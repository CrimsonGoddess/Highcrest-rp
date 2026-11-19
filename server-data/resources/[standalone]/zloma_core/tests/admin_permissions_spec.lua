local exportSource = ...
local registered, checks = {}, 0
local function check(ok,message) assert(ok,message); checks=checks+1 end
local group, broadAce, playerExists, permissions = 'user', true, true, {}
ZlomaCore={Warn=function()end,Debug=function()end}
json={encode=function()return '[]'end}
exports=setmetatable({zloma_core={GetPlayer=function()
    return playerExists and {getGroup=function()return group end} or nil
end}},{__call=function(_,name,fn)registered[name]=fn end})
function IsPlayerAceAllowed(_,permission) return permission=='command' and broadAce end
function HasPermission(_,permission) return permissions[permission]==true end
assert(load(exportSource))()
local admin=registered.IsAdmin
FrameworkType='ESX'
check(admin(1,{'admin'})==true,'legacy ESX broad ACE behavior retained')
check(admin(1,{'admin'},true)==false,'strict ESX refuses broad command ACE')
group='admin'; check(admin(1,{'admin'},true)==true,'strict ESX allows selected group')
check(admin({},1,{'admin'},true)==true,'colon-style explicit self preserves strict arguments')
group='user'; check(admin({},1,{'admin'},true)==false,'colon-style strict refuses command ACE')
check(admin({},1,{'admin'})==true,'colon-style legacy fallback retained')
group='owner'; check(admin(1,{'admin'},true)==false,'strict ESX respects exact allowlist')
for _,framework in ipairs({'QBCore','QBox'}) do
    FrameworkType=framework; permissions={god=true}
    check(admin(1,{'developer'})==true,'legacy '..framework..' god fallback retained')
    check(admin(1,{'developer'},true)==false,'strict '..framework..' blocks god and command fallbacks')
    permissions={developer=true}
    check(admin(1,{'developer'},true)==true,'strict '..framework..' selected permission allowed')
end
FrameworkType=nil; check(admin(1,{'admin'},true)==false,'unknown framework denied')
FrameworkType='ESX'; group='admin'; playerExists=false
check(admin(1,{'admin'},true)==false,'missing player denied')
print(('admin permissions: %d assertions passed'):format(checks))
