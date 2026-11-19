"""Static evidence inventory, not a proof of authority or FXServer compatibility.

Lua comments/strings are masked before searching. Only code hash literals are
replaced for stock Lua 5.4 compilation; SQL backticks inside strings are retained.
"""
from pathlib import Path
import json
import re
from lupa.lua54 import LuaRuntime

ROOT = Path(__file__).resolve().parents[2]
PRODUCTS = ['core', 'antibump', 'bossmenu', 'keys', 'hud', 'tuning',
            'garages', 'simplegarages', 'stance', 'vehicleshop']


def lexical_views(source):
    masked, compilable = list(source), list(source)
    i = 0
    while i < len(source):
        start = i
        comment = source.startswith('--', i)
        if comment:
            i += 2
        long = re.match(r'\[(=*)\[', source[i:])
        if long:
            end_token = ']' + long[1] + ']'
            end = source.find(end_token, i + len(long[0]))
            i = len(source) if end < 0 else end + len(end_token)
        elif comment:
            end = source.find('\n', i)
            i = len(source) if end < 0 else end
        elif source[i] in "\"'":
            quote = source[i]
            i += 1
            while i < len(source):
                if source[i] == '\\':
                    i += 2
                elif source[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
        elif source[i] == '`':
            end = source.find('`', i + 1)
            i = len(source) if end < 0 else end + 1
            compilable[start:i] = ['0'] + [' ' if c != '\n' else '\n' for c in source[start+1:i]]
        else:
            i += 1
            continue
        masked[start:i] = ['\n' if c == '\n' else ' ' for c in source[start:i]]
    return ''.join(masked), ''.join(compilable)


def side(path):
    if path.parts[0] == 'client' or path.name == 'client.lua': return 'CLIENT'
    if path.parts[0] == 'server' or path.name == 'server.lua': return 'SERVER'
    return 'SHARED/CONFIG'


NATIVES = re.compile(r'\b(CreateVehicleServerSetter|CreateVehicle|CreateObjectNoOffset|CreateObject|CreatePed|ClonePed|NetworkRegisterEntityAsNetworked)\s*\(')
WRAPPERS = re.compile(r'\b(SpawnVehicleHybrid|SpawnVehicle|SpawnVehicleFromData|SpawnAuthorizedShopVehicle|SpawnMissionVehicle|SpawnDeliveryProp|EnsureEntityNetworked)\s*\(')
STATE = re.compile(r'\bstate\s*(?::\s*set\s*\(|\.\s*[A-Za-z_]\w*\s*=(?!=)|\[[^\]\n]+\]\s*=(?!=))')


def classify(product, path, kind, snippet):
    realm = side(path)
    if kind == 'state':
        if realm == 'SERVER': return 'S1 SERVER WRITER; request authority requires separate review'
        if path.as_posix() == 'shared/fake_plates.lua': return 'S1 SERVER BRANCH (IsDuplicityVersion guard)'
        if product == 'zloma_core': return 'S2 LOCAL PREVIEW ONLY (non-network entity guard); external provider S5'
        return 'S5 UNKNOWN — manual review required'
    if kind == 'wrapper': return 'WRAPPER — follow native inventory and mode guards; not an extra entity'
    if realm == 'SERVER':
        return 'SERVER CREATED; RPC creation staging required' if 'CreateVehicle(' in snippet else 'SERVER CREATED; lifecycle staging required'
    if 'NetworkRegisterEntityAsNetworked' in snippet:
        if product in ['zloma_garages', 'zloma_simplegarages'] and path.as_posix() == 'client/utils.lua':
            return 'HYBRID NETWORK HELPER; ServerSetter TRUE rejects local-to-network conversion'
        return 'CLIENT NETWORK REGISTRATION; manual strict-mode review required'
    if product == 'zloma_vehicleshop' and path.as_posix() in ['client/shared/security_spawn.lua', 'client/business/delivery.lua']:
        return 'CLIENT CREATED NETWORKED GAMEPLAY; hybrid-only BLOCKER; opt-in server path available'
    if product in ['zloma_garages', 'zloma_simplegarages'] and 'CreateVehicle(' in snippet and ('true, false' in snippet or 'true,false' in snippet):
        return 'CLIENT CREATED NETWORKED GAMEPLAY; hybrid-only BLOCKER; ServerSetter TRUE skips path'
    return 'CLIENT CREATED LOCAL; STRICT COMPATIBLE (native network flag false)'


def main():
    lua = LuaRuntime(unpack_returned_tuples=True)
    compile_lua = lua.eval('function(src,name) local f,e=load(src,name); return f~=nil,e end')
    records, errors, counts = [], [], {}
    for short in PRODUCTS:
        product = 'zloma_' + short
        count = 0
        for file in sorted((ROOT / product).rglob('*.lua')):
            relative = file.relative_to(ROOT / product)
            if any(p in ['tests', 'node_modules', '.git'] for p in relative.parts): continue
            count += 1
            source = file.read_text(encoding='utf-8-sig')
            code, compilable = lexical_views(source)
            ok, error = compile_lua(compilable, str(file))
            if not ok: errors.append({'file': str(file), 'error': error})
            source_lines = source.splitlines()
            for kind, pattern in [('state', STATE), ('entity', NATIVES), ('wrapper', WRAPPERS)]:
                for match in pattern.finditer(code):
                    line = code.count('\n', 0, match.start()) + 1
                    snippet = source_lines[line-1].strip()
                    records.append({'product': product, 'file': relative.as_posix(), 'line': line,
                                    'realm': side(relative), 'kind': kind, 'snippet': snippet,
                                    'classification': classify(product, relative, kind, snippet)})
        counts[product] = count
    output = ROOT / 'zloma_core' / 'docs'
    output.mkdir(exist_ok=True)
    (output / 'ProductSecurityInventory.json').write_text(json.dumps({'lua_files': counts, 'compile_errors': errors, 'records': records}, indent=2), encoding='utf-8')
    lines = ['# Product state/entity inventory', '',
             'Generated by `tests/product_security_scan.py`. Line numbers reference current source. Comments and string content are excluded. Wrapper rows identify definitions/call sites, not additional entities. Classification is limited to bundled paths and must be read with FinalPracticalStrictSecurityPass.md; ProductSecurityAudit.md is historical.', '',
             f'Lua 5.4 syntax: {sum(counts.values())} files; {len(errors)} errors. FiveM code hash literals replaced only outside strings/comments. No native/runtime execution.', '']
    for product in counts:
        lines += [f'## {product}', '', '| Location | Kind / realm | Classification | Source |', '|---|---|---|---|']
        for record in records:
            if record['product'] != product: continue
            location = f"{record['file']}:{record['line']}"
            snippet = record['snippet'].replace('|', '\\|').replace('`', "'")
            lines.append(f"| {location} | {record['kind']} / {record['realm']} | {record['classification']} | `{snippet}` |")
        if not any(r['product'] == product for r in records): lines.append('| None detected | — | No matching writer/creation/wrapper | — |')
        lines.append('')
    (output / 'ProductSecurityInventory.md').write_text('\n'.join(lines), encoding='utf-8')
    print(json.dumps({'lua_files': counts, 'total_files': sum(counts.values()), 'compile_errors': errors,
                      'state_writers': sum(r['kind']=='state' for r in records), 'native_entity_sites': sum(r['kind']=='entity' for r in records)}, indent=2))
    if errors: raise SystemExit(1)


if __name__ == '__main__': main()
