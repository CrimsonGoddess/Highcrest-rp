"""Production valet checkout/Core caller policy simulation; no FXServer runtime."""
from pathlib import Path
from lupa.lua54 import LuaRuntime
root = Path(__file__).resolve().parents[2]
for product in ('zloma_garages', 'zloma_simplegarages'):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().product = product
    lua.globals().read_source = lambda p, f: (root / p / f).read_text(encoding='utf-8-sig')
    lua.execute(Path(__file__).with_suffix('.lua').read_text(encoding='utf-8'))
