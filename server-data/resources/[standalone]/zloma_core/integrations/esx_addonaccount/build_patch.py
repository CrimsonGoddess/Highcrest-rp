"""Produce a reviewable selected-provider patch without editing deployment."""
import argparse
import difflib
import hashlib
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("resource", type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
paths = ["server/classes/addonaccount.lua", "fxmanifest.lua"]
parts = []
for relative in paths:
    path = args.resource / relative
    before = path.read_text(encoding="utf-8-sig")
    if relative.endswith("addonaccount.lua"):
        assert "function CreateAddonAccount(" in before, "Unsupported addonaccount class"
        after = (root / relative).read_text(encoding="utf-8")
    else:
        entry = "'server/main.lua'"
        assert before.count(entry) == 1, "Unsupported addonaccount manifest"
        after = before.replace(entry, "'server/zloma_durable_accounts.lua',\n\t" + entry)
    parts.extend(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
                                    fromfile=f"a/{relative}", tofile=f"b/{relative}"))
(root / "esx_addonaccount.patch").write_text("".join(parts), encoding="utf-8")
(root / "source_hashes.txt").write_text(
    "\n".join(f"{hashlib.sha256((args.resource / path).read_bytes()).hexdigest()}  {path}" for path in paths) + "\n",
    encoding="utf-8",
)
print("Reviewable addonaccount patch generated; existing society accounts retained; deployment source unchanged.")
