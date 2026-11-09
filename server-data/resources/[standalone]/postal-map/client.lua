-- Pause map zoom levels from the Postal Code Map release, so postal numbers stay readable.
-- The map's minimap tiles only draw at this zoom (without it the minimap is see-through), so it's kept every frame like the original.
CreateThread(function()
    while true do
        SetRadarZoom(1100)
        Wait(0)
    end
end)

CreateThread(function()
    SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
    SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)
end)
