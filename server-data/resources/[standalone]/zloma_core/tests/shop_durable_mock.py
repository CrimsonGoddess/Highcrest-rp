"""Production saga fault tests; SQL transactions are modeled, not a real DB."""
from pathlib import Path
from lupa.lua54 import LuaRuntime
root=Path(__file__).resolve().parents[2]
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().read_source=lambda: (root/'zloma_vehicleshop/server/durable_transactions.lua').read_text(encoding='utf-8-sig')
lua.execute(Path(__file__).with_name('shop_durable_spec.lua').read_text(encoding='utf-8'))
