-- Checks a shop sent from the panel. Everything the panel sends is untrusted: this is the only
-- place that decides what gets saved and pushed into ef_shops. Pure, so tests/validate_test.lua can run it.

local function text(v, max)
	if type(v) ~= 'string' then return nil end
	local s = v:match('^%s*(.-)%s*$')
	if s == '' or #s > max then return nil end
	return s
end

local function num(v, min, max, whole)
	if v == nil then return nil end
	v = tonumber(v)
	if not v or v ~= v or v < min or v > max then return nil end -- v ~= v catches NaN
	if whole and math.floor(v) ~= v then return nil end
	return v
end

-- Returns the job map (or nil when empty) and an error message when it is not valid.
local function jobMap(v, what)
	if type(v) ~= 'table' then return nil end
	local out, any = {}, false
	for job, grade in pairs(v) do
		local g = num(grade, 0, 50, true)
		if type(job) ~= 'string' or #job > 32 or not job:match('^[%w_]+$') or not g then
			return nil, ('Job lock on %s is not valid.'):format(what)
		end
		out[job] = g
		any = true
	end
	if any then return out end
	return nil
end

-- Extra item metadata: flat strings, numbers and booleans only. A bare string is kept as-is.
local function metadata(m)
	if type(m) == 'string' then return text(m, 200) end
	if type(m) ~= 'table' then return nil end
	local out, any = {}, false
	for k, v in pairs(m) do
		local t = type(v)
		if type(k) == 'string' and #k <= 32 and (t == 'string' and #v <= 200 or t == 'number' or t == 'boolean') then
			out[k] = v
			any = true
		end
	end
	if any then return out end
	return nil
end

---@param input table shop as sent by the panel
---@param items table<string, table> item catalogue (ox_inventory Items()), keyed by item name
---@return table|nil shop clean definition, or nil
---@return string|nil error message for the panel
function ShopValidate(input, items)
	if type(input) ~= 'table' then return nil, 'Bad shop data.' end

	local id = text(input.id, 40)
	if not id or #id < 5 or not id:match('^c_[a-z0-9_]+$') then
		return nil, 'Shop ID must start with c_ and use only a-z, 0-9 and _ (3 to 38 after c_).'
	end

	local label = text(input.label, 48)
	if not label then return nil, 'Name is required (up to 48 characters).' end

	if type(input.coords) ~= 'table' or #input.coords < 1 or #input.coords > 20 then
		return nil, 'Add between 1 and 20 locations.'
	end
	local coords = {}
	for i, c in ipairs(input.coords) do
		local ok = type(c) == 'table'
		local x = ok and num(c.x, -20000, 20000)
		local y = ok and num(c.y, -20000, 20000)
		local z = ok and num(c.z, -2000, 2000)
		local w = ok and num(c.w or 0, 0, 360)
		if not (x and y and z and w) then return nil, ('Location %d is not valid.'):format(i) end
		coords[i] = { x = x, y = y, z = z, w = w }
	end

	local models = {}
	if input.models ~= nil and type(input.models) ~= 'table' then return nil, 'Vendor models must be a list.' end
	for _, m in ipairs(input.models or {}) do
		local t = type(m)
		local name = (t == 'string' or t == 'number') and text(tostring(m), 64)
		if not name or not name:match('^%-?[%w_]+$') then
			return nil, 'Vendor model names may only use letters, numbers and _.'
		end
		models[#models + 1] = name
	end
	if #models > 10 then return nil, 'Up to 10 vendor models.' end

	local b = type(input.blip) == 'table' and input.blip or {}
	local disabled = b.disabled == true
	local sprite = num(b.sprite or 0, 0, 830, true) or 0
	local color = num(b.color or 0, 0, 85, true) or 0
	local scale = num(b.scale or 0.7, 0.1, 2)
	if not scale then return nil, 'Blip scale must be between 0.1 and 2.' end
	if not disabled and sprite < 1 then return nil, 'Blip sprite must be 1 to 830, or turn the blip off.' end

	local t = type(input.target) == 'table' and input.target or {}
	local radius = num(t.radius or 2, 0.5, 50)
	if not radius then return nil, 'Target radius must be between 0.5 and 50.' end

	local shopJobs, jerr = jobMap(input.jobs, 'the shop')
	if jerr then return nil, jerr end

	if type(input.products) ~= 'table' or #input.products < 1 or #input.products > 500 then
		return nil, 'Add between 1 and 500 items.'
	end
	local products, seen = {}, {}
	for i, p in ipairs(input.products) do
		local name = type(p) == 'table' and p.name
		if type(name) ~= 'string' or not items[name] then
			return nil, ('"%s" is not in the item list.'):format(tostring(name))
		end
		if seen[name] then return nil, ('"%s" is listed twice.'):format(name) end
		seen[name] = true

		local price = num(p.price, 0, 1000000, true)
		if not price then return nil, ('Price for "%s" must be a whole number from 0 to 1000000.'):format(name) end

		local stock -- blank means unlimited
		if p.defaultStock ~= nil and p.defaultStock ~= '' then
			stock = num(p.defaultStock, 0, 1000000, true)
			if not stock then return nil, ('Stock for "%s" must be blank or a whole number.'):format(name) end
		end

		local pjobs, perr = jobMap(p.jobs, name)
		if perr then return nil, perr end

		products[i] = {
			name = name,
			price = price,
			defaultStock = stock,
			category = text(p.category, 32),
			license = text(p.license, 32),
			jobs = pjobs,
			metadata = metadata(p.metadata),
		}
	end

	return {
		id = id,
		label = label,
		enabled = input.enabled ~= false,
		models = #models > 0 and models or nil,
		coords = coords,
		blip = { disabled = disabled, sprite = sprite, color = color, scale = scale },
		target = { label = text(t.label, 40), icon = text(t.icon, 40), radius = radius },
		jobs = shopJobs,
		products = products,
	}
end
