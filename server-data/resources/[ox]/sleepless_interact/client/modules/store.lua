local store = {}
store.cooldownEndTime = 0

store.nearby = {}

store.coords = {}
store.coordIds = {}
store.boxes = {}   -- box zones by coord id: { coords, size, rotation }
store.boxSeq = 0

store.localEntities = {}
store.entities = {}

store.offsets = {
    localEntities = {},
    entities = {},
    models = {},
    peds = {},
    objects = {},
    vehicles = {},
    players = {},
}

store.bones = {
    localEntities = {},
    entities = {},
    models = {},
    peds = {},
    objects = {},
    vehicles = {},
    players = {},
}

store.peds = {}
store.objects = {}
store.vehicles = {}
store.players = {}
store.models = {}

store.current = {}

return store
