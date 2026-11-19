"""Run actual job/gang exports against supported export argument shapes; no FXServer."""
from pathlib import Path
from lupa.lua54 import LuaRuntime
root=Path(__file__).resolve().parents[1]
source=(root/'server/framework/init.lua').read_text(encoding='utf-8-sig')
start=source.index("exports('GetPlayerJob'")
end=source.index('-- EXPORT: GetIdentifier',start)
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
FrameworkType='ESX'
ZlomaCore={Warn=function()end,Debug=function()end}
api={};players={[1]={getJob=function()return {name='ballas',grade=2,label='Ballas'}end,
    PlayerData={job={name='police',grade={level=3}},gang={name='ballas',grade={level=2}}}}}
exports=setmetatable({zloma_core={GetPlayer=function(_,src)return players[src]end}},
    {__call=function(_,name,fn)api[name]=fn end})
function GetJobGradeValue(job)return job.grade.level end
function GetJobGradeName()return 'chief'end
function GetGangGradeValue(gang)return gang.grade.level end
""")
lua.execute(source[start:end])
lua.execute("""
local count=0
for _,args in ipairs({{1},{'1'},{{},1},{{},'1'}})do
    local job=api.GetPlayerJob(table.unpack(args));assert(job.name=='ballas' and job.grade==2);count=count+1
    assert(api.GetPlayerGang(table.unpack(args))==nil);count=count+1
end
for _,fw in ipairs({'QBCore','QBox'})do
    FrameworkType=fw
    for _,args in ipairs({{1},{'1'},{{},1},{{},'1'}})do
        local job=api.GetPlayerJob(table.unpack(args));assert(job.name=='police' and job.grade==3);count=count+1
        local gang=api.GetPlayerGang(table.unpack(args));assert(gang.name=='ballas' and gang.grade==2);count=count+1
    end
end
assert(api.GetPlayerJob(99)==nil and api.GetPlayerGang(99)==nil);count=count+2
print('Core framework org arguments: '..count..' production export checks passed; no FXServer')
""")
