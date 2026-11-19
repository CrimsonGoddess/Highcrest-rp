"""Production private registry + garage resolver + fake plate lifecycle; no FXServer."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[2]
lua = LuaRuntime(unpack_returned_tuples=True)
lua.globals().read_source = lambda product, file: (root / product / file).read_text(encoding="utf-8-sig")
lua.execute(Path(__file__).with_suffix(".lua").read_text(encoding="utf-8"))
