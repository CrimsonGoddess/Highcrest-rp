-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- SemVer comparison for release/beta update checks. No string-only ordering.
ApartmentVersion={}
local function parse(v)
    if type(v)~='string'then return end
    v=v:gsub('^v',''):gsub('%+[%w%.%-]+$','')
    local major,minor,patch,suffix=v:match('^(%d+)%.(%d+)%.(%d+)(.*)$')
    if not major or (suffix~='' and not suffix:match('^%-[%w%.%-]+$'))then return end
    local pre=suffix~=''and suffix:sub(2)or nil
    if pre and (pre:find('%.%.')or pre:match('^%.')or pre:match('%.$'))then return end
    return {tonumber(major),tonumber(minor),tonumber(patch),pre=pre}
end
function ApartmentVersion.compare(a,b)
    a,b=parse(a),parse(b);if not a or not b then return nil end
    for i=1,3 do if a[i]~=b[i]then return a[i]<b[i]and -1 or 1 end end
    if a.pre==b.pre then return 0 end
    if not a.pre then return 1 end
    if not b.pre then return -1 end
    local aa,bb={},{}
    for v in a.pre:gmatch('[^.]+')do aa[#aa+1]=v end
    for v in b.pre:gmatch('[^.]+')do bb[#bb+1]=v end
    for i=1,math.max(#aa,#bb)do
        local x,y=aa[i],bb[i]
        if not x then return -1 end;if not y then return 1 end
        if x~=y then
            local nx,ny=tonumber(x),tonumber(y)
            if nx and ny then return nx<ny and -1 or 1 end
            if nx then return -1 end;if ny then return 1 end
            return x<y and -1 or 1
        end
    end
    return 0
end
