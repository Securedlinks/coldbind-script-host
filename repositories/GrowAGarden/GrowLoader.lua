-- GrowAGarden Loader
-- Made by COLDBIND Team
-- Version 1.0

print("COLDBIND: Loading Grow A Garden Script...")

-- Load the main Grow A Garden script
spawn(function()
    local success, error = pcall(function()
        loadstring(game:HttpGet("https://coldbind-script-host-k8nv.onrender.com/raw/GrowAGarden/Grow.lua?key=coldbind_access_2024"))()
    end)
    
    if success then
        print("COLDBIND: Grow A Garden Script loaded successfully!")
    else
        warn("COLDBIND: Failed to load Grow A Garden Script - " .. tostring(error))
    end
end)

