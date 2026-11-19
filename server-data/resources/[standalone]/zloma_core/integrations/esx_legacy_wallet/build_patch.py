"""Produce a reviewable patch against selected ESX source. Never edits deployment."""
import argparse
import difflib
import hashlib
import re
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("resource", type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
functions = args.resource / "server/functions.lua"
original = functions.read_text(encoding="utf-8-sig")
query = 'WHERE `identifier` = ?",'
guard = 'WHERE `identifier` = ? AND `zloma_wallet_revision` <= ?", -- ZLOMA_DURABLE_WALLET_SAVE_GUARD'
# Restrict replacements to the two standard save functions, not other queries.
start = original.index("function Core.SavePlayer(")
end = original.index("ESX.GetPlayers = GetPlayers", start)
section = original[start:end]
assert section.count(query) == 2, "Unsupported ESX save query layout; manual review required"
assert section.count("xPlayer.identifier,") == 2, "Unsupported save parameter layout"
section = section.replace(query, guard)
section = re.sub(r"(?m)^(\s*)xPlayer\.identifier,$", lambda m: m.group(0) + "\n" + m.group(1)
                 + "tonumber(xPlayer.getMeta('zlomaWalletRevision')) or 0,", section)
updated = original[:start] + section + original[end:]
manifest = args.resource / "fxmanifest.lua"
manifest_original = manifest.read_text(encoding="utf-8-sig")
entry = "'server/functions.lua',"
assert manifest_original.count(entry) == 1, "Unsupported ESX manifest; manual review required"
manifest_updated = manifest_original.replace(entry, entry + "\n    'server/zloma_durable_wallet.lua',")
classes = args.resource / "server/classes/player.lua"
classes_original = classes.read_text(encoding="utf-8-sig")
get_account = 'function self.getAccount(account)\n        account = string.lower(account)'
assert classes_original.count(get_account) == 1, "Unsupported ESX bank accessor; manual review required"
classes_updated = classes_original.replace(get_account, get_account + "\n        -- ZLOMA_DURABLE_WALLET_READ_GUARD\n"
    + "        if account == 'bank' and ZlomaWaitDurableWallet then ZlomaWaitDurableWallet(self.identifier) end")
parts = []
for path, before, after in [("server/functions.lua", original, updated), ("server/classes/player.lua", classes_original, classes_updated),
                           ("fxmanifest.lua", manifest_original, manifest_updated)]:
    parts.extend(difflib.unified_diff(before.splitlines(True), after.splitlines(True),
                                    fromfile=f"a/{path}", tofile=f"b/{path}"))
(root / "esx_legacy_wallet.patch").write_text("".join(parts), encoding="utf-8")
(root / "source_hashes.txt").write_text(
    "\n".join(f"{hashlib.sha256(path.read_bytes()).hexdigest()}  {path.relative_to(args.resource)}" for path in [functions, classes, manifest]) + "\n",
    encoding="utf-8",
)
print("Reviewable ESX wallet save-guard patch generated; deployment source unchanged.")
