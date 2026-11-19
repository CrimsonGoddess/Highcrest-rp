# Final practical strict + security pass

2026-10-05. Continues the existing product checkpoint. No new general audit, Engine V2 redesign, deployment edit or convar change.

## NOT READY

The product implementation is complete for the requested practical pass, but the inspected **active initial rental creation** has one missing integration call. With the new exact-binding garage protection, its initial vehicle cannot be stored until the rental workstream calls `BindRentalVehicle`. This is a real legitimate gameplay blocker. Fuel telemetry, missing catalogue coverage and optional third-party durable receipts are **not** staging blockers.

### BALKAN UNITY INTEGRATION REQUIRED

- Resource: `zloma_rental`.
- File/API: `resources/[scripts]/[server-assets]/zloma_rental/server/main.lua`, successful initial server-created rental flow around `rentalEntities[plate]` / `entityRentals[entity]`, before keys/client delivery.
- Expected trusted data: original actor server source, exact entity returned by that flow's `CreateVehicleServerSetter`, its server-generated canonical plate; active paid `zloma_rentals` row and matching checked-out owned vehicle record must already exist. Bucket/model/owner must still match.
- Exact product call, using whichever garage is installed:

```lua
local bound = exports.zloma_garages:BindRentalVehicle(source, entity, plate)
-- Or: exports.zloma_simplegarages:BindRentalVehicle(source, entity, plate)
```

The hook accepts only the `zloma_rental` server caller, checks current rental/DB access and exact entity/model/bucket/actor, waits up to five seconds for the approved physical plate if necessary, creates the private Core binding, then calls the existing `zloma_rental:RegisterRentalEntity(source, entity)` from the authorized garage resource. The caller must handle `false` using its existing failed-creation cleanup/compensation once; it must not issue keys/deliver an unbound successful spawn. Never put this hook behind an unvalidated public event or adopt an entity by plate/bag scanning.

Both garage checkout/finalization paths already call `RegisterRentalEntity` after legitimate private binding. The external rental source was inspected but not changed. Its current initial flow creates/records the entity but contains no Core/product binding call. No new payment architecture is required.

## Practical authority and availability

| Flow | Final behavior |
|---|---|
| Garage store / police impound | Exact live binding, source/access, DB owner/model/properties/stored CAS, bucket, garage/roadside session. Preserve canonical DB tuning. Invalidate on committed storage and delete only captured target. Police remains roadside. |
| Fuel | Prefer optional authoritative reader. Otherwise finite 0–100 bounded telemetry from the verified store session; absent telemetry retains bounded canonical fuel. Fuel cannot authorize money, access, keys or ownership. No fuel/RPM simulator. Dirt bounded 0–15; damage may deteriorate canonical condition. |
| Tuning | Trusted catalogue gives strict per-model limits. Missing catalogue uses bounded known server categories, model/config/default prices. Server session/workshop/driver/account, payment-before-persistence and replay/CAS protections remain. Persistent rows require private generation; paid non-owned tuning retains its nonpersistent flow without registry adoption. Client identity/fuel/health fields cannot replace canonical fields. |
| Shop finances | Existing immutable intent/quote/journal, stock/ownership transaction, actor/provider pinning, ticket, roles, stages, reward/refund replay guards remain. Receipt providers are enhanced support. Ordinary providers use per-account runtime locks and a durable pre-mutation claim; ownership follows an acknowledged payment. Interrupted ordinary claims are quarantined, never blindly re-debited/re-credited. |
| Society | Retain selected existing `esx_addonaccount` ledger. No alternate banking society ledger or second balance. Experimental ESX/addonaccount packages are optional staging reliability work. |
| Mileage | Existing server-observed implementation retained; server writes bags. Not economy/permission authority. |

Ordinary bank credit/refund queued while its character is offline resumes when online. An interrupted cached-money claim may require reconciliation. Historical orders can complete their already-authorized delivery under the new settlement lock; cancelling a historical order whose paid price/original financial snapshot was never saved still requires a trusted historical record rather than an invented refund. These are provider/history reliability limits, not new client-authorized economy paths and not receipt installation prerequisites for new normal gameplay.

## Stable verified vehicle contract

```lua
local context, reason = exports.zloma_core:GetVerifiedVehicleContext(requesterSource, netId, purpose)
```

This is a SERVER export, not a net event/client callback. Return fields:

- `vehicleId` / `dbIdentity` / `recordId`: immutable DB table/row identity, or trusted transient duty/shop identity.
- `bindingId` / `generation` / `generationId`: current private lifecycle generation.
- `revision`: advances on observed canonical property/owner change or approved display-plate change.
- `entity`, `netId`, `model` / `modelHash`, `bucket` / `routingBucket`.
- `originalPlate` / `canonicalPlate`, `displayPlate`.
- `owner` / `ownerIdentifier` / `ownerCharacterIdentity`; `requesterIdentifier` / `characterIdentity` describe the requester.
- `access.relationship`: owner/shared/organization/rental/duty/catalogue or transient testdrive/delivery as applicable; optional organization/job/grade/rentalId.
- `persistent`: false for transient gameplay vehicles.

The result proves identity and the reported relationship, not completion/payment/location for a consumer's action. The consumer must enforce its own legitimate workflow. A `driver` relationship is available only for paid tuning/fitment and must **never** be treated as ownership/refund/permission authority.

Private registry registration comes only from a trusted server lifecycle. Requests cannot register arbitrary netIds. It checks exact handle/netId/model/approved plate/captured bucket and rechecks after DB yields. Matching model/plate clones, removed/stale/reused netIds, wrong generation/bucket and replaced DB row IDs fail. Current access is read from the owning product's existing DB/config/share rules. No bag/physical plate discovery adopts an entity. `GetAuthorizedVehicleBinding` is a server identity helper with no actor access approval.

Bindings cover full/simple garage checkout and impound retrieval, TRUE/hybrid finalization, configured duty/catalogue vehicles, shop purchase/testdrive/delivery (same-text testdrives have separate entity generations and an eight-character plate), trusted admin savecar, shared server initialization and persistent server respawn. Persistence/recovery now reuse only a surviving private binding; scans of visible plates or recovery bags cannot supply authorization. Store/removal invalidates bindings; DB ownership/property changes refresh revision/access on lookup. Core restart clears generations: trusted spawners must explicitly re-register their captured live lifecycles, never scan/adopt unrelated entities.

For a third-party authorized spawner, its own SERVER creation/payment/ownership flow must call:

```lua
exports.zloma_core:RegisterAuthorizedVehicle(entity, canonicalPlate, serverApprovedModel, approvedDisplayPlate)
```

Its custom schema/access rules can register a server `RegisterVehicleContextResolver(resolver)` callback. Consumers in the server workstream should obtain original/display identity through `GetVerifiedVehicleContext` instead of visible plate or `fakePlate:original` proof.

## Fake plate lifecycle

The new client animation ends in one `zloma_garages:fakePlates:change` callback with exact netId and install/remove intent. Server verifies access, private generation/revision, bucket/proximity and fixed item count; generates a collision-checked display plate; consumes one configured item; writes `zloma_vehicle_display_plates`; updates private approved display/revision and server bag; invokes trusted inventory/fuel/tracking hooks. Removal preserves original DB ownership/tuning identity. Police storage cleans captured mapping/provider data; persistent respawn updates mapping generation. Server keys resolve canonical identity from the private binding, not a client-authored bag. Verified transient testdrive/delivery/duty/catalogue lifecycles grant temporary driving/locking use to their authorized actor, so keys/hotwire do not block legitimate mission vehicles; this creates no inventory key or persistent ownership. The client only caches that UX answer locally for two seconds.

Old fragmented `store`, `clear`, `consumeItem`, `trackingUpdate`, `syncInventory*`, `syncFuel*` client mutations have no authority. Bundled client gameplay now uses the complete replacement flow. Server cleanup exports also use the private binding. Inventory recovery skips still-live approved fake bindings across garage restart. Item/provider crash reconciliation remains a narrow P2 boundary; no client-chosen stash rename or inventory minting endpoint remains in that flow.

## Targeted strict state/entity result

The final targeted inventory covers the ten products: Core, antibump, bossmenu, keys, HUD, tuning, full garages, simple garages, stance and vehicleshop. Client bag writes that remain in Core are guarded for non-networked local previews; shared HUD/stance/fake plate/vehicle initialization state is server-written. Local UI remains local. No known bundled client player/network bag write remains in the selected paths.

Boss/stash previews, key handover prop, stance prop, garage/impound NPCs/props and shop/admin/showroom previews remain local. Full/simple garage network vehicles use complete ServerSetter TRUE paths; shop vehicles and delivery props use `ServerControlledVehicles=true`. TRUE paths never fall back to client network creation. Both garage network helper exports now reject local-to-network conversion in TRUE mode. Legacy hybrid paths remain for public customer compatibility.

The two server/client Engine V2 files retain their checkpoint hashes and architecture. Public defaults remain false. Staging must select TRUE in each installed garage and the shop, using the already documented model-type configuration. No production settings were changed. Startup security blocks only read/classify/explain the three security convars; bucket-specific lockdown still needs separate runtime verification.

Read-only selected provider inspection: active lc_fuel pump/charger/nozzle creations are local and the inspected client has no direct replicated bag writer; its refund claim now closes before DB yield. Perfect consumption authority is not required. Own banking/ATM card/cash props are local in the selected configuration (`InsertCard.IsLocal=true`). External/custom provider paths remain separate integration responsibilities.

## Evidence and staging limits

- 353 bundled Lua files compile; 0 syntax errors; targeted inventory: 28 writer sites, 40 entity native sites.
- 109 production-handler mock checks.
- 54 production store/HUD/private binding mock checks.
- 28 production verified-context/fake plate/rental-hook checks: exact identity, ownership change, generation, bucket, unrelated caller, item consumption, install/remove replay, canonical mapping and rental relationship.
- Shop journal: 32 production-module fault checks, including ordinary providers and interrupted-claim quarantine.
- Full/simple Engine V2 simulations: 113 / 112 checks; checkpoint hashes unchanged.
- Existing optional participant/banking mocks: 28 / 13 checks.
- Production Lua + isolated local MariaDB: 33 checks, 490 queries, 33 transactions, one deliberate insert rollback. Includes ordinary-provider purchase/replay/quarantine as well as enhanced receipts. Only the newly created scratch schema was removed; gameplay database untouched.

No FXServer multiplayer/native runtime was executed. These results support entering staging after the rental hook is integrated; they do not assert production tuning parity, native initialization/owner migration stress results or crash-perfect third-party caches. Staging should exercise real fuel/store/addon tuning/purchase/testdrive/delivery/rental/roadside impound with both strict convars and selected TRUE spawn modes.
