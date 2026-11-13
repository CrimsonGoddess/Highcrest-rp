-- Custom shops are saved by ef_shops_admin and pushed into ef_shops through exports. Server and
-- client both turn a saved definition into the same shape as config/locations.lua and
-- config/shop_items.lua. Custom ids start with "c_" so they never clash with config ids.

---@param id any
---@return boolean
function EF_IsCustomShop(id)
	return type(id) == 'string' and id:sub(1, 2) == 'c_'
end

---@param locations table LOCATIONS table
---@param products table PRODUCTS table
function EF_ClearCustomShops(locations, products)
	for id in pairs(locations) do
		if EF_IsCustomShop(id) then
			locations[id] = nil
			products[id] = nil
		end
	end
end

---@param def table saved shop definition
---@param locations table LOCATIONS table to write into
---@param products table PRODUCTS table to write into
function EF_ApplyCustomShop(def, locations, products)
	local coords = {}
	for i, c in ipairs(def.coords or {}) do
		coords[i] = vector4(c.x, c.y, c.z, c.w)
	end

	locations[def.id] = {
		label = def.label,
		model = def.model,
		coords = coords,
		shopItems = def.id,
		blip = def.blip,
		jobs = def.jobs,
		target = def.target,
	}
	products[def.id] = def.products
end
