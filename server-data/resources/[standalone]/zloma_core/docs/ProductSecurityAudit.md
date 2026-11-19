# Zloma whole-product security audit

Latest authoritative continuation: [FinalPracticalStrictSecurityPass.md](FinalPracticalStrictSecurityPass.md). Fuel/catalogue/receipt availability gates below are historical and superseded; the current report records the practical pass and exact remaining rental integration.

Datum: 2026-10-05. Repozitoriji: `D:\Github\zloma_*`. Deployment kopije nisu mijenjane. Ovo je izvještaj o provedenoj statičkoj provjeri i remediation checkpointu, **nije potvrda da je cijeli anti-cheat cilj postignut**.

Default hybrid client vehicle spawn ostaje aktivan. `Config.SpawnVehiclesWithServerSetter = false` u obje garaže; `Config.ServerControlledVehicles = false` u vehicleshopu. Vehicle Spawn Engine V2 nije redizajniran tijekom ovog audita. Njegov status ostaje **EXPERIMENTAL — NOT RUNTIME TESTED**. Nijedan proizvod nema status RUNTIME VERIFIED.

## Rezultat

| Product | Završni checkpoint status | Server authority | StateBag strict | Entity lockdown strict |
|---|---|---|---|---|
| zloma_core | NOT READY za sve podržane integracije | Money/society exporti ojačani; vanjski provider ugovori nisu dokazani | Bundled local preview writers kompatibilni; providers S5 | Nema vlastitog creation nativea; providers/custom hooks zasebno |
| zloma_antibump | STATICALLY READY FOR STAGING | Nema osjetljive server authority | Nema writera | Nema entity creationa |
| zloma_bossmenu | NOT READY za sve inventory/banking kombinacije | Server job/permission, grade, serialization, stash grants | Nema writera | Svi vlastiti props lokalni |
| zloma_keys | STATICALLY READY FOR STAGING za bundled flowove | Ownership/grant key bridge, eligible random-search registry, timed hotwire/carjack sessions | Nema writera | Handover prop lokalni; ne stvara network vehicles/peds |
| zloma_hud | NOT READY | Server stress cache; mileage i stimulus izvještaji još client-dependent | Vlastiti writeri server-side | Nema creationa |
| zloma_tuning | NOT READY | Server session, DB baseline, canonical account, quote, payment, CAS | Nema writera | Nema creationa |
| zloma_garages | NOT READY za cijeli proizvod | Spawn reservations ojačani; legacy store/impound properties ostaju problem | Bundled writeri server-side; providers S5 | Default hybrid BLOCKER; ServerSetter put statički kompatibilan uz integracijske iznimke dolje |
| zloma_simplegarages | NOT READY za cijeli proizvod | Spawn reservations ojačani; legacy store/impound properties ostaju problem | Bundled writeri server-side; providers S5 | Default hybrid BLOCKER; ServerSetter put statički kompatibilan |
| zloma_stance | STATICALLY READY FOR STAGING | Persistent fitment validira server driver/plate/zone/bounds | Writer je server-side | Station prop lokalni |
| zloma_vehicleshop | NOT READY | Server catalog/price/stock, tickets, delivery stages; durable financial completion nije zaključena | Bundled writer server-side; providers S5 | Default hybrid BLOCKER; odvojen experimental server-created put |

Statička API kompatibilnost nije dokaz autoriteta: server može zapisati client-authored vrijednost. NOT READY ovdje uključuje konkretne otvorene authority i compatibility prepreke; runtime test sam po sebi ne uklanja nedostatak autorizacije.

## zloma_core

**Critical/High findings:** ESX debit export nije provjeravao raspoloživi balance; više proizvoda moglo je preklapati society mutacije. Networked MK Keys / fuel provider implementacije izvan ovog repozitorija nisu dokazano strict-state kompatibilne.

**Changes:** `server/framework/init.lua` odbija NaN/infinity/negativne iznose i nevaljane račune; ESX RemoveMoney/RemoveSocietyMoney provjeravaju saldo; society mutation exporti koriste per-job lock preko yielda. Vlastiti client `fuel`/`Keys` writers ograničeni su na non-networked preview entity. Server-only exports ostaju trusted integration API, nisu client net eventi.

**Authority:** nema novog client economy API-ja. Lock ne čini proizvoljni vanjski bank export atomski sigurnim protiv drugih resourcea koji izravno koriste isti provider. Povrat i failure ugovor svakog banking/inventory providera još treba zasebno potvrditi.

**Static/mock:** 96 Lua files compile; writer/native inventory obuhvaćen. Product mocks koriste Core adapter stubove, **ne testiraju stvarni ESX/QB/QBox banking backend**.

**Runtime / blockers:** provjeriti ESX/QB/QBox money i society underflow/concurrency/refund, MK Keys i sve odabrane fuel/key/custom provider exporte. S5 provider ne dobiva automatski sigurnosno odobrenje iz guardova u Coreu.

## zloma_antibump

**Critical/High findings:** none detected. **NO SECURITY REMEDIATION REQUIRED.** Nema economy/inventory/permission eventa, state mutationa niti entity creationa.

**Changes:** nema produkcijskih izmjena. Handling flag primjenjuje se kroz `lib.onCache('vehicle')` ili local export. Duplicate entry throttle koristi ReapplyDelayMs; nema stalnog gameplay polling threada. Rename warning thread radi samo kod pogrešnog resource imena.

**Static/mock:** 4 Lua files compile; stvarni client entry handler mock provjerava throttle, re-entry i ignored model. Strict-state/entity kompatibilan.

**Runtime:** entry/exit, restart dok je igrač u autu, ignored models, interaction s drugim handling resources. Na restartu se resetira local cache; nije dokazano da ox_lib automatski ponovi entry za već zauzeto vozilo. Nema stop restore handling flagova; ovaj postojeći behavior treba potvrditi, ne predstavljati kao security bug.

## zloma_bossmenu

**Confirmed High findings:** arbitrary/non-existent/fractional grades; mutacije kroz yield bez zajedničke serialization zaštite; stash item pickup prije uspješnog deletea; stash menu authorization nije dovoljan za izravni inventory open API.

**Changes:** novi `server/security.lua`, eksplicitno učitan u manifestu. Bounded finite payloads; mutation lock; postojeći server boss/permission/admin checks zadržani. Hire/rank/salary/permissions zahtijevaju stvarni grade i postojeću hijerarhiju. Society amount integer bounds; society job ostaje server permission-scoped. Stash placement/open/pickup traži server proximity. Pickup blokira otvor/move, ponovno provjerava empty inventory, briše točan owner row prije izdavanja placement itema; inventory-full failure vraća row. PIN type validation dodana.

Ox inventory open/swap hooks sprječavaju izravni open bez kratkog server grant-a i move tijekom pickup-a. Hook ne radi DB mutacije. Admin remote open ostaje dopušten samo kroz server admin check. [Provider hook contract](https://overextended.dev/docs/ox_inventory/Functions/Server/Hooks).

**Authority:** own callbacks koriste stvarni server job/grade/permissions. ox_inventory stash path ima provider-side gate. **Drugi inventory provideri nemaju ovdje implementiran ekvivalentni provider-side open hook**; samo menu check nije dovoljan dokaz zaštite. External banking provider atomicity nije potvrđena.

**Static/mock:** 18 Lua files compile; production wrapper/grade, NaN/deep payload, concurrent mutation, direct stash bypass, source/expiry grant, pickup full-inventory restore, single issuance/replay/remote checks.

**Runtime / blockers:** ESX/QB/QBox zaposlenici online/offline; svi society providers; provider exceptions nakon stash deletea i restore failure; restart/open inventory tijekom pickup-a; ne-ox direct-open autorizacija. Čisti mock ne dokazuje provider rollback ili crash durability.

## zloma_keys

**Confirmed Critical/High findings:** original proximity-only garage bridge mogao je izdati fizički key za tuđe obližnje vozilo; hotwire/carjack completion nije imao dovoljnu server attempt autorizaciju. Handover cosmetic bio je networked client object.

**Changes:** novi server authorization module. Client key request mora dokazati DB ownership ili potrošiti trusted server integration grant, uz exact plate/model/bucket/entity provjere. Garažne reservations izdaju grant; vehicleshop daje key nakon authorized entity bind-a. Handover prop sada je local cosmetic. Admin createkeys ostaje admin-only i koristi server-supported model native. Lock request validates finite netId, boolean intent, key, exact vehicle, bucket, keyfob distance.

Hotwire je source/identifier/entity/model/plate/bucket-bound attempt s readiness/expiry, completion consumption i replay zaštitom. Carjack počinje dok je stvarni NPC driver još u autu; provjerava weapon/NPC/proximity i completion time/context. Player peds i neodobreni script NPCs nisu prihvatljivi. Trusted server export `AuthorizeCarjackNpc(vehicle, victim)` omogućuje legitimnom NPC resourceu uključivanje scripted NPC-a; grant traje 120s. Minigame rezultat nije authorization dokaz.

Random key search provjerava actual driver/plate i framework-specific DB ownership, ownership query failure ne tretira kao dokaz unowned vozila; ponavlja entity validation nakon DB yielda. Script-created vehicle zahtijeva kratku trusted server registraciju `AuthorizeVehicleKeySearch(vehicle)`; grant se potroši na attempt. Ambient vehicles ostaju eligible prema originalnoj konfiguraciji. Metadata model je server observed, label je bounded UX.

**Authority:** zatvoren je pronađeni script-vehicle random key farming put; driver/proximity i DB absence sami nisu authorization za scripted vehicle. Staging mora potvrditi population type i obje trusted registracije na stvarnom artifactu. External scripted-NPC/vehicle resources moraju koristiti nove server exporte za takve legitimne featureove; bez te integracije custom scripted flow nije kompatibilan. Resource key authority ne zaustavlja unrelated global client network creation kada je lockdown inactive.

**Static/mock:** 15 Lua files compile; ownership/grant/no-grant/replay; scripted random-search denied/trusted-grant/single issuance/replay; hotwire missing/early/wrong-source/replay; carjack unapproved script-NPC, trusted integration, early completion and single issuance. UI labels/key provider handling za hash metadata još zahtijevaju staging.

**Runtime / blockers:** key handover remote visuals, provider inventory-full/retry, legitimate owned garage/shop keys, ambient NPC carjack, scripted NPC integrations s novim exportom, source reuse, owner migration, hotwire cancel/timeout. Global arbitrary client vehicle creation ostaje odvojeni server-level problem.

## zloma_hud

**High findings:** replicated stress state bio je persistence input; mileage submission ostaje client-authored persistent vrijednost. Client može potisnuti stress/mileage izvještaje čak i kada su poslani izvještaji bounded.

**Changes:** stress je server-local authoritative cache; replicated stress bag je output. Seatbelt toggle je intent, true zahtijeva actual vehicle/bucket; server-local seatbelt cache koristi se za speeding threshold umjesto client-writable bag-a. ESX load event ne prihvaća network-origin target player ID. Raniji reason allowlist/cooldowns, item consumption i admin/server export zaštite ostaju.

**Authority:** tablet/item rewards zahtijevaju inventory server flow. **Mileage nije završena authority migracija:** `server/mileage.lua:updateMileage` prihvaća client absolute amount nakon session/driver/plate/rate bounda. GetMileage resetira session budget iz DB. Client može izostaviti izvještaj ili poslati dopušten, ali neistinit iznos. Stress speeding/shooting stimulus još se oslanja na client report. Potreban je server observation/tracking uz očuvanje class exemptions i originalnog gameplay timing-a; nije pošteno proglasiti to riješenim samo uklanjanjem eventa.

**State:** writeri server-side. Seatbelt je S3 intent/UX u kontekstu vlastitog legit toggle flowa, nije proof of permission. Client-owned bags više nisu dokaz stress balance-a. Mileage je S4 indirect authoring preko server relay-a kada persistence utječe na vrijednost/maintenance vozila.

**Static/mock:** 27 Lua files compile; actual server stress cache ne prihvaća izmijenjeni replicated stress; seatbelt na foot odbijen, vehicle toggle očuvan. Mileage/server stimulus authority nije testiran kao riješen.

**Runtime / blockers:** server mileage migration, omit/reset/teleport tests, tracking across driver switch/bucket/restart, custom stress/mileage providers; consumed inventory reward/full inventory; persistence on join/drop/source reuse.

## zloma_tuning

**Confirmed Critical/High findings:** checkout originalno prihvaća client-derived cost i plate/context. To nije pretpostavljen nalaz: server handler je zamijenjen server session authority flowom.

**Changes:** server session počinje samo za observed driver u legit workshop/job ili permitted command flowu. Server bira plate/model/DB baseline, zone account/society/free policy i pricing. Client šalje token + customization intent + repair/clean intent. Server računa quote/checkout; finite bounded allowlist; alias normalization za ox_lib i legacy mods; generic client `mods` nije prihvaćen kao zaobilazni kanal. Damage/fuel/ownership/model ne mogu se smuggleati kroz customization payload. Payment prethodi persistence; source i plate locks; DB baseline CAS; consume prije persistence yielda; refund nakon CAS failure. Server webhook logging ostaje aktivan. Trusted tracked-garage props refresh nakon uspješnog savea.

**Compatibility / remaining High blocker:** `Config.Prices.ModelClasses` je trusted server map, trenutno prazan. Explicit Vehicles pricing radi; ostali modeli koriste Default dok se ne popuni trusted class map. To **ne jamči originalnu class pricing jednakost**. Potrebno je dopuniti i provjeriti server catalogue za proizvod prije releasea.

Mod indices su trenutno generic bounded integer range, a ne potpuni per-model mod catalogue. `Config.RemoveGunsTuningMods` ostaje client UI filter; server ne provodi model-specific weapon-labelled mod zabrane. Ne može se tvrditi da je svaki dopušteni mod server-catalogue odobren. Potreban je trusted per-model mod/extras/livery catalogue bez izbacivanja legitimnih customization kategorija. Garažni legacy store raw props može zaobići tuning payment iako je tuning callback ojačan.

**Static/mock:** 8 Lua files compile; actual begin/quote/save handler: non-admin free, wrong zone/token/plate/vehicle, NaN/infinity/extreme index, failed payment, one payment-before-persist, replay, CAS refund, protected health/fuel, authorized free tuning. Actual client UI/cart and vehicle natives nisu izvršeni.

**Runtime / blockers:** class/model catalogue; every existing customization feature, colors/RGB, neon, extras, wheels, weapon restrictions, repair/clean, free admin command, society overrides, unknown/non-owned vehicle, concurrent garage save, DB/provider refund failure, external tuning integrations. Ne objaviti dok class-price behavior nije izjednačen ili izričito dokumentiran kao konfiguracijska migracija.

## zloma_garages

**Confirmed High findings during integration pass:** hybrid duty spawn approval nije vezao permission/spawn context dovoljno čvrsto; client duty props mogao je postati server-replicated VehicleProperties. Hybrid persistent exit props event mogao je zamijeniti tracked canonical props bez source authorizationa.

**Changes:** duty koristi server Context i kada je ServerSetter false; approval bilježi configured model/spawn/garage/identity/time. Confirmation provjerava finite netId, source, ticket, TTL, actual model/bucket/owner/spawn proximity. Properties nastaju iz server duty configa. Failure može vratiti samo matching pending allocation. Key grants izdaju se iz server-approved reservation flowa. Exit persistentPropsUpdate je sada owner/bucket/proximity-scoped refresh intent i snima server health/dirt; tuning mutations koriste trusted server export. Extra boolean/0/1 setter compatibility ispravljen.

**Authority / remaining Critical/High blockers:** `server/garages/vehicles.lua:storeVehicle` sprema `data.props`/fuel; `server/impound/police.lua` također prima full props. Store path ima DB ownership/org checks, ali nije dovoljan proof da submitted netId pripada točno tom vozilu i garage locationu; cleanup koristi submitted netId. To dopušta persistent properties manipulation i arbitrary entity target attempt. Potrebna je coordinated server property authority i full store target/session validation; samo očuvanje baseline modova bez integracijskog contracta može razbiti legitimno third-party tuning. Ranije "substantially handled" nije dokaz da je ovaj legacy path siguran.

**State/entity:** direct writeri server-side. Default hybrid creates gameplay vehicles i blokira strict/relaxed. ServerSetter own native put statički kompatibilan; shared vehicle path `server/shared/access.lua:SpawnVehicleFromData` koristi server RPC `CreateVehicle` i client property broadcast, nije Engine V2 revision lifecycle. Potrebna je konkretna integration staging provjera, posebno bucket/cosmetics/owner migration; ne označiti cijeli resource automatski strict-complete zbog jednog Engine V2 puta.

**Static/mock:** 69 production Lua files compile; 113 simulated server checks, plus key bridge tests. Engine tests ne izvršavaju svaku legacy store/impound/shared integration.

**Runtime / blockers:** store/impound target and property authority, external hooks/providers, shared-access RPC lifecycle, hybrid tuning persistence, all vehicle types, reservation replay/failure/rollback, fake plates, keys, recovery, restart, bucket/source/owner migration and multiplayer tuning visibility.

## zloma_simplegarages

**Changes/findings:** isti duty Context/ticket/config props/key grant i extras compatibility popravci kao full garage; ServerSetter V2 nije redizajniran.

**Remaining Critical/High blockers:** `server/garages/vehicles.lua:storeVehicle` i `server/impound/police.lua` i dalje koriste full client props/fuel i submitted netId cleanup. Server owner check nije proof of actual target/property authenticity. Potreban isti server property/target integration contract; default hybrid network creation blokira strict/relaxed.

**Static/mock:** 46 production Lua files compile; 112 simulated server checks. Bundled state writers server-side; providers S5. ServerSetter selected path statically strict-compatible, EXPERIMENTAL — NOT RUNTIME TESTED.

**Runtime / blockers:** owner/org stores, impound, third-party tuning persistence, key/fuel providers, server creation types, tuning visibility/driver ownership, failure cleanup, restart and routing bucket tests. Nema runtime evidence.

## zloma_stance

**Confirmed High findings:** need finite integral entity identity and bucket scope; save acknowledgement mora odražavati affected rows, ne samo odsutnost SQL exceptiona. Raniji authority guards iz postojeće radne kopije očuvani.

**Changes:** apply zahtijeva actual driver, exact network id/plate/bucket, server zone proximity/access, finite configured ranges; successful affected-row update prije replication. Nakon SQL yielda provjerava isti live entity/netId/plate/bucket. RequestApplyOnSpawn ne može targetirati proizvoljno udaljeno vozilo/plate. Local preview ostaje.

**Authority:** persistence stores sanitized delta; shared absolute preview payload je server-validated bounded customization intent. Public zone i mechanic access intentionally dopuštaju rad na vozilu kojim se upravlja; ne uvodi se izmišljeno owner-only pravilo koje bi uklonilo postojeći feature. Server-only ApplyOnSpawn export ostaje trusted integration API.

**Static/mock:** 7 Lua files compile; stvarni apply event plate mismatch, infinity, extreme offsets, remote zone, legitimate persist, rapid repeat throttle. Own replicated wheelFitment writer je server-side; station object je local.

**Runtime:** all car wheel baselines, delta/absolute agreement, configured maximum visual offsets, permissions/stations, reconnect, source/netId reuse, changed-owner visibility, reload and garage/server export application. Za svaki model potvrditi da postojeći numeric bounds ne dopuštaju neprihvatljiv fitment.

## zloma_vehicleshop

**Confirmed Critical/High findings:** client-created gameplay spawn bez server entity authorization sessiona; direct deliveryConfirm mogao je preskočiti assigned pickup/arrival flow; financial/event concurrency i entity target/replay; testdrive return coordinates client-authored; trade deletion bez owner/stored CAS; cancel refund exception/replay boundary.

**Changes:** explicit finite/bounded request adapter i shared mutation serialization, uključujući stopJob event. Server model/price/dealership/stock/plate iz DB/catalogue; conditional stock reservation i custom balance update. Purchases/trades issue source+identifier-bound one-use spawn ticket. Bind provjerava exact expected model/type/bucket/location/plate i owner/server-created handle prije key issuance. Testdrive allowed catalogue, server return position, original bucket restore, expiry/drop/stop entity cleanup.

Delivery worker dobiva zasebne server tow/cargo tickets i fixed bed/hook model authorization. Pickup/arrival stage traži assigned worker, role, exact bound truck/cargo, bucket, actual driver, configured pickup/delivery proximity i minimum time. Completion consumes in-memory stage prije yields. Insert/stock failure ne daje delivery reward; worker identifier se ponovno provjerava. Cancellation consumes status prije refund yields; unauthorized cancellation ne smije poništiti tuđi pickup stage. Scoped order cleanup, expired attempts i recovery nakon failed ticket-a.

**Entity path:** default zadržava client vehicle + bed/hook spawning. Novi `Config.ServerControlledVehicles=true` je **odvojen experimental lifecycle**, server vehicles/props, bounded client resolution i no client vehicle-create fallback. Local showroom/admin previews/NPCs ostaju local. Nije prisilno ponovno korišten garage Engine V2.

**Remaining Critical/High blockers:** order completion/refund/stock/ownership/reward još nisu durable idempotent transaction preko FXServer crash/restarta i svih money providers. In-memory lock/consume štiti concurrent callbacks, ne crash između side effecta i final DB statusa. Customer order multi-leg society credit/procurement debit i external provider returns zahtijevaju provjerenu compensation/journal logiku. Offline salary/refund SQL affected-row proof i provider exceptions također ostaju otvoreni. Per-source disconnect/reuse tijekom awaited sale treba staging i session identity revalidation. Optional keys selection, unknown vehicle type mapping i server object attachment/owner migration moraju biti integracijski potvrđeni.

**Startup:** jedan read-only security block čita sv_entityLockdown, sv_stateBagStrictMode, sv_filterRequestControl. Strict/relaxed + hybrid je ERROR; inactive hybrid COMPATIBILITY MODE; server-created + strict/state true/filter2 RECOMMENDED bez warninga. Optional hardening je advisory, ne fatal error. Convarovi/bucket settings se ne mijenjaju. Global check izričito ne dokazuje bucket policy.

**Static/mock:** 50 Lua files compile. Actual purchase handler failure, stock reservation conflict, refund/stock restore, successful server-price ticket and depleted-stock replay. Testdrive catalogue/return/bucket/source/replay, finite target, missing/wrong-worker delivery stages, startup matrix. **Trade, offline finance, complete positive delivery, server-native vehicle/object lifecycle nisu potpuno mock-covered.**

**Runtime / blockers:** ESX/QB/QBox direct purchase, trade-in, testdrive expiry/leave/stop, all business roles/stock/society/custom balances, customer/offline orders, full flatbed bed/hook/rope attachment sequence, delivery rewards once, DB faults, restarts at every payment/persist/status boundary, source reuse, addon/type/color/fuel/key providers and strict buckets.

## Final state-bag classification

Complete direct call-site inventory: [ProductSecurityInventory.md](ProductSecurityInventory.md), machine-readable [JSON](ProductSecurityInventory.json). Scanner excludes comments/strings, including commented-out stance setAbsoluteData.

- **S1:** 23 direct server writer sites plus 2 shared FakePlates server-only branches. Engine init markers, garage canonical VehicleProperties, fuel adapters, HUD output and stance fitment. "Server writer" describes mutation realm, not proof of safe upstream authorization.
- **S2:** 3 Core client writers: fuel and two Keys writers, all guarded non-network preview only. `replicated=false` alone would not suffice for strict mode on a network entity; the entity guard matters.
- **S3:** no direct client replicated writer remains in bundled product code. Seatbelt is an allowed request/intent handled by server, with server-local authoritative intent cache; UX labels/local previews are not permissions.
- **S4:** **zero known direct client replicated writer sites**, but **not zero client-authoritative sensitive flows**. HUD mileage relay and garage legacy props persistence remain indirect sensitive client input. A zero direct-writer count is not a completed anti-cheat objective.
- **S5:** optional external fuel/key/inventory/custom providers and customer hooks. Their implementations are not proved by this scan. Core MK network provider calls need separate current provider source review.

Do not accept state bags as proof of ownership, job, permission, paid transaction or completion. Trusted server-owned internal context/DB records are required, independently of whether global strict protection is enabled.

## Exact remaining client network gameplay creation

Line numbers in the generated inventory are authoritative for this working snapshot.

| Product | Native sites / entities | Gate / strict status |
|---|---|---|
| garages | client/main.lua:108; client/utils.lua:698; client/garages/infinitive.lua:245; client/vehicle/spawn.lua:109 and :358 | Hybrid vehicles: owned/shared/impound/duty/recovery/respawn wrappers. Config ServerSetter TRUE skips these paths; FALSE default BLOCKER |
| simplegarages | client/main.lua:112; client/utils.lua:691; client/garages/infinitive.lua:221; client/vehicle/spawn.lua:109 | Hybrid gameplay/duty vehicles; FALSE default BLOCKER |
| garages / simplegarages | client/utils.lua:199 / :247 NetworkRegisterEntityAsNetworked inside EnsureEntityNetworked | Registers a previously local entity if called; legitimate current bundled uses are hybrid spawn helpers. External use under strict is a BLOCKER; this is not an additional vehicle instance |
| vehicleshop | client/shared/security_spawn.lua:18 | Purchase/trade-in, testdrive, delivery tow truck and cargo vehicle via ticket wrapper; ServerControlledVehicles FALSE default BLOCKER |
| vehicleshop | client/business/delivery.lua:118 | Networked flatbed `inm_flatbed_base` and hook `prop_rope_hook_01` through SpawnDeliveryProp; FALSE default BLOCKER |

**No remaining bundled client-created network gameplay ped or ClonePed call detected.** Garage/impound/shop NPCs, admin/showroom vehicle previews, stash/station props and key handover prop use network flag false and are LOCAL / STRICT COMPATIBLE. Rope lifecycle uses client rope natives; no CreateObject/vehicle/ped wrapper equivalent network entity detected for the rope itself. Owner/control/attachment behavior still needs staging.

Server-created sites: full garage shared-access RPC CreateVehicle; both garage CreateVehicleServerSetter sites; shop CreateVehicleServerSetter and server CreateObject. Server creation alone does not prove canonical properties, lifecycle or permission correctness.

## Reproducible verification

Run with installed Python/Lupa Lua 5.4:

```powershell
& 'C:\Program Files\Python314\python.exe' 'D:\Github\zloma_core\tests\product_security_mock.py'
& 'C:\Program Files\Python314\python.exe' 'D:\Github\zloma_core\tests\product_security_scan.py'
& 'C:\Program Files\Python314\python.exe' 'D:\Github\zloma_garages\tests\run_serversetter.py'
& 'C:\Program Files\Python314\python.exe' 'D:\Github\zloma_simplegarages\tests\run_serversetter.py'
```

Result: **96 production-handler mock assertions + 113 full garage + 112 simple garage simulations**. **340 production Lua files compile**, code hash literals translated only outside strings/comments; SQL backticks are preserved. There are 28 writer sites and 40 entity native sites, including local/server/registration branches; these are code sites, not runtime entity counts. git diff --check prošao je svih deset repozitorija. These checks do not execute a real database/framework/provider or FiveM native.

## Multiplayer staging acceptance checklist

1. Compromised client: direct callback/event, wrong type/NaN/infinity/large payload, wrong source/ticket/identifier/job/grade/plate/model/bucket/netId, remote action, repeated request and overlapping callback.
2. Economy: no money/item/ownership/key before authorization and confirmed payment/persistence; provider returns false/throws, inventory full, DB affected=0, rollback failure; two buyers/workers, last stock, simultaneous deposit/withdraw.
3. Crash durability: disconnect/source reuse, restart before/after debit, inventory mutation, vehicle insert, stock update, reward and order final status. A durable idempotence gap is a release blocker, not merely a test to tick off.
4. Actual gameplay: all original tuning categories and original class prices; own/org/shared garages, impound, fake plates/recovery; valid keys; legitimate employees/stashes; NPC carjack/hotwire; HUD stress/mileage; full vehicleshop order/tow/bed/hook/delivery.
5. Engine V2 / shop server creation: every vehicle type/addon, driver-owned initialization, cosmetics and performance visible to another player, owner migration and driver disconnect, bounded failure cleanup, restart, frozen/colliding vehicles, bucket isolation, canonical tuning after store/retrieve.
6. Configuration: ServerSetter/hybrid matrix, state strict true/false, request filter 0/1/2/3/4, bucket-specific strict overrides, all selected external providers. Never change convars automatically as a workaround.

## Odgovori na završnih pet pitanja

1. **Jesu li svi proizvodi statički ready za sv_stateBagStrictMode true?** Bundled direct mutation paths nemaju poznati network/player client writer; API-level strict compatibility je statički potvrđena. **Bezuvjetna potvrda svih konfiguracija nije dana:** external provider S5 i sensitive relay/persistence nalazi ostaju. Strict state i server gameplay authority nisu ista provjera.
2. **Tko blokira strict entity lockdown?** Default hybrid zloma_garages, zloma_simplegarages i zloma_vehicleshop. Local previews/NPCs ostalih proizvoda nisu blockers. Server-created opt-in puts require staging; full garage shared RPC integration posebno ostaje za provjeru.
3. **Koje client network entities ostaju?** Garage hybrid gameplay/duty/recovery vehicles, simple garage hybrid gameplay/duty vehicles, shop purchase/trade/testdrive/delivery tow/cargo vehicles, flatbed bed i rope-hook objects; exact native locations above/in inventory. No bundled networked client gameplay ped remains.
4. **Koji runtime testovi ostaju?** Svi actual FXServer multiplayer/provider/DB checks gore. Ovdje nije pokrenut FXServer niti dokazana tuning/network reliability.
5. **Treba li mijenjati Engine V2?** Ovaj prolaz nije otkrio razlog za njegov redizajn. Surrounding duty/key/extras/tracked-property integration popravljen je izvan Engine V2. Shared-access RPC lifecycle treba concrete integration evidence prije eventualne migracije. Default false i EXPERIMENTAL — NOT RUNTIME TESTED ostaju.
