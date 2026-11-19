"""Run production Lua handlers under Lua 5.4 mocks; this is not an FXServer test."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[2]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().read_source = lambda product, file: (root / product / file).read_text(encoding="utf-8-sig")
lua.execute((Path(__file__).with_name("product_security_spec.lua")).read_text(encoding="utf-8"))
