function lerp(a, b, t)
    return a + (b - a) * t
end

function v3(data)
    return vec3(data.x, data.y, data.z), data.w
end

function GetRandomInt(min, max, exclude)
    for i = 1, 1000 do
        local rand = math.random(min, max)
        if exclude == nil or rand ~= exclude then
            return rand
        end
    end
end
