-- COLDBIND Hub
-- Made by COLDBIND Team
-- Version 1.0
-- Auto-commit test: Updated on 2025-06-25T16:44:05.199Z

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Game Detection and Auto-Execute
local gameId = game.PlaceId
local gameIds = {
    dig = 126244816328678,
    growAGarden = 126884695634066
}

local function autoExecuteScript()
    local scriptUrl = ""
    local scriptName = ""
    
    if gameId == gameIds.dig then
        scriptUrl = "https://coldbind-script-host-k8nv.onrender.com/raw/DigScript/DigLoader.lua?key=coldbind_access_2024"
        scriptName = "Dig Script"
    elseif gameId == gameIds.growAGarden then
        scriptUrl = "https://coldbind-script-host-k8nv.onrender.com/raw/GrowAGarden/GrowLoader.lua?key=coldbind_access_2024"
        scriptName = "Grow A Garden"
    else
        scriptUrl = "https://coldbind-script-host-k8nv.onrender.com/raw/UniAimbot/UniLoader.lua?key=coldbind_access_2024"
        scriptName = "Universal Aimbot"
    end
    
    print("COLDBIND Hub: Auto-loading " .. scriptName .. " for game ID: " .. tostring(gameId))
    
    spawn(function()
        pcall(function()
            loadstring(game:HttpGet(scriptUrl))()
        end)
        print("COLDBIND Hub: " .. scriptName .. " loaded successfully!")
    end)
end

-- Auto-execute the appropriate script and exit
autoExecuteScript()
