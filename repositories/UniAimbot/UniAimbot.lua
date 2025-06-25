-- Aimbot Script with Obsidian UI Library
-- Created using Exunys Aimbot Module and Obsidian Library

-- Compatibility functions
getgenv = getgenv or function() return _G end

-- Load Obsidian Library
local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Load Aimbot Module
local AimbotModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- Create the main window
local Window = Library:CreateWindow({    Title = "SNOWBIND",
                                         Footer = "Credit Exunyx and made by SNOWBIND | v1.0.0",
                                         Size = UDim2.fromOffset(750, 650),
                                         Center = true,
                                         AutoShow = true,
                                         ToggleKeybind = Enum.KeyCode.RightShift,
                                         NotifySide = "Right",
                                         ShowCustomCursor = true,
})

-- Create tabs
local Tabs = {
    Aimbot = Window:AddTab("Aimbot", "crosshair"),
    FOV = Window:AddTab("FOV Settings", "circle"),
    ESP = Window:AddTab("ESP", "eye"),
    Players = Window:AddTab("Players", "users"),
    Sweat = Window:AddTab("Sweat", "droplet"),
    Movement = Window:AddTab("Movement", "move"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Aimbot Settings Tab
local AimbotGroup = Tabs.Aimbot:AddLeftGroupbox("Aimbot Settings", "target")

AimbotGroup:AddToggle("AimbotEnabled", {
    Text = "Enable Aimbot",
    Default = AimbotModule.Settings.Enabled,
    Callback = function(Value)
        AimbotModule.Settings.Enabled = Value
        if Value then
            Library:Notify({
                Title = "Aimbot Enabled",
                Description = "Aimbot is now active",
                Time = 2,
            })
        else
            Library:Notify({
                Title = "Aimbot Disabled",
                Description = "Aimbot is now inactive",
                Time = 2,
            })
        end
    end,
})

-- Enhanced target part selection with multiple options
AimbotGroup:AddDropdown("LockPart", {
    Values = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random", "Smart", "Cycle" },
    Default = AimbotModule.Settings.LockPart,
    Text = "Lock Part",
    Tooltip = "Smart: Head for stationary, HRP for moving targets\nCycle: Cycles through parts\nRandom: Random part each lock",
    Callback = function(Value)
        AimbotModule.Settings.LockPart = Value

        -- Setup for cycling parts if that option is selected
        if Value == "Cycle" then
            if not getgenv().CycleParts then
                getgenv().CycleParts = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
                getgenv().CurrentCycleIndex = 1

                -- Create a function to cycle parts on each shot
                if not getgenv().CyclePartsFunction then
                    getgenv().CyclePartsFunction = function()
                        getgenv().CurrentCycleIndex = (getgenv().CurrentCycleIndex % #getgenv().CycleParts) + 1
                        local nextPart = getgenv().CycleParts[getgenv().CurrentCycleIndex]
                        AimbotModule.Settings.LockPart = nextPart
                        Library:Notify({
                            Title = "Part Cycled",
                            Description = "Now targeting: " .. nextPart,
                            Time = 1,
                        })
                    end
                end
            end
        end

        -- Setup for random part selection
        if Value == "Random" then
            if not getgenv().RandomPartFunction then
                getgenv().RandomParts = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso" }
                getgenv().RandomPartFunction = function()
                    local randomIndex = math.random(1, #getgenv().RandomParts)
                    local randomPart = getgenv().RandomParts[randomIndex]
                    AimbotModule.Settings.LockPart = randomPart
                    Library:Notify({
                        Title = "Random Part",
                        Description = "Now targeting: " .. randomPart,
                        Time = 1,
                    })
                end
            end
        end

        -- Setup for smart targeting
        if Value == "Smart" then
            if not getgenv().SmartTargetFunction then
                getgenv().SmartTargetFunction = function(target)
                    if target and target.Character then
                        local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
                            AimbotModule.Settings.LockPart = "HumanoidRootPart" -- Moving target, aim for center mass
                        else
                            AimbotModule.Settings.LockPart = "Head" -- Stationary target, aim for head
                        end
                    end
                end
            end
        end
    end,
})

AimbotGroup:AddDropdown("LockMode", {
    Values = { "CFrame", "mousemoverel", "Camera", "Hybrid" },
    Default = AimbotModule.Settings.LockMode == 1 and "CFrame" or "mousemoverel",
    Text = "Lock Mode",
    Tooltip = "CFrame: Instant lock (may be detected)\nMousemoverel: Mouse movement (more legit)\nCamera: Camera manipulation\nHybrid: Combines methods",
    Callback = function(Value)
        if Value == "CFrame" then
            AimbotModule.Settings.LockMode = 1
        elseif Value == "mousemoverel" then
            AimbotModule.Settings.LockMode = 2
        elseif Value == "Camera" then
            AimbotModule.Settings.LockMode = 3
            -- Add camera manipulation mode
            if not getgenv().CameraManipulation then
                getgenv().CameraManipulation = function(target, part)
                    if workspace.CurrentCamera and target and target.Character and target.Character:FindFirstChild(part) then
                        workspace.CurrentCamera.CFrame = CFrame.new(
                            workspace.CurrentCamera.CFrame.Position,
                            target.Character[part].Position
                        )
                    end
                end
            end
        elseif Value == "Hybrid" then
            AimbotModule.Settings.LockMode = 4
            -- Hybrid mode combines mousemoverel with subtle camera adjustments
            if not getgenv().HybridAiming then
                getgenv().HybridAiming = function(target, part, sensitivity)
                    if target and target.Character and target.Character:FindFirstChild(part) then
                        -- Use mousemoverel for main movement
                        local targetPos = target.Character[part].Position
                        local camera = workspace.CurrentCamera
                        local mousePos = camera:WorldToScreenPoint(targetPos)
                        local mouseX = mousePos.X - camera.ViewportSize.X/2
                        local mouseY = mousePos.Y - camera.ViewportSize.Y/2
                        mousemoverel(mouseX * sensitivity, mouseY * sensitivity)

                        -- Subtle camera adjustment
                        camera.CFrame = camera.CFrame:Lerp(
                            CFrame.new(camera.CFrame.Position, targetPos),
                            0.2 -- Subtle adjustment factor
                        )
                    end
                end
            end
        end
    end,
})

AimbotGroup:AddSlider("Sensitivity", {
    Text = "Sensitivity",
    Default = AimbotModule.Settings.Sensitivity,
    Min = 0,
    Max = 5,
    Rounding = 2,
    Callback = function(Value)
        AimbotModule.Settings.Sensitivity = Value
    end,
})

AimbotGroup:AddSlider("Sensitivity2", {
    Text = "Mouse Sensitivity",
    Default = AimbotModule.Settings.Sensitivity2,
    Min = 0.1,
    Max = 10,
    Rounding = 2,
    Callback = function(Value)
        AimbotModule.Settings.Sensitivity2 = Value
    end,
})

-- Add smoothness control for more human-like aiming
AimbotGroup:AddSlider("Smoothness", {
    Text = "Smoothness",
    Default = AimbotModule.Settings.Smoothness or 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Tooltip = "Higher = smoother but slower aiming (more human-like)",
    Callback = function(Value)
        AimbotModule.Settings.Smoothness = Value
    end,
})

-- Add aim assist strength for subtle help rather than full lock
AimbotGroup:AddSlider("AimAssistStrength", {
    Text = "Aim Assist Strength",
    Default = AimbotModule.Settings.AimAssistStrength or 1,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Tooltip = "1 = Full aimbot, lower values provide subtle aim assist",
    Callback = function(Value)
        AimbotModule.Settings.AimAssistStrength = Value
    end,
})

-- Aimbot Checks Group
local ChecksGroup = Tabs.Aimbot:AddRightGroupbox("Checks", "shield-check")

ChecksGroup:AddToggle("TeamCheck", {
    Text = "Team Check",
    Default = AimbotModule.Settings.TeamCheck,
    Callback = function(Value)
        AimbotModule.Settings.TeamCheck = Value
    end,
})

ChecksGroup:AddToggle("AliveCheck", {
    Text = "Alive Check",
    Default = AimbotModule.Settings.AliveCheck,
    Callback = function(Value)
        AimbotModule.Settings.AliveCheck = Value
    end,
})

ChecksGroup:AddToggle("WallCheck", {
    Text = "Wall Check",
    Default = AimbotModule.Settings.WallCheck,
    Callback = function(Value)
        AimbotModule.Settings.WallCheck = Value
    end,
})

-- Add visibility check (checks if target is visible on screen)
ChecksGroup:AddToggle("VisibilityCheck", {
    Text = "Visibility Check",
    Default = AimbotModule.Settings.VisibilityCheck or false,
    Tooltip = "Only target players visible on screen",
    Callback = function(Value)
        AimbotModule.Settings.VisibilityCheck = Value
    end,
})

-- Add distance check with configurable max distance
ChecksGroup:AddToggle("DistanceCheck", {
    Text = "Distance Check",
    Default = AimbotModule.Settings.DistanceCheck or false,
    Tooltip = "Only target players within specified distance",
    Callback = function(Value)
        AimbotModule.Settings.DistanceCheck = Value
    end,
})

ChecksGroup:AddSlider("MaxDistance", {
    Text = "Max Distance",
    Default = AimbotModule.Settings.MaxDistance or 1000,
    Min = 10,
    Max = 2000,
    Rounding = 0,
    Tooltip = "Maximum distance to target players",
    Callback = function(Value)
        AimbotModule.Settings.MaxDistance = Value
    end,
})

-- Add health check with configurable min health
ChecksGroup:AddToggle("HealthCheck", {
    Text = "Health Check",
    Default = AimbotModule.Settings.HealthCheck or false,
    Tooltip = "Only target players with health above threshold",
    Callback = function(Value)
        AimbotModule.Settings.HealthCheck = Value
    end,
})

ChecksGroup:AddSlider("MinHealth", {
    Text = "Min Health %",
    Default = AimbotModule.Settings.MinHealth or 0,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Tooltip = "Minimum health percentage to target players",
    Callback = function(Value)
        AimbotModule.Settings.MinHealth = Value
    end,
})

local ToggleModeToggle = ChecksGroup:AddToggle("Toggle", {
    Text = "Toggle Mode",
    Default = AimbotModule.Settings.Toggle,
    Tooltip = "Toggle to turn aimbot on/off with keybind instead of hold",
    Callback = function(Value)
        AimbotModule.Settings.Toggle = Value
    end,
})

-- Add the keybind to the toggle (proper Obsidian way)
local TriggerKeyPicker = ToggleModeToggle:AddKeyPicker("TriggerKey", {
    Default = "MB2",
    Text = "Aimbot Key",
    Mode = "Hold",
    Callback = function(Value)
        print("Aimbot key activated:", Value)
    end,
    ChangedCallback = function(New)
        -- Handle different key types properly
        if New == "MB1" then
            AimbotModule.Settings.TriggerKey = Enum.UserInputType.MouseButton1
        elseif New == "MB2" then
            AimbotModule.Settings.TriggerKey = Enum.UserInputType.MouseButton2
        else
            -- For regular keys, try to convert to KeyCode
            local success, keyCode = pcall(function()
                return Enum.KeyCode[New]
            end)
            if success and keyCode then
                AimbotModule.Settings.TriggerKey = keyCode
            else
                AimbotModule.Settings.TriggerKey = Enum.UserInputType.MouseButton2
            end
        end
        print("Aimbot key changed to:", New)
    end,
})

-- Add a secondary keybind for toggling silent aim
local SilentAimToggle = ChecksGroup:AddToggle("SilentAim", {
    Text = "Silent Aim",
    Default = AimbotModule.Settings.SilentAim or false,
    Tooltip = "Aim without moving your camera (harder to detect)",
    Callback = function(Value)
        AimbotModule.Settings.SilentAim = Value

        -- Initialize silent aim if enabled
        if Value then
            if not getgenv().SilentAimInitialized then
                getgenv().SilentAimInitialized = true

                -- Create silent aim hook function
                getgenv().SilentAimHook = function()
                    local oldNamecall
                    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                        local args = {...}
                        local method = getnamecallmethod()

                        -- Check if it's a relevant firing method
                        if (method == "FireServer" or method == "InvokeServer") and
                           (self.Name == "RemoteEvent" or self.Name:lower():find("fire") or self.Name:lower():find("shoot")) and
                           AimbotModule.Settings.SilentAim and
                           AimbotModule.Settings.Enabled then

                            -- Get closest player
                            local target = AimbotModule.GetClosestPlayer()
                            if target and target.Character then
                                local targetPart = target.Character:FindFirstChild(AimbotModule.Settings.LockPart)
                                if targetPart then
                                    -- Modify arguments to hit the target
                                    -- This is a generic implementation and may need game-specific adjustments
                                    for i, v in pairs(args) do
                                        if typeof(v) == "Vector3" then
                                            args[i] = targetPart.Position
                                        elseif typeof(v) == "CFrame" then
                                            args[i] = CFrame.new(v.Position, targetPart.Position)
                                        end
                                    end
                                end
                            end
                        end

                        return oldNamecall(self, unpack(args))
                    end)
                end

                -- Run the hook
                pcall(getgenv().SilentAimHook)
            end
        end
    end,
})

-- Advanced Targeting Group
local TargetingGroup = Tabs.Aimbot:AddLeftGroupbox("Advanced Targeting", "crosshair")

-- Target priority system
TargetingGroup:AddDropdown("TargetPriority", {
    Values = { "Closest", "Health", "Threat", "Random" },
    Default = AimbotModule.Settings.TargetPriority or "Closest",
    Text = "Target Priority",
    Tooltip = "How to prioritize targets:\nClosest: Target closest player\nHealth: Target lowest health\nThreat: Target player dealing most damage\nRandom: Target random player",
    Callback = function(Value)
        AimbotModule.Settings.TargetPriority = Value

        -- Initialize target priority system
        if not getgenv().TargetPriorityInitialized then
            getgenv().TargetPriorityInitialized = true

            -- Override GetClosestPlayer to use priority system
            local originalGetClosestPlayer = AimbotModule.GetClosestPlayer
            AimbotModule.GetClosestPlayer = function()
                local priority = AimbotModule.Settings.TargetPriority

                if priority == "Closest" then
                    -- Use original function for closest player
                    return originalGetClosestPlayer()

                elseif priority == "Health" then
                    -- Target player with lowest health
                    local lowestHealth = math.huge
                    local targetPlayer = nil

                    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                        if plr ~= game:GetService("Players").LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                            local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 and humanoid.Health < lowestHealth then
                                -- Apply all the standard checks
                                local isTeammate = AimbotModule.Settings.TeamCheck and plr.Team == game:GetService("Players").LocalPlayer.Team
                                local isBlockedByWall = false

                                if AimbotModule.Settings.WallCheck then
                                    local ray = Ray.new(
                                        game:GetService("Workspace").CurrentCamera.CFrame.Position,
                                        (plr.Character.HumanoidRootPart.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * 1000
                                    )
                                    local hit, _ = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, {game:GetService("Players").LocalPlayer.Character})
                                    isBlockedByWall = hit and hit:IsDescendantOf(plr.Character) == false
                                end

                                if not isTeammate and not isBlockedByWall then
                                    lowestHealth = humanoid.Health
                                    targetPlayer = plr
                                end
                            end
                        end
                    end

                    return targetPlayer

                elseif priority == "Threat" then
                    -- Target player who dealt most damage to you
                    -- This requires tracking damage, which we'll simulate with a threat score
                    if not getgenv().ThreatScores then
                        getgenv().ThreatScores = {}

                        -- Simulate threat by distance and facing direction
                        for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                            if plr ~= game:GetService("Players").LocalPlayer and plr.Character then
                                local distance = (plr.Character.HumanoidRootPart.Position - game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                                local facing = plr.Character.HumanoidRootPart.CFrame.LookVector:Dot((game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Unit)

                                -- Higher threat if close and facing you
                                getgenv().ThreatScores[plr.Name] = (1000 / math.max(distance, 1)) * (facing + 1)
                            end
                        end
                    end

                    -- Find highest threat player
                    local highestThreat = 0
                    local targetPlayer = nil

                    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                        if plr ~= game:GetService("Players").LocalPlayer and plr.Character and getgenv().ThreatScores[plr.Name] then
                            local threatScore = getgenv().ThreatScores[plr.Name]

                            -- Apply all the standard checks
                            local isTeammate = AimbotModule.Settings.TeamCheck and plr.Team == game:GetService("Players").LocalPlayer.Team
                            local isBlockedByWall = false

                            if AimbotModule.Settings.WallCheck then
                                local ray = Ray.new(
                                    game:GetService("Workspace").CurrentCamera.CFrame.Position,
                                    (plr.Character.HumanoidRootPart.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * 1000
                                )
                                local hit, _ = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, {game:GetService("Players").LocalPlayer.Character})
                                isBlockedByWall = hit and hit:IsDescendantOf(plr.Character) == false
                            end

                            if not isTeammate and not isBlockedByWall and threatScore > highestThreat then
                                highestThreat = threatScore
                                targetPlayer = plr
                            end
                        end
                    end

                    return targetPlayer

                elseif priority == "Random" then
                    -- Target random player
                    local validTargets = {}

                    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                        if plr ~= game:GetService("Players").LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
                            -- Apply all the standard checks
                            local isTeammate = AimbotModule.Settings.TeamCheck and plr.Team == game:GetService("Players").LocalPlayer.Team
                            local isBlockedByWall = false

                            if AimbotModule.Settings.WallCheck then
                                local ray = Ray.new(
                                    game:GetService("Workspace").CurrentCamera.CFrame.Position,
                                    (plr.Character.HumanoidRootPart.Position - game:GetService("Workspace").CurrentCamera.CFrame.Position).Unit * 1000
                                )
                                local hit, _ = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, {game:GetService("Players").LocalPlayer.Character})
                                isBlockedByWall = hit and hit:IsDescendantOf(plr.Character) == false
                            end

                            if not isTeammate and not isBlockedByWall then
                                table.insert(validTargets, plr)
                            end
                        end
                    end

                    if #validTargets > 0 then
                        return validTargets[math.random(1, #validTargets)]
                    end
                end

                -- Fallback to original function
                return originalGetClosestPlayer()
            end
        end
    end,
})

-- Target switching settings
TargetingGroup:AddToggle("AutoSwitch", {
    Text = "Auto Switch Target",
    Default = AimbotModule.Settings.AutoSwitch or false,
    Tooltip = "Automatically switch to better targets",
    Callback = function(Value)
        AimbotModule.Settings.AutoSwitch = Value
    end,
})

TargetingGroup:AddSlider("SwitchDelay", {
    Text = "Switch Delay (ms)",
    Default = AimbotModule.Settings.SwitchDelay or 500,
    Min = 0,
    Max = 2000,
    Rounding = 0,
    Tooltip = "Delay between target switches",
    Callback = function(Value)
        AimbotModule.Settings.SwitchDelay = Value
    end,
})

-- Enhanced Prediction Settings
local PredictionGroup = Tabs.Aimbot:AddRightGroupbox("Prediction Settings", "move")

PredictionGroup:AddToggle("EnablePrediction", {
    Text = "Enable Prediction",
    Default = AimbotModule.Settings.OffsetToMoveDirection,
    Tooltip = "Predict player movement",
    Callback = function(Value)
        AimbotModule.Settings.OffsetToMoveDirection = Value
    end,
})

PredictionGroup:AddDropdown("PredictionMethod", {
    Values = { "Basic", "Velocity", "Advanced", "Adaptive" },
    Default = AimbotModule.Settings.PredictionMethod or "Basic",
    Text = "Prediction Method",
    Tooltip = "Basic: Simple direction prediction\nVelocity: Uses velocity for prediction\nAdvanced: Accounts for acceleration\nAdaptive: Learns player movement patterns",
    Callback = function(Value)
        AimbotModule.Settings.PredictionMethod = Value

        -- Initialize prediction system
        if not getgenv().PredictionInitialized then
            getgenv().PredictionInitialized = true

            -- Store previous positions for velocity calculation
            getgenv().PreviousPositions = {}
            getgenv().PreviousVelocities = {}

            -- Update positions and velocities
            game:GetService("RunService").Heartbeat:Connect(function()
                for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                    if plr ~= game:GetService("Players").LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local currentPos = plr.Character.HumanoidRootPart.Position

                        if not getgenv().PreviousPositions[plr.Name] then
                            getgenv().PreviousPositions[plr.Name] = currentPos
                            getgenv().PreviousVelocities[plr.Name] = Vector3.new(0, 0, 0)
                        else
                            local previousPos = getgenv().PreviousPositions[plr.Name]
                            local velocity = (currentPos - previousPos) / game:GetService("RunService").Heartbeat:Wait()

                            -- Store previous velocity for acceleration calculation
                            local previousVelocity = getgenv().PreviousVelocities[plr.Name]
                            getgenv().PreviousVelocities[plr.Name] = velocity

                            -- Update position
                            getgenv().PreviousPositions[plr.Name] = currentPos

                            -- Store acceleration
                            if not getgenv().Accelerations then getgenv().Accelerations = {} end
                            getgenv().Accelerations[plr.Name] = (velocity - previousVelocity) / game:GetService("RunService").Heartbeat:Wait()

                            -- For adaptive prediction, store movement patterns
                            if AimbotModule.Settings.PredictionMethod == "Adaptive" then
                                if not getgenv().MovementPatterns then getgenv().MovementPatterns = {} end
                                if not getgenv().MovementPatterns[plr.Name] then getgenv().MovementPatterns[plr.Name] = {} end

                                table.insert(getgenv().MovementPatterns[plr.Name], velocity)
                                if #getgenv().MovementPatterns[plr.Name] > 30 then -- Store last 30 velocity samples
                                    table.remove(getgenv().MovementPatterns[plr.Name], 1)
                                end
                            end
                        end
                    end
                end
            end)

            -- Override the prediction function
            getgenv().GetPredictedPosition = function(player, part)
                if not player or not player.Character or not player.Character:FindFirstChild(part) then
                    return nil
                end

                local targetPart = player.Character[part]
                local currentPos = targetPart.Position
                local method = AimbotModule.Settings.PredictionMethod

                if method == "Basic" then
                    -- Basic prediction using move direction
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        return currentPos + (humanoid.MoveDirection * AimbotModule.Settings.OffsetIncrement)
                    end

                elseif method == "Velocity" then
                    -- Velocity-based prediction
                    if getgenv().PreviousVelocities[player.Name] then
                        local velocity = getgenv().PreviousVelocities[player.Name]
                        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
                        return currentPos + (velocity * ping * AimbotModule.Settings.OffsetIncrement / 10)
                    end

                elseif method == "Advanced" then
                    -- Advanced prediction with acceleration
                    if getgenv().PreviousVelocities[player.Name] and getgenv().Accelerations[player.Name] then
                        local velocity = getgenv().PreviousVelocities[player.Name]
                        local acceleration = getgenv().Accelerations[player.Name]
                        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000

                        -- Physics formula: position = initial_position + velocity*time + 0.5*acceleration*time^2
                        return currentPos + (velocity * ping) + (0.5 * acceleration * ping * ping) * (AimbotModule.Settings.OffsetIncrement / 10)
                    end

                elseif method == "Adaptive" then
                    -- Adaptive prediction based on movement patterns
                    if getgenv().MovementPatterns and getgenv().MovementPatterns[player.Name] and #getgenv().MovementPatterns[player.Name] > 5 then
                        local patterns = getgenv().MovementPatterns[player.Name]
                        local predictedVelocity = Vector3.new(0, 0, 0)

                        -- Calculate weighted average of recent velocities
                        local totalWeight = 0
                        for i = 1, #patterns do
                            local weight = i / #patterns -- More recent velocities have higher weight
                            predictedVelocity = predictedVelocity + (patterns[i] * weight)
                            totalWeight = totalWeight + weight
                        end

                        predictedVelocity = predictedVelocity / totalWeight
                        local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000

                        return currentPos + (predictedVelocity * ping * AimbotModule.Settings.OffsetIncrement / 10)
                    end
                end

                -- Fallback to current position
                return currentPos
            end
        end
    end,
})

PredictionGroup:AddSlider("PredictionStrength", {
    Text = "Prediction Strength",
    Default = AimbotModule.Settings.OffsetIncrement,
    Min = 1,
    Max = 30,
    Rounding = 1,
    Callback = function(Value)
        AimbotModule.Settings.OffsetIncrement = Value
    end,
})

-- Add ping compensation
PredictionGroup:AddToggle("PingCompensation", {
    Text = "Ping Compensation",
    Default = AimbotModule.Settings.PingCompensation or false,
    Tooltip = "Adjust prediction based on your ping",
    Callback = function(Value)
        AimbotModule.Settings.PingCompensation = Value
    end,
})

-- Add silent aim feature
local SilentAimGroup = Tabs.Aimbot:AddRightGroupbox("Silent Aim", "eye-off")

SilentAimGroup:AddToggle("SilentAimEnabled", {
    Text = "Enable Silent Aim",
    Default = AimbotModule.Settings.SilentAim or false,
    Tooltip = "Aim without moving your camera (harder to detect)",
    Callback = function(Value)
        AimbotModule.Settings.SilentAim = Value

        -- Initialize silent aim if enabled
        if Value and not getgenv().SilentAimInitialized then
            getgenv().SilentAimInitialized = true

            -- Create silent aim hook function
            getgenv().SilentAimHook = function()
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    local args = {...}
                    local method = getnamecallmethod()

                    -- Check if it's a relevant firing method
                    if (method == "FireServer" or method == "InvokeServer") and
                       (self.Name == "RemoteEvent" or self.Name:lower():find("fire") or self.Name:lower():find("shoot")) and
                       AimbotModule.Settings.SilentAim and
                       AimbotModule.Settings.Enabled then

                        -- Get closest player
                        local target = AimbotModule.GetClosestPlayer()
                        if target and target.Character then
                            local targetPart = target.Character:FindFirstChild(AimbotModule.Settings.LockPart)
                            if targetPart then
                                -- Modify arguments to hit the target
                                -- This is a generic implementation and may need game-specific adjustments
                                for i, v in pairs(args) do
                                    if typeof(v) == "Vector3" then
                                        args[i] = targetPart.Position
                                    elseif typeof(v) == "CFrame" then
                                        args[i] = CFrame.new(v.Position, targetPart.Position)
                                    end
                                end
                            end
                        end
                    end

                    return oldNamecall(self, unpack(args))
                end)
            end

            -- Run the hook
            pcall(getgenv().SilentAimHook)
        end
    end,
})

SilentAimGroup:AddSlider("SilentAimFOV", {
    Text = "Silent Aim FOV",
    Default = AimbotModule.Settings.SilentAimFOV or 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Tooltip = "Field of view for silent aim",
    Callback = function(Value)
        AimbotModule.Settings.SilentAimFOV = Value
    end,
})

SilentAimGroup:AddToggle("SilentAimVisibleCheck", {
    Text = "Visible Check",
    Default = AimbotModule.Settings.SilentAimVisibleCheck or true,
    Tooltip = "Only target visible players",
    Callback = function(Value)
        AimbotModule.Settings.SilentAimVisibleCheck = Value
    end,
})

SilentAimGroup:AddSlider("SilentAimHitChance", {
    Text = "Hit Chance (%)",
    Default = AimbotModule.Settings.SilentAimHitChance or 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Tooltip = "Chance to hit the target (lower = more legit)",
    Callback = function(Value)
        AimbotModule.Settings.SilentAimHitChance = Value
    end,
})

-- Add anti-detection features
local AntiDetectionGroup = Tabs.Aimbot:AddLeftGroupbox("Anti-Detection", "shield")

AntiDetectionGroup:AddToggle("RandomizeAim", {
    Text = "Randomize Aim",
    Default = AimbotModule.Settings.RandomizeAim or false,
    Tooltip = "Add slight randomness to aim for human-like behavior",
    Callback = function(Value)
        AimbotModule.Settings.RandomizeAim = Value
    end,
})

AntiDetectionGroup:AddSlider("RandomizationAmount", {
    Text = "Randomization",
    Default = AimbotModule.Settings.RandomizationAmount or 5,
    Min = 0,
    Max = 20,
    Rounding = 1,
    Tooltip = "Amount of randomization to add",
    Callback = function(Value)
        AimbotModule.Settings.RandomizationAmount = Value
    end,
})

AntiDetectionGroup:AddToggle("HumanizeAim", {
    Text = "Humanize Aim",
    Default = AimbotModule.Settings.HumanizeAim or false,
    Tooltip = "Simulate human aiming patterns",
    Callback = function(Value)
        AimbotModule.Settings.HumanizeAim = Value

        -- Initialize humanization system
        if Value and not getgenv().HumanizationInitialized then
            getgenv().HumanizationInitialized = true

            -- Create humanization function
            getgenv().HumanizeAimPosition = function(targetPosition)
                if not AimbotModule.Settings.HumanizeAim then
                    return targetPosition
                end

                -- Add slight curve to aim path
                local camera = game:GetService("Workspace").CurrentCamera
                local cameraPos = camera.CFrame.Position
                local aimDir = (targetPosition - cameraPos).Unit

                -- Create a slight curve by adding perpendicular vector
                local upVector = Vector3.new(0, 1, 0)
                local rightVector = aimDir:Cross(upVector).Unit
                local upwardVector = rightVector:Cross(aimDir).Unit

                -- Oscillate the aim with a sine wave
                local time = tick() % (math.pi * 2)
                local curveX = math.sin(time * 2) * AimbotModule.Settings.RandomizationAmount * 0.1
                local curveY = math.cos(time * 2) * AimbotModule.Settings.RandomizationAmount * 0.1

                -- Apply the curve
                local curvedPosition = targetPosition + (rightVector * curveX) + (upwardVector * curveY)

                return curvedPosition
            end
        end
    end,
})

AntiDetectionGroup:AddToggle("DelayedAim", {
    Text = "Delayed Aim",
    Default = AimbotModule.Settings.DelayedAim or false,
    Tooltip = "Add reaction time delay before aiming",
    Callback = function(Value)
        AimbotModule.Settings.DelayedAim = Value
    end,
})

AntiDetectionGroup:AddSlider("ReactionTime", {
    Text = "Reaction Time (ms)",
    Default = AimbotModule.Settings.ReactionTime or 150,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Tooltip = "Simulated human reaction time",
    Callback = function(Value)
        AimbotModule.Settings.ReactionTime = Value
    end,
})

-- FOV Settings Tab
local FOVGroup = Tabs.FOV:AddLeftGroupbox("FOV Circle", "circle")

FOVGroup:AddToggle("FOVEnabled", {
    Text = "Enable FOV Circle",
    Default = AimbotModule.FOVSettings.Enabled,
    Callback = function(Value)
        AimbotModule.FOVSettings.Enabled = Value
    end,
})

FOVGroup:AddToggle("FOVVisible", {
    Text = "Visible",
    Default = AimbotModule.FOVSettings.Visible,
    Callback = function(Value)
        AimbotModule.FOVSettings.Visible = Value
    end,
})

FOVGroup:AddSlider("FOVRadius", {
    Text = "Radius",
    Default = AimbotModule.FOVSettings.Radius,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value)
        AimbotModule.FOVSettings.Radius = Value
    end,
})

FOVGroup:AddSlider("FOVThickness", {
    Text = "Thickness",
    Default = AimbotModule.FOVSettings.Thickness,
    Min = 1,
    Max = 10,
    Rounding = 0,
    Callback = function(Value)
        AimbotModule.FOVSettings.Thickness = Value
    end,
})

FOVGroup:AddSlider("FOVSides", {
    Text = "Number of Sides",
    Default = AimbotModule.FOVSettings.NumSides,
    Min = 3,
    Max = 100,
    Rounding = 0,
    Callback = function(Value)
        AimbotModule.FOVSettings.NumSides = Value
    end,
})

FOVGroup:AddToggle("FOVFilled", {
    Text = "Filled",
    Default = AimbotModule.FOVSettings.Filled,
    Callback = function(Value)
        AimbotModule.FOVSettings.Filled = Value
    end,
})

-- FOV Colors Group
local FOVColorsGroup = Tabs.FOV:AddRightGroupbox("FOV Colors", "palette")

local RainbowColorToggle = FOVColorsGroup:AddToggle("RainbowColor", {
    Text = "Rainbow Color",
    Default = AimbotModule.FOVSettings.RainbowColor,
    Callback = function(Value)
        AimbotModule.FOVSettings.RainbowColor = Value
    end,
})

local RainbowOutlineToggle = FOVColorsGroup:AddToggle("RainbowOutline", {
    Text = "Rainbow Outline",
    Default = AimbotModule.FOVSettings.RainbowOutlineColor,
    Callback = function(Value)
        AimbotModule.FOVSettings.RainbowOutlineColor = Value
    end,
})

-- Add color pickers to toggles for better organization
RainbowColorToggle:AddColorPicker("FOVColor", {
    Default = AimbotModule.FOVSettings.Color,
    Title = "FOV Circle Color",
    Callback = function(Value)
        AimbotModule.FOVSettings.Color = Value
    end,
})

RainbowOutlineToggle:AddColorPicker("OutlineColor", {
    Default = AimbotModule.FOVSettings.OutlineColor,
    Title = "FOV Outline Color",
    Callback = function(Value)
        AimbotModule.FOVSettings.OutlineColor = Value
    end,
})

-- Separate toggle for locked color
local LockedColorToggle = FOVColorsGroup:AddToggle("ShowLockedColor", {
    Text = "Custom Locked Color",
    Default = false,
    Tooltip = "Use custom color when target is locked",
    Callback = function(Value)
        -- This can be used to enable/disable custom locked color
    end,
})

LockedColorToggle:AddColorPicker("LockedColor", {
    Default = AimbotModule.FOVSettings.LockedColor,
    Title = "FOV Locked Color",
    Callback = function(Value)
        AimbotModule.FOVSettings.LockedColor = Value
    end,
})

FOVColorsGroup:AddSlider("FOVTransparency", {
    Text = "Transparency",
    Default = AimbotModule.FOVSettings.Transparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        AimbotModule.FOVSettings.Transparency = Value
    end,
})

-- ESP Settings Tab
local ESPSettings = {
    Enabled = false,
    Box_Color = Color3.fromRGB(255, 0, 0),
    Tracer_Color = Color3.fromRGB(255, 0, 0),
    Skeleton_Color = Color3.fromRGB(255, 255, 255),
    Tracer_Thickness = 1,
    Box_Thickness = 1,
    Skeleton_Thickness = 1,
    Tracer_Origin = "Bottom", -- Middle or Bottom
    Tracer_FollowMouse = false,
    Tracers = true,
    Boxes = true,
    HealthBars = true,
    Skeletons = true,
    TeamCheck = false,
    TeamColor = true,
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0),

    -- Off-screen indicator settings (Made by Blissful#4992)
    OffScreenArrows = false,
    OffScreenArrowColor = Color3.fromRGB(255, 255, 255),
    OffScreenArrowSize = 16,
    OffScreenArrowRadius = 80,
    OffScreenArrowFilled = true,
    OffScreenArrowTransparency = 0,
    OffScreenArrowThickness = 1,
    OffScreenArrowAntiAliasing = false,

    -- Radar settings (Made by Blissful#4992)
    Radar = false,
    RadarPosition = Vector2.new(200, 200),
    RadarRadius = 100,
    RadarScale = 1,
    RadarBack = Color3.fromRGB(10, 10, 10),
    RadarBorder = Color3.fromRGB(75, 75, 75),
    RadarLocalPlayerDot = Color3.fromRGB(255, 255, 255),
    RadarPlayerDot = Color3.fromRGB(60, 170, 255),
    RadarHealthColor = true
}

local ESPObjects = {}
local SkeletonESPObjects = {}
local OffScreenArrowObjects = {} -- Track off-screen arrow objects
local RadarObjects = {} -- Track radar objects
local ESPConnections = {} -- Track all ESP connections for cleanup
local SkeletonESPConnections = {} -- Track all Skeleton ESP connections for cleanup
local OffScreenArrowConnections = {} -- Track off-screen arrow connections for cleanup
local RadarConnections = {} -- Track radar connections for cleanup
local PlayerAddedConnection = nil -- Track PlayerAdded connection for cleanup
local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local mouse = player:GetMouse()

-- Check if Drawing API is available
local DrawingAvailable = false
local DrawingLib = getgenv().Drawing or _G.Drawing or nil

if DrawingLib then
    local success = pcall(function()
        local test = DrawingLib.new("Line")
        if test and test.Remove then
            test:Remove()
            DrawingAvailable = true
        end
    end)
    if not success then
        DrawingAvailable = false
    end
end

local function NewQuad(thickness, color)
    if not DrawingAvailable or not DrawingLib then
        return {
            Visible = false,
            PointA = Vector2.new(0,0),
            PointB = Vector2.new(0,0),
            PointC = Vector2.new(0,0),
            PointD = Vector2.new(0,0),
            Color = color,
            Thickness = thickness
        }
    end

    local quad = DrawingLib.new("Quad")
    quad.Visible = false
    quad.PointA = Vector2.new(0,0)
    quad.PointB = Vector2.new(0,0)
    quad.PointC = Vector2.new(0,0)
    quad.PointD = Vector2.new(0,0)
    quad.Color = color
    quad.Filled = false
    quad.Thickness = thickness
    quad.Transparency = 1
    return quad
end

local function NewLine(thickness, color)
    if not DrawingAvailable or not DrawingLib then
        return {
            Visible = false,
            From = Vector2.new(0, 0),
            To = Vector2.new(0, 0),
            Color = color,
            Thickness = thickness
        }
    end

    local line = DrawingLib.new("Line")
    line.Visible = false
    line.From = Vector2.new(0, 0)
    line.To = Vector2.new(0, 0)
    line.Color = color
    line.Thickness = thickness
    line.Transparency = 1
    return line
end

local function Visibility(state, lib)
    if not DrawingAvailable then return end
    for u, x in pairs(lib) do
        if x and x.Visible ~= nil then
            x.Visible = state
        end
    end
end

-- Helper functions for off-screen arrows (Made by Blissful#4992)
local function GetRelative(pos, char)
    if not char then return Vector2.new(0,0) end

    local rootP = char.PrimaryPart.Position
    local camP = camera.CFrame.Position
    local relative = CFrame.new(Vector3.new(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)

    return Vector2.new(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return camera.ViewportSize/2 - v
end

local function RotateVect(v, a)
    a = math.rad(a)
    local x = v.x * math.cos(a) - v.y * math.sin(a)
    local y = v.x * math.sin(a) + v.y * math.cos(a)

    return Vector2.new(x, y)
end

local function DrawTriangle(color)
    if not DrawingAvailable then return {Visible = false, Remove = function() end} end

    local l = Drawing.new("Triangle")
    l.Visible = false
    l.Color = color
    l.Filled = ESPSettings.OffScreenArrowFilled
    l.Thickness = ESPSettings.OffScreenArrowThickness
    l.Transparency = 1-ESPSettings.OffScreenArrowTransparency
    return l
end

local function AntiA(v)
    if (not ESPSettings.OffScreenArrowAntiAliasing) then return v end
    return Vector2.new(math.round(v.x), math.round(v.y))
end

local black = Color3.fromRGB(0, 0, 0)

local function ESP(plr)
    if not DrawingAvailable then return end

    local library = {
        blacktracer = NewLine(ESPSettings.Tracer_Thickness*2, black),
        tracer = NewLine(ESPSettings.Tracer_Thickness, ESPSettings.Tracer_Color),
        black = NewQuad(ESPSettings.Box_Thickness*2, black),
        box = NewQuad(ESPSettings.Box_Thickness, ESPSettings.Box_Color),
        healthbar = NewLine(3, black),
        greenhealth = NewLine(1.5, black)
    }

    ESPObjects[plr.Name] = library

    local function Colorize(color)
        for u, x in pairs(library) do
            if x and x.Color and x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black then
                x.Color = color
            end
        end
    end

    local function Updater()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not ESPSettings.Enabled then
                Visibility(false, library)
                return
            end

            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("Head") ~= nil then
                local HumPos, OnScreen = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if OnScreen then
                    local head = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(HumPos.X, HumPos.Y)).magnitude, 2, math.huge)

                    -- Boxes
                    if ESPSettings.Boxes and library.box.PointA then
                        local function Size(item)
                            if item.PointA then
                                item.PointA = Vector2.new(HumPos.X + DistanceY, HumPos.Y - DistanceY*2)
                                item.PointB = Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2)
                                item.PointC = Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)
                                item.PointD = Vector2.new(HumPos.X + DistanceY, HumPos.Y + DistanceY*2)
                            end
                        end
                        Size(library.box)
                        Size(library.black)
                        if library.box.Visible ~= nil then
                            library.box.Visible = true
                            library.black.Visible = true
                        end
                    else
                        if library.box.Visible ~= nil then
                            library.box.Visible = false
                            library.black.Visible = false
                        end
                    end

                    -- Tracers
                    if ESPSettings.Tracers and library.tracer.From then
                        if ESPSettings.Tracer_Origin == "Middle" then
                            library.tracer.From = camera.ViewportSize*0.5
                            library.blacktracer.From = camera.ViewportSize*0.5
                        elseif ESPSettings.Tracer_Origin == "Bottom" then
                            library.tracer.From = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y)
                            library.blacktracer.From = Vector2.new(camera.ViewportSize.X*0.5, camera.ViewportSize.Y)
                        end
                        if ESPSettings.Tracer_FollowMouse then
                            library.tracer.From = Vector2.new(mouse.X, mouse.Y+36)
                            library.blacktracer.From = Vector2.new(mouse.X, mouse.Y+36)
                        end
                        library.tracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                        library.blacktracer.To = Vector2.new(HumPos.X, HumPos.Y + DistanceY*2)
                        if library.tracer.Visible ~= nil then
                            library.tracer.Visible = true
                            library.blacktracer.Visible = true
                        end
                    else
                        if library.tracer.Visible ~= nil then
                            library.tracer.Visible = false
                            library.blacktracer.Visible = false
                        end
                    end

                    -- Health Bar
                    if ESPSettings.HealthBars and library.healthbar.From then
                        local d = (Vector2.new(HumPos.X - DistanceY, HumPos.Y - DistanceY*2) - Vector2.new(HumPos.X - DistanceY, HumPos.Y + DistanceY*2)).magnitude
                        local healthoffset = plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth * d

                        library.greenhealth.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                        library.greenhealth.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2 - healthoffset)

                        library.healthbar.From = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y + DistanceY*2)
                        library.healthbar.To = Vector2.new(HumPos.X - DistanceY - 4, HumPos.Y - DistanceY*2)

                        local green = Color3.fromRGB(0, 255, 0)
                        local red = Color3.fromRGB(255, 0, 0)

                        if library.greenhealth.Color then
                            library.greenhealth.Color = red:lerp(green, plr.Character.Humanoid.Health/plr.Character.Humanoid.MaxHealth)
                        end
                        if library.healthbar.Visible ~= nil then
                            library.healthbar.Visible = true
                            library.greenhealth.Visible = true
                        end
                    else
                        if library.healthbar.Visible ~= nil then
                            library.healthbar.Visible = false
                            library.greenhealth.Visible = false
                        end
                    end

                    -- Team Check and Colors
                    if ESPSettings.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            Colorize(ESPSettings.Green)
                        else
                            Colorize(ESPSettings.Red)
                        end
                    else
                        if library.tracer.Color then
                            library.tracer.Color = ESPSettings.Tracer_Color
                        end
                        if library.box.Color then
                            library.box.Color = ESPSettings.Box_Color
                        end
                    end

                    if ESPSettings.TeamColor then
                        Colorize(plr.TeamColor.Color)
                    end
                else
                    Visibility(false, library)
                end
            else
                Visibility(false, library)                if game.Players:FindFirstChild(plr.Name) == nil then
                connection:Disconnect()
                -- Remove from ESPConnections tracking
                if ESPConnections[plr.Name] then
                    ESPConnections[plr.Name] = nil
                end
                if ESPObjects[plr.Name] then
                    for _, obj in pairs(ESPObjects[plr.Name]) do
                        if obj and obj.Remove then
                            obj:Remove()
                        end
                    end
                    ESPObjects[plr.Name] = nil
                end
            end
            end
        end)
        -- Store connection for cleanup
        ESPConnections[plr.Name] = connection
    end
    coroutine.wrap(Updater)()
end

-- Skeleton ESP Functions
local SkeletonESPObjects = {}

local function DrawSkeletonLine()
    if not DrawingAvailable or not DrawingLib then
        return {
            Visible = false,
            From = Vector2.new(0, 0),
            To = Vector2.new(0, 0),
            Color = ESPSettings.Skeleton_Color,
            Thickness = ESPSettings.Skeleton_Thickness
        }
    end

    local l = DrawingLib.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = ESPSettings.Skeleton_Color
    l.Thickness = ESPSettings.Skeleton_Thickness
    l.Transparency = 1
    return l
end

-- Off-screen arrows function (Made by Blissful#4992)
local function DrawOffScreenArrows(plr)
    if not DrawingAvailable then return end

    local Arrow = DrawTriangle(ESPSettings.OffScreenArrowColor)
    OffScreenArrowObjects[plr.Name] = Arrow

    local function Update()
        local connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not plr or not plr.Parent then
                if Arrow and Arrow.Remove then
                    pcall(function() Arrow:Remove() end)
                end
                OffScreenArrowObjects[plr.Name] = nil
                if OffScreenArrowConnections[plr.Name] then
                    OffScreenArrowConnections[plr.Name]:Disconnect()
                    OffScreenArrowConnections[plr.Name] = nil
                end
                return
            end

            if not ESPSettings.Enabled or not ESPSettings.OffScreenArrows then
                Arrow.Visible = false
                return
            end

            if plr and plr.Character then
                local CHAR = plr.Character
                local HUM = CHAR:FindFirstChildOfClass("Humanoid")

                if HUM and CHAR.PrimaryPart ~= nil and HUM.Health > 0 then
                    local _, vis = camera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                    if vis == false then
                        local rel = GetRelative(CHAR.PrimaryPart.Position, player.Character)
                        local direction = rel.Unit

                        local base = direction * ESPSettings.OffScreenArrowRadius
                        local sideLength = ESPSettings.OffScreenArrowSize/2
                        local baseL = base + RotateVect(direction, 90) * sideLength
                        local baseR = base + RotateVect(direction, -90) * sideLength

                        local tip = direction * (ESPSettings.OffScreenArrowRadius + ESPSettings.OffScreenArrowSize)

                        Arrow.PointA = AntiA(RelativeToCenter(baseL))
                        Arrow.PointB = AntiA(RelativeToCenter(baseR))
                        Arrow.PointC = AntiA(RelativeToCenter(tip))

                        -- Apply team color if enabled
                        if ESPSettings.TeamCheck then
                            if plr.Team == player.Team then
                                Arrow.Color = ESPSettings.Green
                            else
                                Arrow.Color = ESPSettings.Red
                            end
                        elseif ESPSettings.TeamColor and plr.Team and plr.Team.TeamColor then
                            Arrow.Color = plr.Team.TeamColor.Color
                        else
                            Arrow.Color = ESPSettings.OffScreenArrowColor
                        end

                        Arrow.Visible = true
                    else
                        Arrow.Visible = false
                    end
                else
                    Arrow.Visible = false
                end
            else
                Arrow.Visible = false
            end
        end)

        OffScreenArrowConnections[plr.Name] = connection
    end

    coroutine.wrap(Update)()
end

local function DrawSkeletonESP(plr)
    if not DrawingAvailable then return end

    repeat task.wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local limbs = {}
    local R15 = (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false

    if R15 then
        limbs = {
            -- Spine
            Head_UpperTorso = DrawSkeletonLine(),
            UpperTorso_LowerTorso = DrawSkeletonLine(),
            -- Left Arm
            UpperTorso_LeftUpperArm = DrawSkeletonLine(),
            LeftUpperArm_LeftLowerArm = DrawSkeletonLine(),
            LeftLowerArm_LeftHand = DrawSkeletonLine(),
            -- Right Arm
            UpperTorso_RightUpperArm = DrawSkeletonLine(),
            RightUpperArm_RightLowerArm = DrawSkeletonLine(),
            RightLowerArm_RightHand = DrawSkeletonLine(),
            -- Left Leg
            LowerTorso_LeftUpperLeg = DrawSkeletonLine(),
            LeftUpperLeg_LeftLowerLeg = DrawSkeletonLine(),
            LeftLowerLeg_LeftFoot = DrawSkeletonLine(),
            -- Right Leg
            LowerTorso_RightUpperLeg = DrawSkeletonLine(),
            RightUpperLeg_RightLowerLeg = DrawSkeletonLine(),
            RightLowerLeg_RightFoot = DrawSkeletonLine(),
        }
    else
        limbs = {
            Head_Spine = DrawSkeletonLine(),
            Spine = DrawSkeletonLine(),
            LeftArm = DrawSkeletonLine(),
            LeftArm_UpperTorso = DrawSkeletonLine(),
            RightArm = DrawSkeletonLine(),
            RightArm_UpperTorso = DrawSkeletonLine(),
            LeftLeg = DrawSkeletonLine(),
            LeftLeg_LowerTorso = DrawSkeletonLine(),
            RightLeg = DrawSkeletonLine(),
            RightLeg_LowerTorso = DrawSkeletonLine()
        }
    end

    SkeletonESPObjects[plr.Name] = limbs

    local function SkeletonVisibility(state)
        for i, v in pairs(limbs) do
            if v and v.Visible ~= nil then
                v.Visible = state
            end
        end
    end

    local function SkeletonColorize(color)
        for i, v in pairs(limbs) do
            if v and v.Color then
                v.Color = color
            end
        end
    end

    local function UpdaterR15()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not ESPSettings.Enabled or not ESPSettings.Skeletons then
                SkeletonVisibility(false)
                return
            end

            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    -- Head
                    local H = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_UpperTorso and limbs.Head_UpperTorso.From then
                        --Spine
                        local UT = camera:WorldToViewportPoint(plr.Character.UpperTorso.Position)
                        local LT = camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                        -- Left Arm
                        local LUA = camera:WorldToViewportPoint(plr.Character.LeftUpperArm.Position)
                        local LLA = camera:WorldToViewportPoint(plr.Character.LeftLowerArm.Position)
                        local LH = camera:WorldToViewportPoint(plr.Character.LeftHand.Position)
                        -- Right Arm
                        local RUA = camera:WorldToViewportPoint(plr.Character.RightUpperArm.Position)
                        local RLA = camera:WorldToViewportPoint(plr.Character.RightLowerArm.Position)
                        local RH = camera:WorldToViewportPoint(plr.Character.RightHand.Position)
                        -- Left leg
                        local LUL = camera:WorldToViewportPoint(plr.Character.LeftUpperLeg.Position)
                        local LLL = camera:WorldToViewportPoint(plr.Character.LeftLowerLeg.Position)
                        local LF = camera:WorldToViewportPoint(plr.Character.LeftFoot.Position)
                        -- Right leg
                        local RUL = camera:WorldToViewportPoint(plr.Character.RightUpperLeg.Position)
                        local RLL = camera:WorldToViewportPoint(plr.Character.RightLowerLeg.Position)
                        local RF = camera:WorldToViewportPoint(plr.Character.RightFoot.Position)

                        --Head
                        limbs.Head_UpperTorso.From = Vector2.new(H.X, H.Y)
                        limbs.Head_UpperTorso.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.UpperTorso_LowerTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LowerTorso.To = Vector2.new(LT.X, LT.Y)

                        -- Left Arm
                        limbs.UpperTorso_LeftUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LeftUpperArm.To = Vector2.new(LUA.X, LUA.Y)

                        limbs.LeftUpperArm_LeftLowerArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftUpperArm_LeftLowerArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftLowerArm_LeftHand.From = Vector2.new(LLA.X, LLA.Y)
                        limbs.LeftLowerArm_LeftHand.To = Vector2.new(LH.X, LH.Y)

                        -- Right Arm
                        limbs.UpperTorso_RightUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_RightUpperArm.To = Vector2.new(RUA.X, RUA.Y)

                        limbs.RightUpperArm_RightLowerArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightUpperArm_RightLowerArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightLowerArm_RightHand.From = Vector2.new(RLA.X, RLA.Y)
                        limbs.RightLowerArm_RightHand.To = Vector2.new(RH.X, RH.Y)

                        -- Left Leg
                        limbs.LowerTorso_LeftUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_LeftUpperLeg.To = Vector2.new(LUL.X, LUL.Y)

                        limbs.LeftUpperLeg_LeftLowerLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftUpperLeg_LeftLowerLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLowerLeg_LeftFoot.From = Vector2.new(LLL.X, LLL.Y)
                        limbs.LeftLowerLeg_LeftFoot.To = Vector2.new(LF.X, LF.Y)

                        -- Right Leg
                        limbs.LowerTorso_RightUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_RightUpperLeg.To = Vector2.new(RUL.X, RUL.Y)

                        limbs.RightUpperLeg_RightLowerLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightUpperLeg_RightLowerLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLowerLeg_RightFoot.From = Vector2.new(RLL.X, RLL.Y)
                        limbs.RightLowerLeg_RightFoot.To = Vector2.new(RF.X, RF.Y)
                    end

                    -- Apply colors
                    if ESPSettings.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            SkeletonColorize(ESPSettings.Green)
                        else
                            SkeletonColorize(ESPSettings.Red)
                        end
                    elseif ESPSettings.TeamColor then
                        SkeletonColorize(plr.TeamColor.Color)
                    else
                        SkeletonColorize(ESPSettings.Skeleton_Color)
                    end

                    if limbs.Head_UpperTorso and limbs.Head_UpperTorso.Visible ~= true then
                        SkeletonVisibility(true)
                    end
                else
                    if limbs.Head_UpperTorso and limbs.Head_UpperTorso.Visible ~= false then
                        SkeletonVisibility(false)
                    end
                end
            else                if limbs.Head_UpperTorso and limbs.Head_UpperTorso.Visible ~= false then
                SkeletonVisibility(false)
            end
                if game.Players:FindFirstChild(plr.Name) == nil then
                    for i, v in pairs(limbs) do
                        if v and v.Remove then
                            v:Remove()
                        end
                    end
                    if SkeletonESPObjects[plr.Name] then
                        SkeletonESPObjects[plr.Name] = nil
                    end
                    -- Remove from SkeletonESPConnections tracking
                    if SkeletonESPConnections[plr.Name .. "_skeleton"] then
                        SkeletonESPConnections[plr.Name .. "_skeleton"] = nil
                    end
                    connection:Disconnect()                end
            end
        end)
        -- Store skeleton connection for cleanup (R15)
        SkeletonESPConnections[plr.Name .. "_skeleton"] = connection
    end

    local function UpdaterR6()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if not ESPSettings.Enabled or not ESPSettings.Skeletons then
                SkeletonVisibility(false)
                return
            end

            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    local H = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_Spine and limbs.Head_Spine.From then
                        local T_Height = plr.Character.Torso.Size.Y/2 - 0.2
                        local UT = camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, T_Height, 0)).p)
                        local LT = camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, -T_Height, 0)).p)

                        local LA_Height = plr.Character["Left Arm"].Size.Y/2 - 0.2
                        local LUA = camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, LA_Height, 0)).p)
                        local LLA = camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, -LA_Height, 0)).p)

                        local RA_Height = plr.Character["Right Arm"].Size.Y/2 - 0.2
                        local RUA = camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, RA_Height, 0)).p)
                        local RLA = camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, -RA_Height, 0)).p)

                        local LL_Height = plr.Character["Left Leg"].Size.Y/2 - 0.2
                        local LUL = camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, LL_Height, 0)).p)
                        local LLL = camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, -LL_Height, 0)).p)

                        local RL_Height = plr.Character["Right Leg"].Size.Y/2 - 0.2
                        local RUL = camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, RL_Height, 0)).p)
                        local RLL = camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, -RL_Height, 0)).p)

                        -- Head
                        limbs.Head_Spine.From = Vector2.new(H.X, H.Y)
                        limbs.Head_Spine.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.Spine.From = Vector2.new(UT.X, UT.Y)
                        limbs.Spine.To = Vector2.new(LT.X, LT.Y)

                        --Left Arm
                        limbs.LeftArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.LeftArm_UpperTorso.To = Vector2.new(LUA.X, LUA.Y)

                        --Right Arm
                        limbs.RightArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.RightArm_UpperTorso.To = Vector2.new(RUA.X, RUA.Y)

                        --Left Leg
                        limbs.LeftLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.LeftLeg_LowerTorso.To = Vector2.new(LUL.X, LUL.Y)

                        --Right Leg
                        limbs.RightLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.RightLeg_LowerTorso.To = Vector2.new(RUL.X, RUL.Y)
                    end

                    -- Apply colors
                    if ESPSettings.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            SkeletonColorize(ESPSettings.Green)
                        else
                            SkeletonColorize(ESPSettings.Red)
                        end
                    elseif ESPSettings.TeamColor then
                        SkeletonColorize(plr.TeamColor.Color)
                    else
                        SkeletonColorize(ESPSettings.Skeleton_Color)
                    end

                    if limbs.Head_Spine and limbs.Head_Spine.Visible ~= true then
                        SkeletonVisibility(true)
                    end
                else
                    if limbs.Head_Spine and limbs.Head_Spine.Visible ~= false then
                        SkeletonVisibility(false)
                    end
                end
            else                if limbs.Head_Spine and limbs.Head_Spine.Visible ~= false then
                SkeletonVisibility(false)
            end
                if game.Players:FindFirstChild(plr.Name) == nil then
                    for i, v in pairs(limbs) do
                        if v and v.Remove then
                            v:Remove()
                        end
                    end
                    if SkeletonESPObjects[plr.Name] then
                        SkeletonESPObjects[plr.Name] = nil
                    end
                    -- Remove from SkeletonESPConnections tracking
                    if SkeletonESPConnections[plr.Name .. "_skeleton"] then
                        SkeletonESPConnections[plr.Name .. "_skeleton"] = nil
                    end
                    connection:Disconnect()                end
            end
        end)
        -- Store skeleton connection for cleanup (R6)
        SkeletonESPConnections[plr.Name .. "_skeleton"] = connection
    end

    if R15 then
        coroutine.wrap(UpdaterR15)()
    else
        coroutine.wrap(UpdaterR6)()
    end
end

-- Initialize ESP for existing players
-- Radar implementation (Made by Blissful#4992)
local function NewCircle(Transparency, Color, Radius, Filled, Thickness)
    if not DrawingAvailable then return {Visible = false, Remove = function() end} end

    local c = Drawing.new("Circle")
    c.Transparency = Transparency
    c.Color = Color
    c.Visible = false
    c.Thickness = Thickness
    c.Position = Vector2.new(0, 0)
    c.Radius = Radius
    c.NumSides = math.clamp(Radius*55/100, 10, 75)
    c.Filled = Filled
    return c
end

local function InitializeRadar()
    if not DrawingAvailable then return end

    -- Create radar background and border
    local RadarBackground = NewCircle(0.9, ESPSettings.RadarBack, ESPSettings.RadarRadius, true, 1)
    RadarBackground.Visible = ESPSettings.Radar
    RadarBackground.Position = ESPSettings.RadarPosition

    local RadarBorder = NewCircle(0.75, ESPSettings.RadarBorder, ESPSettings.RadarRadius, false, 3)
    RadarBorder.Visible = ESPSettings.Radar
    RadarBorder.Position = ESPSettings.RadarPosition

    RadarObjects.Background = RadarBackground
    RadarObjects.Border = RadarBorder

    -- Helper function to get relative position
    local function GetRelative(pos)
        local char = player.Character
        if char ~= nil and char.PrimaryPart ~= nil then
            local pmpart = char.PrimaryPart
            local camerapos = Vector3.new(camera.CFrame.Position.X, pmpart.Position.Y, camera.CFrame.Position.Z)
            local newcf = CFrame.new(pmpart.Position, camerapos)
            local r = newcf:PointToObjectSpace(pos)
            return r.X, r.Z
        else
            return 0, 0
        end
    end

    -- Create local player dot (triangle)
    local function NewLocalDot()
        if not DrawingAvailable then return {Visible = false, Remove = function() end} end

        local d = Drawing.new("Triangle")
        d.Visible = ESPSettings.Radar
        d.Thickness = 1
        d.Filled = true
        d.Color = ESPSettings.RadarLocalPlayerDot
        d.PointA = ESPSettings.RadarPosition + Vector2.new(0, -6)
        d.PointB = ESPSettings.RadarPosition + Vector2.new(-3, 6)
        d.PointC = ESPSettings.RadarPosition + Vector2.new(3, 6)
        return d
    end

    local LocalPlayerDot = NewLocalDot()
    RadarObjects.LocalDot = LocalPlayerDot

    -- Function to place dots for other players
    local function PlaceDot(plr)
        if not DrawingAvailable then return end

        local PlayerDot = NewCircle(1, ESPSettings.RadarPlayerDot, 3, true, 1)
        RadarObjects[plr.Name] = PlayerDot

        local function Update()
            local connection = game:GetService("RunService").RenderStepped:Connect(function()
                if not ESPSettings.Radar then
                    PlayerDot.Visible = false
                    return
                end

                local char = plr.Character
                if char and char:FindFirstChildOfClass("Humanoid") and char.PrimaryPart ~= nil and char:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    local scale = ESPSettings.RadarScale
                    local relx, rely = GetRelative(char.PrimaryPart.Position)
                    local newpos = ESPSettings.RadarPosition - Vector2.new(relx * scale, rely * scale)

                    if (newpos - ESPSettings.RadarPosition).magnitude < ESPSettings.RadarRadius-2 then
                        PlayerDot.Radius = 3
                        PlayerDot.Position = newpos
                        PlayerDot.Visible = true
                    else
                        local dist = (ESPSettings.RadarPosition - newpos).magnitude
                        local calc = (ESPSettings.RadarPosition - newpos).unit * (dist - ESPSettings.RadarRadius)
                        local inside = Vector2.new(newpos.X + calc.X, newpos.Y + calc.Y)
                        PlayerDot.Radius = 2
                        PlayerDot.Position = inside
                        PlayerDot.Visible = true
                    end

                    -- Apply team color if enabled
                    if ESPSettings.TeamCheck then
                        if plr.TeamColor == player.TeamColor then
                            PlayerDot.Color = ESPSettings.Green
                        else
                            PlayerDot.Color = ESPSettings.Red
                        end
                    elseif ESPSettings.TeamColor and plr.Team and plr.Team.TeamColor then
                        PlayerDot.Color = plr.Team.TeamColor.Color
                    else
                        PlayerDot.Color = ESPSettings.RadarPlayerDot
                    end

                    -- Apply health color if enabled
                    if ESPSettings.RadarHealthColor then
                        local healthPercent = hum.Health / hum.MaxHealth
                        PlayerDot.Color = Color3.fromRGB(
                                255 * (1 - healthPercent),
                                255 * healthPercent,
                                0
                        )
                    end
                else
                    PlayerDot.Visible = false
                    if not game.Players:FindFirstChild(plr.Name) then
                        PlayerDot:Remove()
                        RadarObjects[plr.Name] = nil
                        if RadarConnections[plr.Name] then
                            RadarConnections[plr.Name]:Disconnect()
                            RadarConnections[plr.Name] = nil
                        end
                    end
                end
            end)

            RadarConnections[plr.Name] = connection
        end

        coroutine.wrap(Update)()
    end

    -- Initialize dots for existing players
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Name ~= player.Name then
            PlaceDot(v)
        end
    end

    -- Add dots for new players
    local playerAddedConnection = game.Players.PlayerAdded:Connect(function(v)
        if v.Name ~= player.Name then
            PlaceDot(v)
        end
        -- Recreate local player dot when players join (to ensure it stays on top)
        if LocalPlayerDot and LocalPlayerDot.Remove then
            LocalPlayerDot:Remove()
        end
        LocalPlayerDot = NewLocalDot()
        RadarObjects.LocalDot = LocalPlayerDot
    end)
    RadarConnections["PlayerAdded"] = playerAddedConnection

    -- Update radar visuals
    local radarUpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if not ESPSettings.Radar then
            RadarBackground.Visible = false
            RadarBorder.Visible = false
            if LocalPlayerDot then LocalPlayerDot.Visible = false end
            return
        end

        if LocalPlayerDot then
            LocalPlayerDot.Visible = true
            LocalPlayerDot.Color = ESPSettings.RadarLocalPlayerDot
            LocalPlayerDot.PointA = ESPSettings.RadarPosition + Vector2.new(0, -6)
            LocalPlayerDot.PointB = ESPSettings.RadarPosition + Vector2.new(-3, 6)
            LocalPlayerDot.PointC = ESPSettings.RadarPosition + Vector2.new(3, 6)
        end

        RadarBackground.Visible = true
        RadarBackground.Position = ESPSettings.RadarPosition
        RadarBackground.Radius = ESPSettings.RadarRadius
        RadarBackground.Color = ESPSettings.RadarBack

        RadarBorder.Visible = true
        RadarBorder.Position = ESPSettings.RadarPosition
        RadarBorder.Radius = ESPSettings.RadarRadius
        RadarBorder.Color = ESPSettings.RadarBorder
    end)
    RadarConnections["RadarUpdate"] = radarUpdateConnection

    -- Make radar draggable
    local inset = game:GetService("GuiService"):GetGuiInset()
    local dragging = false
    local offset = Vector2.new(0, 0)

    local dragBeginConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and
                (Vector2.new(mouse.X, mouse.Y + inset.Y) - ESPSettings.RadarPosition).magnitude < ESPSettings.RadarRadius then
            offset = ESPSettings.RadarPosition - Vector2.new(mouse.X, mouse.Y)
            dragging = true
        end
    end)
    RadarConnections["DragBegin"] = dragBeginConnection

    local dragEndConnection = game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    RadarConnections["DragEnd"] = dragEndConnection

    -- Mouse indicator on radar
    local mouseIndicatorConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if dragging then
            ESPSettings.RadarPosition = Vector2.new(mouse.X, mouse.Y) + offset
        end
    end)
    RadarConnections["MouseIndicator"] = mouseIndicatorConnection

    -- Create mouse dot
    local mouseDot = NewCircle(1, Color3.fromRGB(255, 255, 255), 3, true, 1)
    RadarObjects.MouseDot = mouseDot

    local mouseDotConnection = game:GetService("RunService").RenderStepped:Connect(function()
        if ESPSettings.Radar and (Vector2.new(mouse.X, mouse.Y + inset.Y) - ESPSettings.RadarPosition).magnitude < ESPSettings.RadarRadius then
            mouseDot.Position = Vector2.new(mouse.X, mouse.Y + inset.Y)
            mouseDot.Visible = true
        else
            mouseDot.Visible = false
        end
    end)
    RadarConnections["MouseDot"] = mouseDotConnection
end

local function InitializeESP()
    if not DrawingAvailable then
        Library:Notify({
            Title = "ESP Unavailable",
            Description = "Drawing API not available! ESP disabled.",
            Time = 4,
        })
        return
    end

    for i, v in pairs(game:GetService("Players"):GetPlayers()) do
        if v.Name ~= player.Name then
            coroutine.wrap(ESP)(v)
            if ESPSettings.Skeletons then
                coroutine.wrap(DrawSkeletonESP)(v)
            end
            if ESPSettings.OffScreenArrows then
                coroutine.wrap(DrawOffScreenArrows)(v)
            end
        end
    end

    -- Initialize radar
    coroutine.wrap(InitializeRadar)()
end

-- ESP for new players
PlayerAddedConnection = game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= player.Name and DrawingAvailable then
        coroutine.wrap(ESP)(newplr)
        if ESPSettings.Skeletons then
            coroutine.wrap(DrawSkeletonESP)(newplr)
        end
        if ESPSettings.OffScreenArrows then
            coroutine.wrap(DrawOffScreenArrows)(newplr)
        end
    end
end)

-- Function to clean up ESP objects and connections
local function CleanupESP()
    -- Disconnect all ESP connections
    for playerName, connection in pairs(ESPConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    ESPConnections = {}

    -- Disconnect all Skeleton ESP connections
    for connectionKey, connection in pairs(SkeletonESPConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    SkeletonESPConnections = {}

    -- Disconnect all Off-Screen Arrow connections
    for playerName, connection in pairs(OffScreenArrowConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    OffScreenArrowConnections = {}

    -- Clean up Off-Screen Arrow objects
    for playerName, arrow in pairs(OffScreenArrowObjects) do
        if arrow and arrow.Remove then
            pcall(function() arrow:Remove() end)
        end
    end
    OffScreenArrowObjects = {}

    -- Clean up Radar objects
    for key, obj in pairs(RadarObjects) do
        if obj and obj.Remove then
            pcall(function() obj:Remove() end)
        end
    end
    RadarObjects = {}

    -- Disconnect Radar connections
    for key, connection in pairs(RadarConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    RadarConnections = {}

    -- Clean up ESP objects
    for playerName, espLib in pairs(ESPObjects) do
        for _, obj in pairs(espLib) do
            if obj and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
    end
    ESPObjects = {}

    -- Clean up Skeleton ESP objects
    for playerName, skelLib in pairs(SkeletonESPObjects) do
        for _, obj in pairs(skelLib) do
            if obj and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
    end
    SkeletonESPObjects = {}
end

-- ESP UI Controls
local ESPGroup = Tabs.ESP:AddLeftGroupbox("ESP Settings", "eye")

if not DrawingAvailable then
    ESPGroup:AddLabel("⚠️ Drawing API not available!")
    ESPGroup:AddLabel("ESP features require an executor")
    ESPGroup:AddLabel("that supports the Drawing library.")
end

ESPGroup:AddToggle("ESPEnabled", {
    Text = "Enable ESP",
    Default = ESPSettings.Enabled,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Enabled = Value
        if Value then
            InitializeESP()
            Library:Notify({
                Title = "ESP Enabled",
                Description = "All ESP features are now active",
                Time = 2,
            })
        else
            -- Clean up ESP objects and connections when disabled
            CleanupESP()
            Library:Notify({
                Title = "ESP Disabled",
                Description = "All ESP features are now inactive",
                Time = 2,
            })
        end
    end,
})

-- Create a dropdown for ESP presets
ESPGroup:AddDropdown("ESPPreset", {
    Values = { "Default", "Competitive", "Stealth", "Colorful", "Minimal", "Custom" },
    Default = "Default",
    Text = "ESP Preset",
    Tooltip = "Quick presets for different ESP styles",
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        if Value == "Default" then
            -- Default settings
            ESPSettings.Boxes = true
            ESPSettings.Tracers = true
            ESPSettings.HealthBars = true
            ESPSettings.Skeletons = false
            ESPSettings.OffScreenArrows = false
            ESPSettings.Names = false
            ESPSettings.Distances = false
            ESPSettings.Weapons = false
            ESPSettings.Chams = false
            ESPSettings.Box_Thickness = 1
            ESPSettings.Tracer_Thickness = 1
            ESPSettings.Skeleton_Thickness = 1
            ESPSettings.Box_Color = Color3.fromRGB(255, 0, 0)
            ESPSettings.Tracer_Color = Color3.fromRGB(255, 0, 0)
            ESPSettings.Skeleton_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.TeamCheck = true
            ESPSettings.TeamColor = false

        elseif Value == "Competitive" then
            -- Competitive settings (maximum visibility)
            ESPSettings.Boxes = true
            ESPSettings.Tracers = true
            ESPSettings.HealthBars = true
            ESPSettings.Skeletons = true
            ESPSettings.OffScreenArrows = true
            ESPSettings.Names = true
            ESPSettings.Distances = true
            ESPSettings.Weapons = true
            ESPSettings.Chams = true
            ESPSettings.Box_Thickness = 2
            ESPSettings.Tracer_Thickness = 2
            ESPSettings.Skeleton_Thickness = 2
            ESPSettings.Box_Color = Color3.fromRGB(0, 255, 0)
            ESPSettings.Tracer_Color = Color3.fromRGB(0, 255, 0)
            ESPSettings.Skeleton_Color = Color3.fromRGB(0, 255, 0)
            ESPSettings.TeamCheck = true
            ESPSettings.TeamColor = false

        elseif Value == "Stealth" then
            -- Stealth settings (minimal visibility, harder to detect)
            ESPSettings.Boxes = false
            ESPSettings.Tracers = false
            ESPSettings.HealthBars = false
            ESPSettings.Skeletons = false
            ESPSettings.OffScreenArrows = true
            ESPSettings.Names = false
            ESPSettings.Distances = false
            ESPSettings.Weapons = false
            ESPSettings.Chams = false
            ESPSettings.Box_Thickness = 1
            ESPSettings.Tracer_Thickness = 1
            ESPSettings.Skeleton_Thickness = 1
            ESPSettings.Box_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.Tracer_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.Skeleton_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.TeamCheck = true
            ESPSettings.TeamColor = false

        elseif Value == "Colorful" then
            -- Colorful settings (rainbow colors)
            ESPSettings.Boxes = true
            ESPSettings.Tracers = true
            ESPSettings.HealthBars = true
            ESPSettings.Skeletons = true
            ESPSettings.OffScreenArrows = true
            ESPSettings.Names = true
            ESPSettings.Distances = true
            ESPSettings.Weapons = true
            ESPSettings.Chams = true
            ESPSettings.Box_Thickness = 2
            ESPSettings.Tracer_Thickness = 2
            ESPSettings.Skeleton_Thickness = 2
            ESPSettings.RainbowColor = true
            ESPSettings.RainbowOutlineColor = true
            ESPSettings.TeamCheck = false
            ESPSettings.TeamColor = true

        elseif Value == "Minimal" then
            -- Minimal settings (boxes only)
            ESPSettings.Boxes = true
            ESPSettings.Tracers = false
            ESPSettings.HealthBars = false
            ESPSettings.Skeletons = false
            ESPSettings.OffScreenArrows = false
            ESPSettings.Names = false
            ESPSettings.Distances = false
            ESPSettings.Weapons = false
            ESPSettings.Chams = false
            ESPSettings.Box_Thickness = 1
            ESPSettings.Tracer_Thickness = 1
            ESPSettings.Skeleton_Thickness = 1
            ESPSettings.Box_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.Tracer_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.Skeleton_Color = Color3.fromRGB(255, 255, 255)
            ESPSettings.TeamCheck = true
            ESPSettings.TeamColor = false
        end

        -- Update UI elements to reflect the new settings
        Toggles.ESPBoxes:SetValue(ESPSettings.Boxes)
        Toggles.ESPTracers:SetValue(ESPSettings.Tracers)
        Toggles.ESPHealthBars:SetValue(ESPSettings.HealthBars)
        Toggles.ESPSkeletons:SetValue(ESPSettings.Skeletons)
        Toggles.ESPOffScreenArrows:SetValue(ESPSettings.OffScreenArrows)
        if Toggles.ESPNames then Toggles.ESPNames:SetValue(ESPSettings.Names) end
        if Toggles.ESPDistances then Toggles.ESPDistances:SetValue(ESPSettings.Distances) end
        if Toggles.ESPWeapons then Toggles.ESPWeapons:SetValue(ESPSettings.Weapons) end
        if Toggles.ESPChams then Toggles.ESPChams:SetValue(ESPSettings.Chams) end

        -- Initialize ESP with new settings
        if ESPSettings.Enabled then
            InitializeESP()
        end

        Library:Notify({
            Title = "ESP Preset Applied",
            Description = Value .. " preset has been applied",
            Time = 2,
        })
    end,
})

ESPGroup:AddToggle("ESPBoxes", {
    Text = "Show Boxes",
    Default = ESPSettings.Boxes,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Boxes = Value
    end,
})

ESPGroup:AddToggle("ESPTracers", {
    Text = "Show Tracers",
    Default = ESPSettings.Tracers,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Tracers = Value
    end,
})

ESPGroup:AddToggle("ESPHealthBars", {
    Text = "Show Health Bars",
    Default = ESPSettings.HealthBars,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.HealthBars = Value
    end,
})

ESPGroup:AddToggle("ESPSkeletons", {
    Text = "Show Skeletons",
    Default = ESPSettings.Skeletons,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Skeletons = Value
        if Value and DrawingAvailable then
            -- Initialize skeleton ESP for existing players
            for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v.Name ~= player.Name and not SkeletonESPObjects[v.Name] then
                    coroutine.wrap(DrawSkeletonESP)(v)
                end
            end
        end
    end,
})

-- Off-screen arrows toggle (Made by Blissful#4992)
ESPGroup:AddToggle("ESPOffScreenArrows", {
    Text = "Show Off-Screen Arrows",
    Default = ESPSettings.OffScreenArrows,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrows = Value
        if Value and DrawingAvailable then
            -- Initialize off-screen arrows for existing players
            for i, v in pairs(game:GetService("Players"):GetPlayers()) do
                if v.Name ~= player.Name and not OffScreenArrowObjects[v.Name] then
                    coroutine.wrap(DrawOffScreenArrows)(v)
                end
            end
        end
    end,
})

-- Add new ESP features
ESPGroup:AddToggle("ESPNames", {
    Text = "Show Names",
    Default = ESPSettings.Names or false,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Names = Value
    end,
})

ESPGroup:AddToggle("ESPDistances", {
    Text = "Show Distances",
    Default = ESPSettings.Distances or false,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Distances = Value
    end,
})

ESPGroup:AddToggle("ESPWeapons", {
    Text = "Show Weapons",
    Default = ESPSettings.Weapons or false,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Weapons = Value
    end,
})

ESPGroup:AddToggle("ESPChams", {
    Text = "Show Chams",
    Default = ESPSettings.Chams or false,
    Disabled = not DrawingAvailable,
    Tooltip = "Highlight players through walls",
    Callback = function(Value)
        ESPSettings.Chams = Value

        -- Initialize chams if enabled
        if Value and DrawingAvailable then
            if not getgenv().ChamsInitialized then
                getgenv().ChamsInitialized = true

                -- Create chams function
                getgenv().UpdateChams = function()
                    for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
                        if plr ~= player and plr.Character then
                            -- Check if chams already exist for this player
                            if not getgenv().ChamsObjects then getgenv().ChamsObjects = {} end

                            if not getgenv().ChamsObjects[plr.Name] then
                                getgenv().ChamsObjects[plr.Name] = {}

                                -- Create highlight for the character
                                local highlight = Instance.new("Highlight")
                                highlight.FillColor = ESPSettings.TeamCheck and
                                    (plr.TeamColor == player.TeamColor and ESPSettings.Green or ESPSettings.Red) or
                                    (ESPSettings.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255, 0, 0))
                                highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                                highlight.FillTransparency = 0.5
                                highlight.OutlineTransparency = 0
                                highlight.Adornee = plr.Character
                                highlight.Parent = game:GetService("CoreGui")

                                getgenv().ChamsObjects[plr.Name].Highlight = highlight
                            else
                                -- Update existing highlight
                                local highlight = getgenv().ChamsObjects[plr.Name].Highlight
                                if highlight and highlight.Parent then
                                    highlight.FillColor = ESPSettings.TeamCheck and
                                        (plr.TeamColor == player.TeamColor and ESPSettings.Green or ESPSettings.Red) or
                                        (ESPSettings.TeamColor and plr.TeamColor.Color or Color3.fromRGB(255, 0, 0))
                                    highlight.Adornee = plr.Character
                                end
                            end
                        end
                    end
                end

                -- Clean up chams function
                getgenv().CleanupChams = function()
                    if getgenv().ChamsObjects then
                        for _, chamObj in pairs(getgenv().ChamsObjects) do
                            if chamObj.Highlight and chamObj.Highlight.Parent then
                                chamObj.Highlight:Destroy()
                            end
                        end
                        getgenv().ChamsObjects = {}
                    end
                end

                -- Run update chams
                getgenv().UpdateChams()
            else
                -- If already initialized, just update
                if getgenv().UpdateChams then
                    getgenv().UpdateChams()
                end
            end
        else
            -- Clean up chams if disabled
            if getgenv().CleanupChams then
                getgenv().CleanupChams()
            end
        end
    end,
})

ESPGroup:AddDropdown("TracerOrigin", {
    Values = { "Bottom", "Middle" },
    Default = ESPSettings.Tracer_Origin,
    Text = "Tracer Origin",
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Tracer_Origin = Value
    end,
})

ESPGroup:AddToggle("TracerFollowMouse", {
    Text = "Tracer Follow Mouse",
    Default = ESPSettings.Tracer_FollowMouse,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Tracer_FollowMouse = Value
    end,
})

ESPGroup:AddSlider("BoxThickness", {
    Text = "Box Thickness",
    Default = ESPSettings.Box_Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Box_Thickness = Value
        -- Update thickness for all existing ESP objects
        for _, lib in pairs(ESPObjects) do
            if lib.box and lib.box.Thickness then
                lib.box.Thickness = Value
                lib.black.Thickness = Value * 2
            end
        end
    end,
})

ESPGroup:AddSlider("TracerThickness", {
    Text = "Tracer Thickness",
    Default = ESPSettings.Tracer_Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Tracer_Thickness = Value
        -- Update thickness for all existing ESP objects
        for _, lib in pairs(ESPObjects) do
            if lib.tracer and lib.tracer.Thickness then
                lib.tracer.Thickness = Value
                lib.blacktracer.Thickness = Value * 2
            end
        end
    end,
})

ESPGroup:AddSlider("SkeletonThickness", {
    Text = "Skeleton Thickness",
    Default = ESPSettings.Skeleton_Thickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Skeleton_Thickness = Value
        -- Update thickness for all existing skeleton objects
        for _, lib in pairs(SkeletonESPObjects) do
            for _, line in pairs(lib) do
                if line and line.Thickness then
                    line.Thickness = Value
                end
            end
        end
    end,
})

-- Off-screen arrow sliders (Made by Blissful#4992)
ESPGroup:AddSlider("OffScreenArrowSize", {
    Text = "Off-Screen Arrow Size",
    Default = ESPSettings.OffScreenArrowSize,
    Min = 8,
    Max = 32,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrowSize = Value
    end,
})

ESPGroup:AddSlider("OffScreenArrowRadius", {
    Text = "Off-Screen Arrow Distance",
    Default = ESPSettings.OffScreenArrowRadius,
    Min = 40,
    Max = 200,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrowRadius = Value
    end,
})

ESPGroup:AddSlider("OffScreenArrowThickness", {
    Text = "Off-Screen Arrow Thickness",
    Default = ESPSettings.OffScreenArrowThickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrowThickness = Value
        -- Update thickness for all existing arrow objects
        for _, arrow in pairs(OffScreenArrowObjects) do
            if arrow and arrow.Thickness then
                arrow.Thickness = Value
            end
        end
    end,
})

ESPGroup:AddToggle("OffScreenArrowFilled", {
    Text = "Filled Arrows",
    Default = ESPSettings.OffScreenArrowFilled,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrowFilled = Value
        -- Update filled state for all existing arrow objects
        for _, arrow in pairs(OffScreenArrowObjects) do
            if arrow and arrow.Filled ~= nil then
                arrow.Filled = Value
            end
        end
    end,
})

ESPGroup:AddSlider("OffScreenArrowTransparency", {
    Text = "Arrow Transparency",
    Default = ESPSettings.OffScreenArrowTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrowTransparency = Value
        -- Update transparency for all existing arrow objects
        for _, arrow in pairs(OffScreenArrowObjects) do
            if arrow and arrow.Transparency ~= nil then
                arrow.Transparency = 1-Value
            end
        end
    end,
})

ESPGroup:AddToggle("OffScreenArrowAntiAliasing", {
    Text = "Anti-Aliasing",
    Default = ESPSettings.OffScreenArrowAntiAliasing,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.OffScreenArrowAntiAliasing = Value
    end,
})

-- Radar toggle and settings (Made by Blissful#4992)
ESPGroup:AddDivider()
ESPGroup:AddLabel("Radar Settings")

ESPGroup:AddToggle("RadarEnabled", {
    Text = "Show Radar",
    Default = ESPSettings.Radar,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.Radar = Value
    end,
})

ESPGroup:AddToggle("RadarHealthColor", {
    Text = "Health-Based Colors",
    Default = ESPSettings.RadarHealthColor,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.RadarHealthColor = Value
    end,
})

ESPGroup:AddSlider("RadarRadius", {
    Text = "Radar Size",
    Default = ESPSettings.RadarRadius,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.RadarRadius = Value
    end,
})

ESPGroup:AddSlider("RadarScale", {
    Text = "Radar Scale",
    Default = ESPSettings.RadarScale,
    Min = 0.5,
    Max = 5,
    Rounding = 1,
    Disabled = not DrawingAvailable,
    Callback = function(Value)
        ESPSettings.RadarScale = Value
    end,
})

-- ESP Colors Group
local ESPColorsGroup = Tabs.ESP:AddRightGroupbox("ESP Colors", "palette")

-- Create toggles first, then add color pickers to them
local BoxColorToggle = ESPColorsGroup:AddToggle("CustomBoxColor", {
    Text = "Custom Box Color",
    Default = true,
    Tooltip = "Use custom color for ESP boxes",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

BoxColorToggle:AddColorPicker("ESPBoxColor", {
    Default = ESPSettings.Box_Color,
    Title = "ESP Box Color",
    Callback = function(Value)
        ESPSettings.Box_Color = Value
    end,
})

local TracerColorToggle = ESPColorsGroup:AddToggle("CustomTracerColor", {
    Text = "Custom Tracer Color",
    Default = true,
    Tooltip = "Use custom color for ESP tracers",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

TracerColorToggle:AddColorPicker("ESPTracerColor", {
    Default = ESPSettings.Tracer_Color,
    Title = "ESP Tracer Color",
    Callback = function(Value)
        ESPSettings.Tracer_Color = Value
    end,
})

local SkeletonColorToggle = ESPColorsGroup:AddToggle("CustomSkeletonColor", {
    Text = "Custom Skeleton Color",
    Default = true,
    Tooltip = "Use custom color for ESP skeletons",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

SkeletonColorToggle:AddColorPicker("ESPSkeletonColor", {
    Default = ESPSettings.Skeleton_Color,
    Title = "ESP Skeleton Color",
    Callback = function(Value)
        ESPSettings.Skeleton_Color = Value
    end,
})

-- Off-screen arrow color toggle (Made by Blissful#4992)
local ArrowColorToggle = ESPColorsGroup:AddToggle("CustomArrowColor", {
    Text = "Custom Arrow Color",
    Default = true,
    Tooltip = "Use custom color for off-screen arrows",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

ArrowColorToggle:AddColorPicker("ESPArrowColor", {
    Default = ESPSettings.OffScreenArrowColor,
    Title = "Off-Screen Arrow Color",
    Callback = function(Value)
        ESPSettings.OffScreenArrowColor = Value
        -- Update color for all existing arrow objects
        for _, arrow in pairs(OffScreenArrowObjects) do
            if arrow and arrow.Color ~= nil then
                arrow.Color = Value
            end
        end
    end,
})

ESPColorsGroup:AddDivider()

ESPColorsGroup:AddToggle("ESPTeamCheck", {
    Text = "Team Check",
    Default = ESPSettings.TeamCheck,
    Tooltip = "Use different colors for teammates and enemies",
    Callback = function(Value)
        ESPSettings.TeamCheck = Value
    end,
})

ESPColorsGroup:AddToggle("ESPTeamColor", {
    Text = "Team Color",
    Default = ESPSettings.TeamColor,
    Tooltip = "Use player's team color",
    Callback = function(Value)
        ESPSettings.TeamColor = Value
    end,
})

local TeamColorToggle = ESPColorsGroup:AddToggle("CustomTeamColors", {
    Text = "Custom Team Colors",
    Default = true,
    Tooltip = "Customize teammate and enemy colors",
    Callback = function(Value)
        -- Team color customization toggle
    end,
})

TeamColorToggle:AddColorPicker("ESPTeamGreen", {
    Default = ESPSettings.Green,
    Title = "Teammate Color",
    Callback = function(Value)
        ESPSettings.Green = Value
    end,
})

TeamColorToggle:AddColorPicker("ESPTeamRed", {
    Default = ESPSettings.Red,
    Title = "Enemy Color",
    Callback = function(Value)
        ESPSettings.Red = Value
    end,
})

-- Radar Colors (Made by Blissful#4992)
ESPColorsGroup:AddDivider()
ESPColorsGroup:AddLabel("Radar Colors")

local RadarBackToggle = ESPColorsGroup:AddToggle("CustomRadarBack", {
    Text = "Radar Background",
    Default = true,
    Tooltip = "Customize radar background color",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

RadarBackToggle:AddColorPicker("RadarBackColor", {
    Default = ESPSettings.RadarBack,
    Title = "Radar Background Color",
    Callback = function(Value)
        ESPSettings.RadarBack = Value
    end,
})

local RadarBorderToggle = ESPColorsGroup:AddToggle("CustomRadarBorder", {
    Text = "Radar Border",
    Default = true,
    Tooltip = "Customize radar border color",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

RadarBorderToggle:AddColorPicker("RadarBorderColor", {
    Default = ESPSettings.RadarBorder,
    Title = "Radar Border Color",
    Callback = function(Value)
        ESPSettings.RadarBorder = Value
    end,
})

local RadarLocalDotToggle = ESPColorsGroup:AddToggle("CustomRadarLocalDot", {
    Text = "Local Player Dot",
    Default = true,
    Tooltip = "Customize local player dot color",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

RadarLocalDotToggle:AddColorPicker("RadarLocalDotColor", {
    Default = ESPSettings.RadarLocalPlayerDot,
    Title = "Local Player Dot Color",
    Callback = function(Value)
        ESPSettings.RadarLocalPlayerDot = Value
    end,
})

local RadarPlayerDotToggle = ESPColorsGroup:AddToggle("CustomRadarPlayerDot", {
    Text = "Player Dots",
    Default = true,
    Tooltip = "Customize player dots color",
    Callback = function(Value)
        -- Color customization toggle
    end,
})

RadarPlayerDotToggle:AddColorPicker("RadarPlayerDotColor", {
    Default = ESPSettings.RadarPlayerDot,
    Title = "Player Dots Color",
    Callback = function(Value)
        ESPSettings.RadarPlayerDot = Value
    end,
})

-- Players Tab
local PlayersGroup = Tabs.Players:AddLeftGroupbox("Player Management", "users")

-- Use Obsidian's special Player dropdown that auto-updates
local PlayerSelector = PlayersGroup:AddDropdown("PlayerList", {
    SpecialType = "Player",
    Text = "Select Player",
    ExcludeLocalPlayer = true,
    Tooltip = "Select a player to target or manage",
    Callback = function(Value)
        getgenv().SelectedPlayer = Value
        print("Selected player:", Value)
    end,
})

PlayersGroup:AddButton({
    Text = "Blacklist Player",
    Func = function()
        if getgenv().SelectedPlayer then
            AimbotModule:Blacklist(getgenv().SelectedPlayer)
            Library:Notify({
                Title = "Player Blacklisted",
                Description = "Blacklisted: " .. getgenv().SelectedPlayer,
                Time = 3,
            })
        else
            Library:Notify({
                Title = "No Player Selected",
                Description = "Please select a player first!",
                Time = 2,
            })
        end
    end,
    Tooltip = "Blacklist the selected player from aimbot targeting",
})

PlayersGroup:AddButton({
    Text = "Whitelist Player",
    Func = function()
        if getgenv().SelectedPlayer then
            pcall(function()
                AimbotModule:Whitelist(getgenv().SelectedPlayer)
                Library:Notify({
                    Title = "Player Whitelisted",
                    Description = "Whitelisted: " .. getgenv().SelectedPlayer,
                    Time = 3,
                })
            end)
        else
            Library:Notify({
                Title = "No Player Selected",
                Description = "Please select a player first!",
                Time = 2,
            })
        end
    end,
    Tooltip = "Remove player from blacklist",
})

-- Control Buttons
local ControlGroup = Tabs.Players:AddRightGroupbox("Aimbot Control", "play")

ControlGroup:AddButton({
    Text = "Start Aimbot",
    Func = function()
        if not AimbotModule.Loaded then
            AimbotModule.Load()
            Library:Notify({
                Title = "Aimbot Started",
                Description = "Aimbot module initialized successfully!",
                Time = 3,
            })
        else
            Library:Notify({
                Title = "Already Running",
                Description = "Aimbot is already active!",
                Time = 2,
            })
        end
    end,
    Tooltip = "Initialize and start the aimbot",
})

ControlGroup:AddButton({
    Text = "Restart Aimbot",
    Func = function()
        AimbotModule.Restart()
        Library:Notify({
            Title = "Aimbot Restarted",
            Description = "Aimbot module has been restarted!",
            Time = 3,
        })
    end,
    Tooltip = "Restart the aimbot module",
})

ControlGroup:AddButton({
    Text = "Get Closest Player",
    Func = function()
        local closest = AimbotModule.GetClosestPlayer()
        if closest then
            Library:Notify({
                Title = "Closest Player Found",
                Description = "Closest Player: " .. closest.Name,
                Time = 3,
            })
        else
            Library:Notify({
                Title = "No Target Found",
                Description = "No player found in FOV range",
                Time = 2,
            })
        end
    end,
    Tooltip = "Find the closest player to your crosshair",
})

-- UI Settings Tab (from Obsidian example)
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "wrench")

MenuGroup:AddToggle("KeybindMenuOpen", {
    Default = Library.KeybindFrame.Visible,
    Text = "Open Keybind Menu",
    Callback = function(value)
        Library.KeybindFrame.Visible = value
    end,
})

MenuGroup:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor",
    Default = true,
    Callback = function(Value)
        Library.ShowCustomCursor = Value
    end,
})

MenuGroup:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" },
    Default = "Right",
    Text = "Notification Side",
    Callback = function(Value)
        Library:SetNotifySide(Value)
    end,
})

MenuGroup:AddDivider()

-- Create a dummy toggle for menu keybind (following Obsidian best practices)
local MenuKeybindToggle = MenuGroup:AddToggle("MenuKeybindToggle", {
    Text = "Menu Keybind",
    Default = false,
    Tooltip = "Toggle to show/hide the menu keybind option",
    Callback = function(Value)
        -- This toggle doesn't need to do anything, it's just for the keybind
    end,
})

MenuKeybindToggle:AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI = true,
    Text = "Menu keybind",
    Mode = "Toggle",
})

-- Create cleanup function
local function cleanupAndUnload()    pcall(function()
    -- Show notification before unloading
    Library:Notify({
        Title = "Unloading GUI",
        Description = "Cleaning up all objects...",
        Time = 2,
    })
end)

    -- Disable ESP settings to stop render loops
    ESPSettings.Enabled = false

    -- Use the CleanupESP function to clean up all ESP-related objects and connections
    CleanupESP()

    -- Disconnect PlayerAdded connection
    if PlayerAddedConnection and PlayerAddedConnection.Disconnect then
        pcall(function() PlayerAddedConnection:Disconnect() end)
        PlayerAddedConnection = nil
    end

    -- Make sure the aimbot is disabled by setting its Enabled property to false
    if getgenv().ExunysDeveloperAimbot and getgenv().ExunysDeveloperAimbot.Settings then
        getgenv().ExunysDeveloperAimbot.Settings.Enabled = false
    end

    -- Clean up aimbot and FOV circles properly
    local AimbotEnvironment = getgenv().ExunysDeveloperAimbot
    if AimbotEnvironment then
        -- Clean up FOV circles manually first (extra safety)
        pcall(function()
            if AimbotEnvironment.FOVCircle and AimbotEnvironment.FOVCircle.Remove then
                AimbotEnvironment.FOVCircle:Remove()
            end
        end)
        pcall(function()
            if AimbotEnvironment.FOVCircleOutline and AimbotEnvironment.FOVCircleOutline.Remove then
                AimbotEnvironment.FOVCircleOutline:Remove()
            end
        end)

        -- Call the proper Exit method
        pcall(function()
            AimbotEnvironment:Exit()
        end)
    end

    -- Also try the module Exit method as backup
    if AimbotModule and AimbotModule.Exit then
        pcall(function() AimbotModule:Exit() end)
    end

    -- Mark aimbot as unloaded
    if AimbotModule then
        AimbotModule.Loaded = false
    end

    -- Clear global variables
    if getgenv().SelectedPlayer then
        getgenv().SelectedPlayer = nil
    end
    if getgenv().ExunysDeveloperAimbot then
        getgenv().ExunysDeveloperAimbot = nil
    end

    -- Small delay then unload
    task.wait(0.5)
    Library:Unload()
end

-- Create toggle for unload keybind
local UnloadKeybindToggle = MenuGroup:AddToggle("UnloadKeybindToggle", {
    Text = "Unload Keybind",
    Default = false,
    Tooltip = "Toggle to show/hide the unload keybind option",
    Callback = function(Value)
        -- This toggle doesn't need to do anything, it's just for the keybind
    end,
})

UnloadKeybindToggle:AddKeyPicker("UnloadKeybind", {
    Default = "End",
    NoUI = true,
    Text = "Unload GUI keybind",
    Mode = "Toggle",
    Callback = function()
        cleanupAndUnload()
    end
})

MenuGroup:AddButton({
    Text = "Unload GUI",
    Func = function()
        cleanupAndUnload()
    end,
    Tooltip = "Manually unload the GUI and clean up all objects",
})

Library.ToggleKeybind = Options.MenuKeybind

-- Setup managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

ThemeManager:SetFolder("AimbotScript")
SaveManager:SetFolder("AimbotScript/configs")

SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- Initialize the aimbot
AimbotModule.Load()
AimbotModule.Loaded = true

-- Auto-load config
SaveManager:LoadAutoloadConfig()

-- Cleanup function
Library:OnUnload(function()
    print("Starting GUI cleanup...")

    -- Also clean up Off-Screen Arrow objects and connections (Made by Blissful#4992)
    for playerName, connection in pairs(OffScreenArrowConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    for playerName, arrow in pairs(OffScreenArrowObjects) do
        if arrow and arrow.Remove then
            pcall(function() arrow:Remove() end)
        end
    end

    -- Clean up Radar objects and connections (Made by Blissful#4992)
    for key, connection in pairs(RadarConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    for key, obj in pairs(RadarObjects) do
        if obj and obj.Remove then
            pcall(function() obj:Remove() end)
        end
    end

    -- Disable ESP settings to stop render loops
    ESPSettings.Enabled = false

    -- Disconnect all ESP connections
    for playerName, connection in pairs(ESPConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    ESPConnections = {}

    -- Disconnect all Skeleton ESP connections
    for connectionKey, connection in pairs(SkeletonESPConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    SkeletonESPConnections = {}

    -- Disconnect all Off-Screen Arrow connections (Made by Blissful#4992)
    for playerName, connection in pairs(OffScreenArrowConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    OffScreenArrowConnections = {}

    -- Disconnect all Radar connections (Made by Blissful#4992)
    for key, connection in pairs(RadarConnections) do
        if connection and connection.Disconnect then
            pcall(function() connection:Disconnect() end)
        end
    end
    RadarConnections = {}

    -- Disconnect PlayerAdded connection
    if PlayerAddedConnection and PlayerAddedConnection.Disconnect then
        pcall(function() PlayerAddedConnection:Disconnect() end)
        PlayerAddedConnection = nil
    end

    -- Clean up ESP objects
    for playerName, espLib in pairs(ESPObjects) do
        for _, obj in pairs(espLib) do
            if obj and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
    end
    ESPObjects = {}

    -- Clean up Skeleton ESP objects
    for playerName, skelLib in pairs(SkeletonESPObjects) do
        for _, obj in pairs(skelLib) do
            if obj and obj.Remove then
                pcall(function() obj:Remove() end)
            end
        end
    end
    SkeletonESPObjects = {}

    -- Make sure the aimbot is disabled by setting its Enabled property to false
    if getgenv().ExunysDeveloperAimbot and getgenv().ExunysDeveloperAimbot.Settings then
        getgenv().ExunysDeveloperAimbot.Settings.Enabled = false
    end

    -- Clean up aimbot and FOV circles properly
    local AimbotEnvironment = getgenv().ExunysDeveloperAimbot
    if AimbotEnvironment then
        -- Clean up FOV circles manually first (extra safety)
        pcall(function()
            if AimbotEnvironment.FOVCircle and AimbotEnvironment.FOVCircle.Remove then
                AimbotEnvironment.FOVCircle:Remove()
            end
        end)
        pcall(function()
            if AimbotEnvironment.FOVCircleOutline and AimbotEnvironment.FOVCircleOutline.Remove then
                AimbotEnvironment.FOVCircleOutline:Remove()
            end
        end)

        -- Call the proper Exit method
        pcall(function()
            AimbotEnvironment:Exit()
        end)
    end

    -- Also try the module Exit method as backup
    if AimbotModule and AimbotModule.Exit then
        pcall(function() AimbotModule:Exit() end)
    end

    -- Mark aimbot as unloaded
    if AimbotModule then
        AimbotModule.Loaded = false
    end

    -- Clear global variables
    if getgenv().SelectedPlayer then
        getgenv().SelectedPlayer = nil
    end
    if getgenv().ExunysDeveloperAimbot then
        getgenv().ExunysDeveloperAimbot = nil
    end

    print("GUI completely unloaded and cleaned up!")
end)

-- Sweat Tab
-- Only keeping Stretch Resolution and FOV Changer features
local SweatAdvancedGroup = Tabs.Sweat:AddRightGroupbox("Sweat Settings", "settings")

-- Create a separate groupbox for Low Graphics
local LowGraphicsGroup = Tabs.Sweat:AddLeftGroupbox("Low Graphics Settings", "image")

-- Add Low Graphics toggle to its own groupbox
LowGraphicsGroup:AddToggle("LowGraphics", {
    Text = "Enable Low Graphics",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Save original materials to restore later
            if not getgenv().OriginalMaterials then
                getgenv().OriginalMaterials = {}
                for i, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("Part") then
                        getgenv().OriginalMaterials[v] = v.Material
                    end
                end
            end

            -- Apply low graphics (change all parts to SmoothPlastic)
            for i, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Part") then
                    v.Material = Enum.Material.SmoothPlastic
                end
            end

            Library:Notify({
                Title = "Low Graphics Enabled",
                Description = "Low graphics mode is now active",
                Time = 2,
            })
        else
            -- Restore original materials if available
            if getgenv().OriginalMaterials then
                for part, material in pairs(getgenv().OriginalMaterials) do
                    if part and part:IsA("Part") then
                        pcall(function() part.Material = material end)
                    end
                end
            end

            Library:Notify({
                Title = "Low Graphics Disabled",
                Description = "Low graphics mode is now inactive",
                Time = 2,
            })
        end
    end,
})

-- Stretch Resolution
SweatAdvancedGroup:AddToggle("StretchResolution", {
    Text = "Enable Stretch Resolution",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Initialize stretch resolution
            getgenv().Resolution = {
                [".gg/scripters"] = 0.65
            }

            if getgenv().gg_scripters == nil then
                game:GetService("RunService").RenderStepped:Connect(
                    function()
                        local Camera = workspace.CurrentCamera
                        Camera.CFrame = Camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, getgenv().Resolution[".gg/scripters"], 0, 0, 0, 1)
                    end
                )
            end
            getgenv().gg_scripters = "Aori0001"

            Library:Notify({
                Title = "Stretch Resolution Enabled",
                Description = "Stretch resolution is now active",
                Time = 2,
            })
        else
            -- Disable stretch resolution (reset to default)
            if getgenv().Resolution then
                getgenv().Resolution[".gg/scripters"] = 1
            end

            Library:Notify({
                Title = "Stretch Resolution Disabled",
                Description = "Stretch resolution is now inactive",
                Time = 2,
            })
        end
    end,
})

SweatAdvancedGroup:AddSlider("StretchAmount", {
    Text = "Stretch Amount",
    Default = 0.65,
    Min = 0.1,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        if getgenv().Resolution then
            getgenv().Resolution[".gg/scripters"] = Value
        end
    end,
})

-- FOV Changer
SweatAdvancedGroup:AddToggle("FOVChanger", {
    Text = "Enable FOV Changer",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Save original FOV to restore later
            if not getgenv().OriginalFOV then
                getgenv().OriginalFOV = workspace.Camera.FieldOfView
            end

            -- Set FOV to the value from the slider or default to 120
            workspace.Camera.FieldOfView = Options.FOVValue and Options.FOVValue.Value or 120

            Library:Notify({
                Title = "FOV Changer Enabled",
                Description = "FOV changer is now active",
                Time = 2,
            })
        else
            -- Restore original FOV
            if getgenv().OriginalFOV then
                workspace.Camera.FieldOfView = getgenv().OriginalFOV
            end

            Library:Notify({
                Title = "FOV Changer Disabled",
                Description = "FOV changer is now inactive",
                Time = 2,
            })
        end
    end,
})

-- Low Graphics is now in its own groupbox

SweatAdvancedGroup:AddSlider("FOVValue", {
    Text = "FOV Value",
    Default = 120,
    Min = 70,
    Max = 120,
    Rounding = 0,
    Callback = function(Value)
        -- Only update FOV if FOV Changer is enabled
        if Toggles.FOVChanger and Toggles.FOVChanger.Value then
            workspace.Camera.FieldOfView = Value
        end
    end,
})

-- Movement Tab
local MovementGroup = Tabs.Movement:AddLeftGroupbox("Movement Features")
local MovementAdvancedGroup = Tabs.Movement:AddRightGroupbox("Advanced Movement")

-- Variables for CFrame Fly
local CFspeed = 50
local CFloop = nil

-- CFrame Fly Toggle
MovementGroup:AddToggle("CFlyEnabled", {
    Text = "CFrame Fly",
    Default = false,
    Tooltip = "Enables CFrame flying (bypasses some anti-cheats)",
    Callback = function(Value)
        if Value then
            -- Enable CFrame Fly
            local player = game.Players.LocalPlayer
            player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
            local Head = player.Character:WaitForChild("Head")
            Head.Anchored = true

            if CFloop then CFloop:Disconnect() end

            CFloop = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
                local moveDirection = player.Character:FindFirstChildOfClass('Humanoid').MoveDirection * (CFspeed * deltaTime)
                local headCFrame = Head.CFrame
                local cameraCFrame = workspace.CurrentCamera.CFrame
                local cameraOffset = headCFrame:ToObjectSpace(cameraCFrame).Position
                cameraCFrame = cameraCFrame * CFrame.new(-cameraOffset.X, -cameraOffset.Y, -cameraOffset.Z + 1)
                local cameraPosition = cameraCFrame.Position
                local headPosition = headCFrame.Position

                local objectSpaceVelocity = CFrame.new(cameraPosition, Vector3.new(headPosition.X, cameraPosition.Y, headPosition.Z)):VectorToObjectSpace(moveDirection)
                Head.CFrame = CFrame.new(headPosition) * (cameraCFrame - cameraPosition) * CFrame.new(objectSpaceVelocity)
            end)

            Library:Notify({
                Title = "CFrame Fly Enabled",
                Description = "CFrame flying is now active",
                Time = 2,
            })
        else
            -- Disable CFrame Fly
            if CFloop then
                CFloop:Disconnect()
                local player = game.Players.LocalPlayer
                player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
                local Head = player.Character:WaitForChild("Head")
                Head.Anchored = false

                Library:Notify({
                    Title = "CFrame Fly Disabled",
                    Description = "CFrame flying is now inactive",
                    Time = 2,
                })
            end
        end
    end,
})

-- CFrame Fly Speed Slider
MovementGroup:AddSlider("CFlySpeed", {
    Text = "CFrame Fly Speed",
    Default = 50,
    Min = 10,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        CFspeed = Value
    end,
})

-- WalkSpeed Feature
local WalkSpeedValue = 16
local WalkSpeedLoop = nil
local WalkSpeedCA = nil

MovementGroup:AddToggle("WalkSpeedEnabled", {
    Text = "Enable WalkSpeed",
    Default = false,
    Tooltip = "Changes your character's movement speed",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if Value then
            -- Set walkspeed
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                player.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = WalkSpeedValue
            end

            Library:Notify({
                Title = "WalkSpeed Enabled",
                Description = "WalkSpeed set to " .. WalkSpeedValue,
                Time = 2,
            })
        else
            -- Reset walkspeed to default
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                player.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = 16
            end

            -- Disconnect loop if it exists
            if WalkSpeedLoop then
                WalkSpeedLoop:Disconnect()
                WalkSpeedLoop = nil
            end

            if WalkSpeedCA then
                WalkSpeedCA:Disconnect()
                WalkSpeedCA = nil
            end

            Library:Notify({
                Title = "WalkSpeed Disabled",
                Description = "WalkSpeed reset to default",
                Time = 2,
            })
        end
    end,
})

MovementGroup:AddSlider("WalkSpeedValue", {
    Text = "WalkSpeed Value",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        WalkSpeedValue = Value

        -- Update walkspeed if enabled
        if Toggles.WalkSpeedEnabled and Toggles.WalkSpeedEnabled.Value then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                player.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = Value
            end
        end
    end,
})

MovementGroup:AddToggle("LoopWalkSpeed", {
    Text = "Loop WalkSpeed",
    Default = false,
    Tooltip = "Continuously sets your walkspeed (prevents games from changing it back)",
    Callback = function(Value)
        local player = game.Players.LocalPlayer

        if Value then
            -- Function to set walkspeed
            local function UpdateWalkSpeed()
                if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                    player.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = WalkSpeedValue
                end
            end

            -- Initial set
            UpdateWalkSpeed()

            -- Connect to property changed signal
            local Human = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
            if Human then
                WalkSpeedLoop = Human:GetPropertyChangedSignal("WalkSpeed"):Connect(UpdateWalkSpeed)
            end

            -- Connect to character added
            WalkSpeedCA = player.CharacterAdded:Connect(function(newChar)
                local newHuman = newChar:WaitForChild("Humanoid")
                UpdateWalkSpeed()

                if WalkSpeedLoop then
                    WalkSpeedLoop:Disconnect()
                end

                WalkSpeedLoop = newHuman:GetPropertyChangedSignal("WalkSpeed"):Connect(UpdateWalkSpeed)
            end)

            Library:Notify({
                Title = "Loop WalkSpeed Enabled",
                Description = "Your walkspeed will be maintained at " .. WalkSpeedValue,
                Time = 2,
            })
        else
            -- Disconnect loop
            if WalkSpeedLoop then
                WalkSpeedLoop:Disconnect()
                WalkSpeedLoop = nil
            end

            if WalkSpeedCA then
                WalkSpeedCA:Disconnect()
                WalkSpeedCA = nil
            end

            Library:Notify({
                Title = "Loop WalkSpeed Disabled",
                Description = "WalkSpeed loop stopped",
                Time = 2,
            })
        end
    end,
})

-- Jump Power Feature
local JumpPowerValue = 50
local JumpPowerLoop = nil
local JumpPowerCA = nil

MovementGroup:AddToggle("JumpPowerEnabled", {
    Text = "Enable Jump Power",
    Default = false,
    Tooltip = "Changes how high your character can jump",
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if Value then
            -- Set jump power
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                if player.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
                    player.Character:FindFirstChildOfClass('Humanoid').JumpPower = JumpPowerValue
                else
                    player.Character:FindFirstChildOfClass('Humanoid').JumpHeight = JumpPowerValue / 2.5
                end
            end

            Library:Notify({
                Title = "Jump Power Enabled",
                Description = "Jump Power set to " .. JumpPowerValue,
                Time = 2,
            })
        else
            -- Reset jump power to default
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                if player.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
                    player.Character:FindFirstChildOfClass('Humanoid').JumpPower = 50
                else
                    player.Character:FindFirstChildOfClass('Humanoid').JumpHeight = 7.2
                end
            end

            -- Disconnect loop if it exists
            if JumpPowerLoop then
                JumpPowerLoop:Disconnect()
                JumpPowerLoop = nil
            end

            if JumpPowerCA then
                JumpPowerCA:Disconnect()
                JumpPowerCA = nil
            end

            Library:Notify({
                Title = "Jump Power Disabled",
                Description = "Jump Power reset to default",
                Time = 2,
            })
        end
    end,
})

MovementGroup:AddSlider("JumpPowerValue", {
    Text = "Jump Power Value",
    Default = 50,
    Min = 50,
    Max = 300,
    Rounding = 0,
    Callback = function(Value)
        JumpPowerValue = Value

        -- Update jump power if enabled
        if Toggles.JumpPowerEnabled and Toggles.JumpPowerEnabled.Value then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                if player.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
                    player.Character:FindFirstChildOfClass('Humanoid').JumpPower = Value
                else
                    player.Character:FindFirstChildOfClass('Humanoid').JumpHeight = Value / 2.5
                end
            end
        end
    end,
})

MovementGroup:AddToggle("LoopJumpPower", {
    Text = "Loop Jump Power",
    Default = false,
    Tooltip = "Continuously sets your jump power (prevents games from changing it back)",
    Callback = function(Value)
        local player = game.Players.LocalPlayer

        if Value then
            -- Function to set jump power
            local function UpdateJumpPower()
                if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                    if player.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
                        player.Character:FindFirstChildOfClass('Humanoid').JumpPower = JumpPowerValue
                    else
                        player.Character:FindFirstChildOfClass('Humanoid').JumpHeight = JumpPowerValue / 2.5
                    end
                end
            end

            -- Initial set
            UpdateJumpPower()

            -- Connect to property changed signal
            local Human = player.Character and player.Character:FindFirstChildOfClass('Humanoid')
            if Human then
                if Human.UseJumpPower then
                    JumpPowerLoop = Human:GetPropertyChangedSignal("JumpPower"):Connect(UpdateJumpPower)
                else
                    JumpPowerLoop = Human:GetPropertyChangedSignal("JumpHeight"):Connect(UpdateJumpPower)
                end
            end

            -- Connect to character added
            JumpPowerCA = player.CharacterAdded:Connect(function(newChar)
                local newHuman = newChar:WaitForChild("Humanoid")
                UpdateJumpPower()

                if JumpPowerLoop then
                    JumpPowerLoop:Disconnect()
                end

                if newHuman.UseJumpPower then
                    JumpPowerLoop = newHuman:GetPropertyChangedSignal("JumpPower"):Connect(UpdateJumpPower)
                else
                    JumpPowerLoop = newHuman:GetPropertyChangedSignal("JumpHeight"):Connect(UpdateJumpPower)
                end
            end)

            Library:Notify({
                Title = "Loop Jump Power Enabled",
                Description = "Your jump power will be maintained at " .. JumpPowerValue,
                Time = 2,
            })
        else
            -- Disconnect loop
            if JumpPowerLoop then
                JumpPowerLoop:Disconnect()
                JumpPowerLoop = nil
            end

            if JumpPowerCA then
                JumpPowerCA:Disconnect()
                JumpPowerCA = nil
            end

            Library:Notify({
                Title = "Loop Jump Power Disabled",
                Description = "Jump Power loop stopped",
                Time = 2,
            })
        end
    end,
})

-- Float Feature
local Floating = false
local floatName = "FloatPart_" .. math.random(1000, 9999)
local FloatingFunc = nil
local qUp, eUp, qDown, eDown, floatDied = nil, nil, nil, nil, nil

MovementGroup:AddToggle("FloatEnabled", {
    Text = "Float/Platform",
    Default = false,
    Tooltip = "Creates an invisible platform under you (Q = down, E = up)",
    Callback = function(Value)
        Floating = Value
        local player = game.Players.LocalPlayer
        local pchar = player.Character

        if Value then
            if pchar and not pchar:FindFirstChild(floatName) then
                task.spawn(function()
                    local Float = Instance.new('Part')
                    Float.Name = floatName
                    Float.Parent = pchar
                    Float.Transparency = 1
                    Float.Size = Vector3.new(2, 0.2, 1.5)
                    Float.Anchored = true
                    local FloatValue = -3.1

                    local function getRoot(char)
                        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
                    end

                    Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0, FloatValue, 0)

                    Library:Notify({
                        Title = "Float Enabled",
                        Description = "Float platform active (Q = down & E = up)",
                        Time = 2,
                    })

                    qUp = game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.Q then
                            FloatValue = FloatValue + 0.5
                        end
                    end)

                    eUp = game:GetService("UserInputService").InputEnded:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.E then
                            FloatValue = FloatValue - 1.5
                        end
                    end)

                    qDown = game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.Q then
                            FloatValue = FloatValue - 0.5
                        end
                    end)

                    eDown = game:GetService("UserInputService").InputBegan:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.E then
                            FloatValue = FloatValue + 1.5
                        end
                    end)

                    floatDied = pchar:FindFirstChildOfClass('Humanoid').Died:Connect(function()
                        if FloatingFunc then FloatingFunc:Disconnect() end
                        Float:Destroy()
                        if qUp then qUp:Disconnect() end
                        if eUp then eUp:Disconnect() end
                        if qDown then qDown:Disconnect() end
                        if eDown then eDown:Disconnect() end
                        if floatDied then floatDied:Disconnect() end
                    end)

                    local function FloatPadLoop()
                        if pchar:FindFirstChild(floatName) and getRoot(pchar) then
                            Float.CFrame = getRoot(pchar).CFrame * CFrame.new(0, FloatValue, 0)
                        else
                            if FloatingFunc then FloatingFunc:Disconnect() end
                            Float:Destroy()
                            if qUp then qUp:Disconnect() end
                            if eUp then eUp:Disconnect() end
                            if qDown then qDown:Disconnect() end
                            if eDown then eDown:Disconnect() end
                            if floatDied then floatDied:Disconnect() end
                        end
                    end

                    FloatingFunc = game:GetService("RunService").Heartbeat:Connect(FloatPadLoop)
                end)
            end
        else
            Library:Notify({
                Title = "Float Disabled",
                Description = "Float platform removed",
                Time = 2,
            })

            if pchar:FindFirstChild(floatName) then
                pchar:FindFirstChild(floatName):Destroy()
            end

            if FloatingFunc then FloatingFunc:Disconnect() end
            if qUp then qUp:Disconnect() end
            if eUp then eUp:Disconnect() end
            if qDown then qDown:Disconnect() end
            if eDown then eDown:Disconnect() end
            if floatDied then floatDied:Disconnect() end
        end
    end,
})

-- NoClip Feature
local Clip = true
local Noclipping = nil

MovementAdvancedGroup:AddToggle("NoClipEnabled", {
    Text = "NoClip",
    Default = false,
    Tooltip = "Allows you to walk through walls and objects",
    Callback = function(Value)
        local player = game.Players.LocalPlayer

        if Value then
            -- Enable NoClip
            Clip = false

            local function NoclipLoop()
                if Clip == false and player.Character ~= nil then
                    for _, child in pairs(player.Character:GetDescendants()) do
                        if child:IsA("BasePart") and child.CanCollide == true and child.Name ~= floatName then
                            child.CanCollide = false
                        end
                    end
                end
            end

            Noclipping = game:GetService("RunService").Stepped:Connect(NoclipLoop)

            Library:Notify({
                Title = "NoClip Enabled",
                Description = "You can now walk through objects",
                Time = 2,
            })
        else
            -- Disable NoClip
            if Noclipping then
                Noclipping:Disconnect()
                Noclipping = nil
            end

            Clip = true

            Library:Notify({
                Title = "NoClip Disabled",
                Description = "NoClip is now inactive",
                Time = 2,
            })
        end
    end,
})

-- Infinite Jump Feature
local InfiniteJump = false
local InfiniteJumpConnection = nil

MovementAdvancedGroup:AddToggle("InfiniteJumpEnabled", {
    Text = "Infinite Jump",
    Default = false,
    Tooltip = "Allows you to jump infinitely without waiting for cooldown",
    Callback = function(Value)
        InfiniteJump = Value

        if Value then
            -- Enable Infinite Jump
            InfiniteJumpConnection = game:GetService("UserInputService").JumpRequest:Connect(function()
                if InfiniteJump then
                    local player = game.Players.LocalPlayer
                    if player.Character and player.Character:FindFirstChildOfClass("Humanoid") then
                        player.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)

            Library:Notify({
                Title = "Infinite Jump Enabled",
                Description = "You can now jump infinitely",
                Time = 2,
            })
        else
            -- Disable Infinite Jump
            if InfiniteJumpConnection then
                InfiniteJumpConnection:Disconnect()
                InfiniteJumpConnection = nil
            end

            Library:Notify({
                Title = "Infinite Jump Disabled",
                Description = "Infinite Jump is now inactive",
                Time = 2,
            })
        end
    end,
})

-- Welcome notification
Library:Notify({
    Title = "Universal Aimbot",
    Description = "Aimbot script loaded successfully!\nUse " .. tostring(Options.TriggerKey and Options.TriggerKey.Value or "Right Mouse") .. " to aim.",
    Time = 5,
})