"""Production store/mileage authority mocks. No FXServer or database is simulated faithfully."""
from pathlib import Path
from lupa.lua54 import LuaRuntime

root = Path(__file__).resolve().parents[2]
# Resource-specific lifecycle glue need not be byte-identical. Exercise both real implementations.
for selected in ("zloma_garages", "zloma_simplegarages"):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.globals().read_source = lambda product, file: (root / (selected if product == "zloma_garages" and file != "shared/vehicle_properties.lua" else product) / file).read_text(encoding="utf-8-sig")
    lua.execute(Path(__file__).with_name("focused_authority_spec.lua").read_text(encoding="utf-8"))
    print(f"{selected}: production authority scenarios passed")
