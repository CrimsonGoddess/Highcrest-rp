-- Runtime identity check (editable source; not an additional license condition).
if type(GetCurrentResourceName) == 'function' and GetCurrentResourceName() ~= 'zloma_apartments' then
    error('[zloma_apartments] Resource must be named "zloma_apartments". Rename the folder and use ensure zloma_apartments.', 0)
end

-- WiWang Hotel by Floky - https://github.com/uFLOKY/wiwang_hotel
-- 20 floors x 19 rooms. Coordinates are measured on floor 1; every floor above
-- adds floors.step to Z. Disable with Config.WiWang = false.
ApartmentPresets = ApartmentPresets or {}

local doors = {
    [1]  = { -825.87, -724.61, 41.67 }, [2]  = { -830.83, -724.50, 40.57 },
    [3]  = { -836.43, -724.52, 40.57 }, [4]  = { -842.00, -724.51, 40.57 },
    [5]  = { -839.51, -721.49, 40.57 }, [6]  = { -833.72, -721.48, 40.57 },
    [7]  = { -828.21, -721.46, 40.57 }, [8]  = { -819.93, -705.58, 40.57 },
    [9]  = { -819.90, -699.97, 40.57 }, [10] = { -819.87, -694.40, 40.57 },
    [11] = { -819.88, -688.90, 40.57 }, [12] = { -819.88, -683.26, 40.57 },
    [13] = { -816.79, -685.82, 40.57 }, [14] = { -816.71, -691.58, 40.57 },
    [15] = { -816.69, -697.06, 40.57 }, [16] = { -816.73, -702.67, 40.57 },
    [17] = { -816.71, -708.33, 40.57 }, [18] = { -816.69, -713.92, 40.57 },
    [19] = { -816.65, -719.53, 40.57 },
}

local safes = {
    [1]  = { -826.2042, -726.5109, 40.5425, 96.4466 },  [2]  = { -831.8109, -726.5930, 40.5424, 96.4466 },
    [3]  = { -837.4181, -726.4327, 40.5424, 96.4466 },  [4]  = { -843.0094, -726.5355, 40.5424, 96.4466 },
    [5]  = { -838.4626, -719.4711, 40.5424, 276.9350 }, [6]  = { -832.8165, -719.3935, 40.5424, 278.0545 },
    [7]  = { -827.1769, -719.4046, 40.5424, 278.8065 }, [8]  = { -821.9019, -704.6139, 40.5423, 7.1229 },
    [9]  = { -821.8719, -699.0039, 40.5423, 7.1229 },   [10] = { -821.8419, -693.4339, 40.5423, 7.1229 },
    [11] = { -821.8519, -687.9339, 40.5423, 7.1229 },   [12] = { -821.8519, -682.2939, 40.5423, 7.1229 },
    [13] = { -814.9025, -686.7592, 40.5423, 186.5439 }, [14] = { -814.8225, -692.5192, 40.5423, 186.5439 },
    [15] = { -814.8025, -697.9992, 40.5423, 186.5439 }, [16] = { -814.8425, -703.6092, 40.5423, 186.5439 },
    [17] = { -814.8225, -709.2692, 40.5423, 186.5439 }, [18] = { -814.8025, -714.8592, 40.5423, 186.5439 },
    [19] = { -814.7625, -720.4692, 40.5423, 186.5439 },
}

local rooms = {}
for index = 1, 19 do
    local d, s = doors[index], safes[index]
    rooms[index] = {
        index = index,
        door = { x = d[1], y = d[2], z = d[3] },
        safe = { x = s[1], y = s[2], z = s[3], w = s[4] },
    }
end

ApartmentPresets.wiwang = {
    id = 'wiwang',
    label = 'WiWang Hotel',
    imageUrl = 'https://i.imgur.com/LLmvFYq.jpeg',
    description = 'Furnished hotel rooms in Little Seoul. 20 floors, elevator in the lobby.',
    reception = { x = -823.62, y = -701.51, z = 27.06, w = 9.01 },
    receptionModel = 'a_m_m_business_01',
    receptionScenario = 'WORLD_HUMAN_CLIPBOARD',
    blip = { sprite = 475, color = 2, scale = 0.8 },
    floors = { count = 20, baseZ = 40.57, step = 3.80 },
    ipl = 'floky_wiwang_hotel_%02d_milo_',
    doorModel = -138454175,
    rooms = rooms,
    pricing = { daily = 500, contractDaily = 350, contractMinDays = 7, contractMaxDays = 30, buy = 150000 },
    enablePrepaid = true, enableContract = true, enableBuy = true,
}
