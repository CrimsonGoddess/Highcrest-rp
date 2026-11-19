# Public server valet and external vehicle binding contract

This contract is available in **both** `zloma_garages` and `zloma_simplegarages`.
It does not migrate Engine V2, change commercial spawn defaults, charge money,
or enable any server convar. Select one active garage provider.

## Installation and trust

The garage must have `Config.SpawnVehiclesWithServerSetter = true`. There is no
client spawn fallback for this export, even when other garage features use hybrid mode.
Enable the caller explicitly in that garage's `config.lua`:

```lua
Config.Valet = {
    Callers = { ['sd-phone'] = true },
    MaxDistance = 225,
}
```

Commercial defaults have an empty caller list. `MaxDistance` is clamped to 25–300
metres. The product checks finite destination coordinates, current ped/character,
bucket, nearby distance, live caller, canonical owned stored row and exact binding.
**The trusted calling server must validate the ROAD destination**, blocked areas,
paid session, cooldown, and delivery conditions. A proximity bound is not a road
geometry test. Do not forward unchecked client coordinates or a client-generated
session identifier. `isValid` must close over the caller's private paid ticket and
approved destination and return **boolean true** only while they remain valid;
it must be quick and must not yield or perform billing. It is repeatedly called
throughout initialization. A client minigame, client boolean, or bag is not proof.

## Public API

All exports below are **server exports**, with no public net-event equivalent.

```lua
local result = exports[garageResource]:RetrieveVehicleForValet(source, canonicalPlate, {
    sessionId = privatePaidTicketId, -- nonempty string, at most 128 bytes
    purpose = 'valet',
    destination = { x = x, y = y, z = z, w = heading },
    bucket = currentServerBucket,
    isValid = function() return privateTicketStillValid end,
})
```

`source` is the current integer server ID. Plate is a lookup intent (trimmed, at
most 32 bytes); DB plate is canonical and must match. Only owner-owned personal
vehicles with stored=1 and no police impound flag are accepted. Shared/org access
and impound retrieval are not valet permissions. Properties/model come exclusively
from the normalized canonical DB row. Unknown top-level arguments, including
`model`, `props`, `owner`, `recordId` and `netId`, are rejected.

The product uses the existing garage plate lock, `ReserveVehicleInDB` checkout CAS,
`CreateSpawnReservation`, Engine V2 with `warp=false`, canonical initialization,
`FinalizeVehicleSpawn`, tracking and private Core registration. Valet CAS additionally
captures row ID (when available), owner and exact raw canonical properties. Context
resolution blocks store/keys on this pending checkout until the result is published.
Normal garage and valet retrieval cannot consume the same stored row concurrently.

Success means **ready for the caller's delivery lifecycle**, not that an NPC has
already driven the vehicle to the customer:

```lua
{
    success = true, reason = 'ready', outcome = 'ready', sessionId = ticketId,
    entity = entity, netId = netId, model = hash, modelHash = hash,
    originalPlate = canonicalPlate, canonicalPlate = canonicalPlate,
    displayPlate = approvedPhysicalPlate, dbIdentity = 'owned_vehicles:rowId',
    generation = bindingGeneration, revision = revision, bucket = bucket,
    owner = ownerIdentifier, access = { relationship = 'owner', ... },
    context = verifiedVehicleContext,
}
```

The context is the actual `GetVerifiedVehicleContext(source, netId, 'valet')` result:
vehicleId/dbIdentity/recordId, bindingId/generation/generationId, revision, entity,
netId, model/modelHash, bucket/routingBucket, originalPlate/canonicalPlate/displayPlate,
owner/ownerIdentifier/ownerCharacterIdentity, characterIdentity/requesterIdentifier,
access, persistent. Treat generation + DB identity as lifecycle identity, not plate alone.
Refresh it after any asynchronous delivery step:

```lua
local ctx = exports.zloma_core:GetVerifiedVehicleContext(src, result.netId, 'store')
if not ctx or ctx.generation ~= result.generation then return end
```

## Failure, cancellation and unknown outcomes

Failures return `{success=false, reason=string, outcome=string}`. Validation failures
have outcome `not_created`. Confirmed cleanup/restoration has `rolled_back`.
`quarantined` requires reconciliation; never blindly refund/retry or restore stored.
A duplicate session returns `duplicate_session` with the existing phase as outcome;
query its result rather than charging or spawning again.

Validation reasons: caller_not_authorized, ServerSetter_required, invalid_request,
unsupported_argument, invalid_session, session_capacity, invalid_destination,
wrong_bucket, actor_unavailable, destination_too_far, checkout_busy, vehicle_not_found,
canonical_plate_mismatch, not_owner, not_stored_or_impounded,
invalid_canonical_properties, vehicle_already_exists, context_changed, checkout_conflict.
Lifecycle reasons: checkout_outcome_unknown, binding_failed, verification_failed,
retrieval_exception; Engine V2 can return player_initialization_busy,
spawn_point_initializing, spawn_point_occupied, configure_ServerSetter_ModelTypes,
ServerSetter_native_unavailable, reservation_cancelled_or_requester_changed,
requester_bucket_changed, initialization_exhausted, initialization_exception.
Consumers must handle other future engine reasons as failures, using outcome.

```lua
exports[garageResource]:CancelValetRetrieval(sessionId)
exports[garageResource]:GetValetRetrievalResult(sessionId)
exports[garageResource]:AcknowledgeValetHandoff(sessionId, generation)
```

Cancel is caller-scoped. Pending returns `{success=true,reason='cancellation_requested',
outcome='pending'}`; poll until rolled_back/quarantined. It does not acknowledge SQL
cleanup immediately. Ready/delivered returns `already_ready` and keeps the checked-out
vehicle; do not use cancellation to store it. Finished failures return their prior
result. Missing session returns session_not_found.

GetResult returns ready success or the recorded failure; preparing returns pending.
Ready result is revalidated against the current character and binding. A lost current
context returns handoff_context_changed / checked_out, never an automatic refund.

Acknowledge requires a ready session, exact generation and current verified character;
returns `{success=true,reason='delivered',context=ctx}`. Wrong/repeated acknowledgment
returns invalid_handoff. It does not issue keys. Result generation/revision snapshots
are not substitutes for current context.

Disconnect, character/ped/bucket change, invalid destination/session, cancellation or
caller stop during preparation invalidate the engine and trigger captured cleanup.
Rollback never deletes another binding/handle generation or restores a changed DB
row. SQL exceptions/zero rollback rows and lost generations are quarantined with the
plate lock retained for reconciliation. On garage stop, SQL restoration cannot be
safely acknowledged; a concise reconciliation warning identifies ticket/plate and the
checked-out row stays out. After successful publication the normal garage/store
lifecycle owns the vehicle, including after caller disconnect/stop. Restarted callers
must reconcile against their durable paid session and current product context.

Session IDs are consumed for the garage resource lifetime, including failed attempts.
There is a conservative 4096-session limit per resource lifetime; session_capacity
fails before checkout. Start a **new server-generated paid-operation ID** only after
confirmed previous completion/cancellation, never to work around an unknown outcome.

## sd-phone integration example (server)

The existing sd-phone `server/garages/valet.lua` owns the fee, `pending[src]`, current
character/ped/bucket validation and refund policy. Replace its current
`lib.callback.await('sd-phone:client:zlomaValetSpawn', ...)` compatibility trigger with
this actual export. This product workstream does not edit deployed sd-phone.

```lua
-- After sd-phone validates/claims its private session and charges exactly once:
-- spawn is the already SERVER-APPROVED nearby road point; veh.plate is canonical.
-- Generate once when creating the private request, never receive it from a client:
request.productSessionId = request.productSessionId or
    ('%s:%s:%s'):format(src, GetGameTimer(), math.random(1, 2147483647))
local result = exports.zloma_garages:RetrieveVehicleForValet(src, veh.plate, {
    sessionId = request.productSessionId,
    purpose = 'valet',
    destination = {x=spawn.x, y=spawn.y, z=spawn.z, w=spawn.h},
    bucket = request.bucket,
    isValid = current, -- existing private current() plus road/destination validity
})
if not result.success then
    -- refund() is sd-phone's EXISTING once-only refund for this paid request.
    if result.outcome == 'rolled_back' or result.outcome == 'not_created' then
        return refund(result.reason)
    end
    -- pending/duplicate/ready/checked_out/quarantined: retain/reconcile the fee ticket;
    -- use GetValetRetrievalResult(productSessionId); do not charge/spawn again.
    return finish({success=false, reason='reconciliationRequired'})
end
local ctx = lifecycle.verify(src, result.netId, veh, spawn) -- existing server verifier
if not ctx or ctx.generation ~= result.generation then
    -- It is already checked out: reconcile; a failed client delivery hint is no refund proof.
    return finish({success=false, reason='reconciliationRequired'})
end
local driverTicket = lifecycle.register(src, ctx) -- existing private NPC delivery lifecycle
-- Continue existing lastValet/props/response behavior using result.netId/displayPlate.
```

Payment: sd-phone. Creation/init/binding/tracking: garage. Keys: calling server's
existing legitimate key flow, **after** ready binding and a refreshed exact-generation
context. `Core:GiveVehicleKeys(src, ctx.originalPlate)` is the existing server bridge
(the client/key provider can require proximity to the car; invoke at actual handoff,
not while a road-spawned car is distant). No valet key grant is created during reservation.
The caller validates its delivery ticket/current context before key action and calls
`AcknowledgeValetHandoff(productSessionId, result.generation)` at final server-confirmed
handoff. Do not acknowledge based only on a client success boolean/NUI result.
The caller owns once-only final key/handoff execution. API result/ack do not charge fees.

## External admin / market binding policy

Core `server/vehicle_policy.lua` is SERVER-only and defaults to no external callers.
In this deployment the actual resource names found were `zloma_vehManagement` and
`zloma_autopijaca`. Configure them locally (not baked into commercial defaults):

```lua
ZlomaVehiclePolicy = {
    BindingCallers = {
        ['zloma_vehManagement'] = true,
        ['zloma_autopijaca'] = true,
    },
}
```

Allowlisting alone **does not authorize adoption** of an arbitrary existing entity.
Each caller must replace its server `CreateVehicle(...)` with this SERVER factory:

```lua
local entity, reason = exports.zloma_core:CreateVehicleForAuthorizedBinding(
    canonicalModel, serverApprovedVehicleType,
    {x=x, y=y, z=z, w=heading}, validatedBucket)
-- vehicleType: automobile/bike/boat/heli/plane/submarine/trailer/train;
-- derive the type from the caller's server model configuration. No client fallback.
if not entity then return false, reason end
-- Keep existing exact source/permission/DB checkout/props initialization lifecycle:
SetVehicleNumberPlateText(entity, canonicalPlate)
local bound = exports.zloma_core:RegisterAuthorizedVehicle(
    entity, canonicalPlate, canonicalModel, canonicalPlate)
if not bound then
    -- Use the caller's captured exact-handle cleanup/CAS rollback, never a plate scan.
    return false, 'binding_failed'
end
```

Factory signature: `(model:string|integer, vehicleType:string, point:{x,y,z,w?},
bucket:nonnegative integer) -> entity|nil, reason?`. Reasons: caller_not_authorized,
invalid_creation_request, creation_failed. This factory guarantees **creation provenance**,
not paid gameplay completion/properties initialization; those remain the trusted caller's
existing server responsibility. Core captures caller, handle, netId, model and bucket at
actual `CreateVehicleServerSetter` creation and invalidates provenance on entityRemoved.
A different trusted caller, unrelated/client entity, reused handle, model/bucket change,
unconfigured resource or client cannot register it.

Registration signature remains `(entity, canonicalPlate, model, approvedDisplayPlate?,
descriptor?) -> boolean`. External persistent registrations additionally require current
canonical DB plate/model, stored/state=0, and capture DB identity. External transient
registration and custom context resolver registration are not permitted. The existing
full/simple garage and shop private reservation/hybrid paths retain their own product
policy. Only these products can change the approved display plate; invalidation is
limited to product callers or the resource owning that binding.

**The current deployed admin/market direct-native calls need this documented factory
integration in their server workstream. Configuring names alone will fail closed.**
No deployed sources or convars are modified here. Core restart discards private
provenance/bindings: do not scan/adopt vehicles from bags/plates; reconcile or recreate
through the trusted captured lifecycle. Neither script hash nor first-owner=-1 proves
server creation (the latter can also mean the original client disconnected; see the
[Cfx server native implementation](https://github.com/citizenfx/fivem/blob/master/code/components/citizen-server-impl/src/state/ServerGameState_Scripting.cpp)).

## Test evidence

`zloma_core/tests/valet_public_contract_mock.py` executes production Core registry,
both production garage checkout/finalization exports and actual context resolvers:
47 focused checks per product (94 total). Engine creation/initialization and SQL are
simulated; existing Engine V2 suite verifies the engine separately. These tests cover
owner/stored/impound/caller/bucket/model/destination, normal+valet concurrency, replay,
creation/init failures, disconnect/character/bucket/cancel/session/resource invalidation,
DB replacement/unknown outcome, binding-before-result/current context/handoff, trusted
admin+market acceptance and unrelated/reused entity rejection. This is not FXServer
runtime verification. Stage the real phone/factory integrations under strict lockdown
and strict state bags before claiming end-to-end production delivery.

## Files changed in this scoped contract

- `zloma_core/server/vehicle_policy.lua`
- `zloma_core/server/vehicle_authority.lua`
- `zloma_core/fxmanifest.lua`
- `zloma_core/tests/valet_public_contract_mock.py`
- `zloma_core/tests/valet_public_contract_mock.lua`
- `zloma_core/tests/product_security_spec.lua` (receipt-useable startup fixture only)
- Each of `zloma_garages` and `zloma_simplegarages`: `server/vehicle/spawn.lua`, `server/vehicle/context.lua`, `config.lua`.
- Each of Core/full/simple garage: `README.md`, `docs/PublicValetContract.md`.

Frozen Engine V2 server/client files remain unchanged. Deployed server resources and convars remain unchanged.
