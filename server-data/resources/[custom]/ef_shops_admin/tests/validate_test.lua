-- Run from the resource folder:  lua tests/validate_test.lua
-- Plain Lua, no FiveM needed. Checks the rules that keep bad shops out of ef_shops.
dofile('server/validate.lua')

local items = { burger = { label = 'Burger' }, WEAPON_PISTOL = { label = 'Pistol' }, water = { label = 'Water' } }

local function shop(overrides)
	local s = {
		id = 'c_test_shop',
		label = 'Test Shop',
		coords = { { x = 1.5, y = 2, z = 3, w = 90 } },
		models = { 'mp_m_shopkeep_01' },
		blip = { sprite = 52, color = 2, scale = 0.9 },
		target = { radius = 2 },
		products = { { name = 'burger', price = 5, defaultStock = 50, category = 'Food' } },
	}
	for k, v in pairs(overrides or {}) do s[k] = v end
	return s
end

local function accepts(input)
	local s, err = ShopValidate(input, items)
	assert(s, 'expected accept, got: ' .. tostring(err))
	return s
end

local function rejects(input, fragment)
	local s, err = ShopValidate(input, items)
	assert(not s, 'expected reject for ' .. fragment)
	assert(err and err:find(fragment, 1, true), ('wrong error %q, wanted %q'):format(tostring(err), fragment))
end

-- A clean shop passes and keeps its values.
local ok = accepts(shop())
assert(ok.products[1].defaultStock == 50 and ok.products[1].price == 5)
assert(ok.enabled == true and ok.models[1] == 'mp_m_shopkeep_01')

-- Empty job and license values must become nil: an empty table/string would lock everyone out.
local noLock = accepts(shop({ jobs = {}, products = { { name = 'burger', price = 5, jobs = {}, license = '' } } }))
assert(noLock.jobs == nil and noLock.products[1].jobs == nil and noLock.products[1].license == nil)

-- Blank stock means unlimited (nil), 0 means sold out.
assert(accepts(shop({ products = { { name = 'burger', price = 5 } } })).products[1].defaultStock == nil)
assert(accepts(shop({ products = { { name = 'burger', price = 5, defaultStock = 0 } } })).products[1].defaultStock == 0)

-- Job locks keep their grade.
local locked = accepts(shop({ jobs = { police = 2 } }))
assert(locked.jobs.police == 2)

-- Ids must be custom ids.
rejects(shop({ id = 'supermarket' }), 'Shop ID must start with c_')
rejects(shop({ id = 'c_' }), 'Shop ID must start with c_')
rejects(shop({ id = 'c_Bad Id' }), 'Shop ID must start with c_')

-- Names and locations.
rejects(shop({ label = '   ' }), 'Name is required')
rejects(shop({ coords = {} }), 'between 1 and 20 locations')
rejects(shop({ coords = { { x = 0 / 0, y = 0, z = 0, w = 0 } } }), 'Location 1 is not valid')
rejects(shop({ coords = { { x = 1, y = 1, z = 99999, w = 0 } } }), 'Location 1 is not valid')

-- Items must exist and be unique.
rejects(shop({ products = { { name = 'nope', price = 5 } } }), '"nope" is not in the item list')
rejects(shop({ products = { { name = 'burger', price = 5 }, { name = 'burger', price = 6 } } }), '"burger" is listed twice')
rejects(shop({ products = {} }), 'between 1 and 500 items')

-- Prices and stock are whole numbers in range.
rejects(shop({ products = { { name = 'burger', price = 5.5 } } }), 'Price for "burger"')
rejects(shop({ products = { { name = 'burger', price = -1 } } }), 'Price for "burger"')
rejects(shop({ products = { { name = 'burger', price = 5, defaultStock = 'lots' } } }), 'Stock for "burger"')

-- Blips: a visible blip needs a sprite, a hidden one does not.
rejects(shop({ blip = { sprite = 0, color = 2, scale = 0.9 } }), 'Blip sprite')
accepts(shop({ blip = { disabled = true, sprite = 0, color = 0, scale = 0.7 } }))

-- Jobs and metadata with bad values are refused or dropped, never saved as-is.
rejects(shop({ jobs = { ['bad job!'] = 1 } }), 'Job lock on the shop')
rejects(shop({ jobs = { police = 99 } }), 'Job lock on the shop')
local meta = accepts(shop({ products = { { name = 'burger', price = 5, metadata = { imageurl = 'x.png', nested = { a = 1 } } } } }))
assert(meta.products[1].metadata.imageurl == 'x.png' and meta.products[1].metadata.nested == nil)

-- Vendor models: names only.
rejects(shop({ models = { 'bad name' } }), 'Vendor model names')
assert(accepts(shop({ models = {} })).models == nil)

-- Bad input shape.
rejects('not a table', 'Bad shop data')

print('validate ok')
