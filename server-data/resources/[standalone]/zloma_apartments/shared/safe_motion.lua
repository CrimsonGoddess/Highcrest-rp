-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- Shared reversible hinge motion; timestamps are local to each runtime.
SafeMotion={}
function SafeMotion.angle(s,now)
    if not s or not s.duration or s.duration<=0 then return s and s.target or 0 end
    local t=math.max(0,math.min(1,(now-s.started)/s.duration));t=t*t*(3-2*t)
    return s.from+(s.target-s.from)*t
end
