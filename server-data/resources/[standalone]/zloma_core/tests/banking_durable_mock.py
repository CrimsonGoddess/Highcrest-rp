"""Selected banking offline bridge; participant SQL semantics are modeled."""
from pathlib import Path
from lupa.lua54 import LuaRuntime
root=Path(__file__).resolve().parents[2]
lua=LuaRuntime(unpack_returned_tuples=True)
lua.globals().read_source=lambda file: (root/'zloma_banking'/file).read_text(encoding='utf-8-sig')
lua.execute(Path(__file__).with_name('banking_durable_spec.lua').read_text(encoding='utf-8'))
