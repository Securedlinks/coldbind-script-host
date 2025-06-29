-- Universal Aimbot Loader
-- Made by COLDBIND Team
-- Version 1.0

print("COLDBIND: Loading Universal Aimbot...")

-- Load the main Universal Aimbot script
spawn(function()
    local success, error = pcall(function()
        loadstring(game:HttpGet("https://coldbind-script-host-k8nv.onrender.com/raw/UniAimbot/UniAimbot.lua?key=coldbind_access_2024"))()
    end)
    
    if success then
        print("COLDBIND: Universal Aimbot loaded successfully!")
    else
        warn("COLDBIND: Failed to load Universal Aimbot - " .. tostring(error))
    end
end)
