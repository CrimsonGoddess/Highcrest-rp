"""Run production Lua SQL against an isolated, disposable LOCAL MariaDB schema.

Reads credentials privately from the selected server.cfg; never opens or writes
its configured gameplay database. No FXServer/native/provider runtime is used.
"""
from pathlib import Path
import argparse, datetime, decimal, json, re, uuid
from urllib.parse import urlsplit, unquote
import pymysql
from lupa.lua54 import LuaRuntime, lua_type

parser=argparse.ArgumentParser()
parser.add_argument('--config',required=True,type=Path)
args=parser.parse_args()
config=args.config.read_text(encoding='utf-8-sig')
match=re.search(r'^\s*set(?:r)?\s+mysql_connection_string\s+["\']([^"\']+)["\']',config,re.M)
if not match: raise SystemExit('No connection string in selected config; no database changed')
connection=match[1]
if connection.startswith('mysql://'):
    parsed=urlsplit(connection)
    settings=dict(host=parsed.hostname or 'localhost',port=parsed.port or 3306,
        user=unquote(parsed.username or ''),password=unquote(parsed.password or ''))
else:
    fields=dict(part.split('=',1) for part in connection.split(';') if '=' in part)
    fields={k.strip().lower():v.strip() for k,v in fields.items()}
    settings=dict(host=fields.get('server',fields.get('host','localhost')),port=int(fields.get('port',3306)),
        user=fields.get('userid',fields.get('user','root')),password=fields.get('password',''))
if settings['host'] not in ('localhost','127.0.0.1','::1'):
    raise SystemExit('Configured database is not local; no database changed')
try:
    conn=pymysql.connect(**settings,charset='utf8mb4',autocommit=True,cursorclass=pymysql.cursors.DictCursor)
except Exception as exc:
    raise SystemExit('Local database connection unavailable: '+type(exc).__name__) from None
schema='zloma_security_test_'+uuid.uuid4().hex[:12]
assert re.fullmatch(r'zloma_security_test_[a-f0-9]{12}',schema)
created=False
root=Path(__file__).resolve().parents[2]
lua=LuaRuntime(unpack_returned_tuples=True)
stats={'queries':0,'transactions':0,'rollbacks':0}
faults={'cursor':False,'commit':False}

def plain(value):
    if lua_type(value)=='table':
        keys=list(value.keys())
        if keys and all(isinstance(k,int) for k in keys) and set(keys)==set(range(1,len(keys)+1)):
            return [plain(value[i]) for i in range(1,len(keys)+1)]
        return {str(k):plain(v) for k,v in value.items()}
    return value

def converted(value):
    if isinstance(value,(datetime.datetime,datetime.date)): return value.isoformat()
    if isinstance(value,decimal.Decimal): return float(value)
    if isinstance(value,dict): return lua.table_from({k:converted(v) for k,v in value.items()})
    if isinstance(value,list): return lua.table_from([converted(v) for v in value])
    return value

def execute(query,values=None,kind='query'):
    values=plain(values) if values is not None else []
    if isinstance(values,dict):
        values=[values.get(str(i)) for i in range(1,len(values)+1)]
    if faults['cursor'] and 'SET `cursor`=?' in query and values[0]==faults['cursor']:
        faults['cursor']=False
        raise RuntimeError('Injected interruption before saga cursor update')
    stats['queries']+=1
    with conn.cursor() as cur:
        cur.execute(query.replace('?','%s'),values)
        if kind=='insert': return cur.lastrowid
        if kind=='update': return cur.rowcount
        rows=cur.fetchall()
        if kind=='scalar': return converted(next(iter(rows[0].values()))) if rows else None
        if kind=='single': return converted(rows[0]) if rows else None
        return converted(list(rows))

def transaction(statements):
    stats['transactions']+=1
    conn.begin()
    try:
        for index in range(1,len(statements)+1):
            stmt=statements[index]
            execute(stmt['query'],stmt['values'])
        conn.commit()
    except pymysql.MySQLError as exc:
        conn.rollback();stats['rollbacks']+=1
        print('Scratch transaction rollback:',exc.args[0],exc.args[1])
        return False
    except Exception:
        conn.rollback();raise
    if faults['commit']:
        faults['commit']=False
        raise RuntimeError('Injected lost acknowledgement after real SQL commit')
    return True

try:
    with conn.cursor() as cur:
        cur.execute(f'CREATE DATABASE `{schema}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci')
        created=True
        cur.execute(f'USE `{schema}`')
        cur.execute('SELECT DATABASE() AS name')
        assert cur.fetchone()['name']==schema
    lua.globals().sql_execute=execute
    lua.globals().sql_transaction=transaction
    lua.globals().encode_json=lambda value: json.dumps(plain(value),separators=(',',':'))
    lua.globals().decode_json=lambda value: converted(json.loads(value))
    lua.globals().read_source=lambda product,file: (root/product/file).read_text(encoding='utf-8-sig')
    lua.globals().set_fault=lambda name,value: faults.__setitem__(name,value)
    lua.execute(Path(__file__).with_name('durable_sql_spec.lua').read_text(encoding='utf-8'))
    print('Isolated MariaDB SQL evidence:',json.dumps(stats,sort_keys=True))
finally:
    if created:
        assert re.fullmatch(r'zloma_security_test_[a-f0-9]{12}',schema)
        with conn.cursor() as cur: cur.execute(f'DROP DATABASE `{schema}`')
        print('Only the newly created scratch schema was removed; gameplay database untouched')
    conn.close()
