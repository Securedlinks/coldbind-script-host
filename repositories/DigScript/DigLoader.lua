-- DigScript Loader
-- Made by COLDBIND Team
-- Version 1.0

print("COLDBIND: Loading Dig Script...")

-- Load the main Dig script
spawn(function()
    local success, error = pcall(function()
        loadstring(game:HttpGet("https://coldbind-script-host-k8nv.onrender.com/raw/DigScript/Dig.lua?key=coldbind_access_2024"))()
    end)
    
    if success then
        print("COLDBIND: Dig Script loaded successfully!")
    else
        warn("COLDBIND: Failed to load Dig Script - " .. tostring(error))
    end
end)

