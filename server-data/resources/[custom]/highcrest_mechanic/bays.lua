-- Work bays per shop. Placed and moved in-game with /jobs (job spots of kind 'bay', shared
-- through GlobalState.hcJobPoints by highcrest_jobs). If none are placed for a shop, the
-- bays list in config.lua is used instead.

local function firstShopId()
    for id in pairs(Config.shops) do return id end
end

function GetShopBays(shopId)
    local shop = Config.shops[shopId]
    if not shop then return {} end
    local list = {}
    local fallbackShop = firstShopId()
    for _, p in ipairs(GlobalState.hcJobPoints or {}) do
        if p.kind == 'bay' and p.job == Config.job and (p.shop or fallbackShop) == shopId then
            list[#list + 1] = vec4(p.coords.x, p.coords.y, p.coords.z, p.heading or 0.0)
        end
    end
    if #list == 0 then return shop.bays or { shop.bay } end
    return list
end
