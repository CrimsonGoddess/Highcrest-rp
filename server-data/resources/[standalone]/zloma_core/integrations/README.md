# Optional selected ESX money reliability participants

These packages are **not prerequisites** for ordinary product gameplay or the practical anti-cheat exit criteria. Shop supports existing ordinary providers with runtime locks/idempotency and interrupted-claim quarantine. Install these only as separately reviewed staging reliability work; no package was applied to deployment.

These packages preserve ESX MAIN bank accounts and the existing
`esx_addonaccount` society rows. They do **not** select zloma_banking's internal
organization ledger or add a second society balance.

The patches were generated against the inspected ESX 1.13.4/source files. Their
SHA-256 inputs are recorded alongside each patch. The scripts generate patches;
they never write deployment files. Review against the server's actual versions
and test a staging copy first. Different versions require a reviewed adaptation.

## ESX wallet

Copy `esx_legacy_wallet/server/zloma_durable_wallet.lua` into the staging
`es_extended/server` directory and apply its accompanying patch there. The patch
loads the helper after functions.lua, guards **both** framework save queries by
wallet revision, and guards bank reads during ambiguous receipt recovery.
Installing the helper alone is deliberately rejected.

The operation journal and MAIN bank update co-commit under InnoDB. The helper
updates private bank cache and revision before asynchronous client notifications.
Repeated operation IDs must have identical identifier/delta. Offline credits are
supported; a reconnect reconciles journal revisions into loaded cache. An older
framework autosave cannot overwrite a newer journal revision.

Other resources must use the normal ESX bank accessor/mutation API or a reviewed
durable participant. Direct private account mutation and direct SQL writes are
outside this contract. `zloma_banking` offline credits use a durable recovery
queue when this participant is active, preserving the original bank ledger.
That compatibility bridge does not certify every banking transfer/withdrawal
as a fully durable multi-account transaction.

## Existing society accounts

Copy `esx_addonaccount/server/zloma_durable_accounts.lua` into staging
`esx_addonaccount/server`, then apply the accompanying patch. It replaces cached
absolute account saves with conditional SQL mutations. `save()` refreshes SQL
instead of overwriting it with a stale balance. Public API names are preserved;
an explicit false now signals a failed mutation.

Existing account IDs, names, balances and ownership remain. The new table holds
operation receipts only. Ambiguous duplicate shared-account rows are rejected.
Negative balances and fractional money require a separately reviewed policy;
the selected integer, nonnegative society ledger is the supported contract.

## Read-only patch checks

From each corresponding resource root:

```powershell
git apply --check --ignore-whitespace 'ABSOLUTE_PATH_TO_PATCH'
```

`--ignore-whitespace` is needed for the inspected CRLF source files. Both checks
passed without applying patches to deployment. Preserve backups and existing
resource edits when preparing staging. No server convars are modified.

## Required staging evidence

Use real MySQL/MariaDB, oxmysql and multiplayer clients. Interrupt before/after
each receipt commit, before the shop cursor update, during framework autosave,
and during reconnect/load. Confirm cache/SQL convergence, preserved society
balances, no second debit/refund/reward, and no stale account overwrite. Mock
tests model SQL semantics; they do not prove actual database isolation. A separate
local scratch-schema integration run also passed 28 production-Lua SQL checks,
including a real ownership-insert rollback and stored-receipt recovery. Actual
oxmysql coroutines and player lifecycle remain staging requirements.
