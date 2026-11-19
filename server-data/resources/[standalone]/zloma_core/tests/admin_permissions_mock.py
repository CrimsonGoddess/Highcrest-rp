"""Run the actual IsAdmin export with isolated framework/ACE mocks."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[1]
source = (root / "server/framework/init.lua").read_text(encoding="utf-8-sig")
start = source.index("exports('IsAdmin',")
end = source.index("-- Server callback: Check if player is admin", start)
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("assert(load(...))", source)
lua.execute((root / "tests/admin_permissions_spec.lua").read_text(encoding="utf-8"), source[start:end])
