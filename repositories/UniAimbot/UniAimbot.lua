-- Aimbot Script with Vision UI Library v2
-- Ported from Obsidian UI Library to Vision UI Library
-- Created using Exunys Aimbot Module and Vision Library

-- Compatibility functions
getgenv = getgenv or function() return _G end

-- Load Vision Library
local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/Loco-CTO/UI-Library/main/VisionLibV2/source.lua'))()

-- Load Aimbot Module
local AimbotModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Aimbot-V3/main/src/Aimbot.lua"))()

-- Create the main window
local Window = Library:Create({
    Name = "SNOWBIND",
    Footer = "Credit Exunyx and made by SNOWBIND | v1.0.0",
    ToggleKey = Enum.KeyCode.RightShift,
    LoadedCallback = function()
        -- Callback when UI is loaded
    end,
    KeySystem = false, -- Set to true if you want to use a key system
    Key = "123456", -- Your key here
    MaxAttempts = 5,
    DiscordLink = nil, -- Your Discord link here if you have one
})

-- Create tabs
local AimbotTab = Window:Tab({
    Name = "Aimbot",
    Icon = "rbxassetid://11396131982",
    Color = Color3.new(1, 0, 0),
})

local SilentAimTab = Window:Tab({
    Name = "Silent Aim",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(0, 0, 1),
})

local FOVTab = Window:Tab({
    Name = "FOV Settings",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(0, 1, 0),
})

local ESPTab = Window:Tab({
    Name = "ESP",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(1, 1, 0),
})

local PlayersTab = Window:Tab({
    Name = "Players",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(1, 0, 1),
})

local SweatTab = Window:Tab({
    Name = "Sweat",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(0, 1, 1),
})

local MovementTab = Window:Tab({
    Name = "Movement",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(0.5, 0.5, 0.5),
})

local UISettingsTab = Window:Tab({
    Name = "UI Settings",
    Icon = "rbxassetid://11476626403",
    Color = Color3.new(0.7, 0.7, 0.7),
})

-- Aimbot Settings Section
local AimbotSettingsSection = AimbotTab:Section({
    Name = "Aimbot Settings"
})

AimbotSettingsSection:Toggle({
    Name = "Enable Aimbot",
    Default = AimbotModule.Settings.Enabled,
    Callback = function(Value)
        AimbotModule.Settings.Enabled = Value
        if Value then
            Library:Notify({
                Name = "Aimbot Enabled",
                Text = "Aimbot is now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            Library:Notify({
                Name = "Aimbot Disabled",
                Text = "Aimbot is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

AimbotSettingsSection:Dropdown({
    Name = "Lock Part",
    Items = { "Head", "Torso", "HumanoidRootPart", "UpperTorso", "LowerTorso", "Random", "Smart", "Cycle" },
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
                            Name = "Part Cycled",
                            Text = "Now targeting: " .. nextPart,
                            Icon = "rbxassetid://11401835376",
                            Duration = 1,
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
                        Name = "Random Part",
                        Text = "Now targeting: " .. randomPart,
                        Icon = "rbxassetid://11401835376",
                        Duration = 1,
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

AimbotSettingsSection:Dropdown({
    Name = "Lock Mode",
    Items = { "CFrame", "mousemoverel", "Camera", "Hybrid" },
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

AimbotSettingsSection:Slider({
    Name = "Sensitivity",
    Max = 5,
    Min = 0,
    Default = AimbotModule.Settings.Sensitivity,
    Callback = function(Value)
        AimbotModule.Settings.Sensitivity = Value
    end,
})

AimbotSettingsSection:Slider({
    Name = "Mouse Sensitivity",
    Max = 10,
    Min = 0.1,
    Default = AimbotModule.Settings.Sensitivity2,
    Callback = function(Value)
        AimbotModule.Settings.Sensitivity2 = Value
    end,
})

AimbotSettingsSection:Slider({
    Name = "Smoothness",
    Max = 1,
    Min = 0,
    Default = AimbotModule.Settings.Smoothness or 0.5,
    Callback = function(Value)
        AimbotModule.Settings.Smoothness = Value
    end,
})

AimbotSettingsSection:Slider({
    Name = "Aim Assist Strength",
    Max = 1,
    Min = 0,
    Default = AimbotModule.Settings.AimAssistStrength or 1,
    Callback = function(Value)
        AimbotModule.Settings.AimAssistStrength = Value
    end,
})

-- Aimbot Checks Section
local ChecksSection = AimbotTab:Section({
    Name = "Checks"
})

ChecksSection:Toggle({
    Name = "Team Check",
    Default = AimbotModule.Settings.TeamCheck,
    Callback = function(Value)
        AimbotModule.Settings.TeamCheck = Value
    end,
})

ChecksSection:Toggle({
    Name = "Alive Check",
    Default = AimbotModule.Settings.AliveCheck,
    Callback = function(Value)
        AimbotModule.Settings.AliveCheck = Value
    end,
})

ChecksSection:Toggle({
    Name = "Wall Check",
    Default = AimbotModule.Settings.WallCheck,
    Callback = function(Value)
        AimbotModule.Settings.WallCheck = Value
    end,
})

ChecksSection:Toggle({
    Name = "Visibility Check",
    Default = AimbotModule.Settings.VisibilityCheck or false,
    Callback = function(Value)
        AimbotModule.Settings.VisibilityCheck = Value
    end,
})

ChecksSection:Toggle({
    Name = "Distance Check",
    Default = AimbotModule.Settings.DistanceCheck or false,
    Callback = function(Value)
        AimbotModule.Settings.DistanceCheck = Value
    end,
})

ChecksSection:Slider({
    Name = "Max Distance",
    Max = 2000,
    Min = 10,
    Default = AimbotModule.Settings.MaxDistance or 1000,
    Callback = function(Value)
        AimbotModule.Settings.MaxDistance = Value
    end,
})

ChecksSection:Toggle({
    Name = "Health Check",
    Default = AimbotModule.Settings.HealthCheck or false,
    Callback = function(Value)
        AimbotModule.Settings.HealthCheck = Value
    end,
})

ChecksSection:Slider({
    Name = "Min Health %",
    Max = 100,
    Min = 0,
    Default = AimbotModule.Settings.MinHealth or 0,
    Callback = function(Value)
        AimbotModule.Settings.MinHealth = Value
    end,
})

local ToggleModeToggle = ChecksSection:Toggle({
    Name = "Toggle Mode",
    Default = AimbotModule.Settings.Toggle,
    Callback = function(Value)
        AimbotModule.Settings.Toggle = Value
    end,
})

ChecksSection:Keybind({
    Name = "Aimbot Key",
    Default = Enum.KeyCode.E,
    Callback = function()
        -- This will be triggered when the key is pressed
    end,
    UpdateKeyCallback = function(Key)
        -- Handle different key types properly
        if Key == Enum.KeyCode.MouseButton1 then
            AimbotModule.Settings.TriggerKey = Enum.UserInputType.MouseButton1
        elseif Key == Enum.KeyCode.MouseButton2 then
            AimbotModule.Settings.TriggerKey = Enum.UserInputType.MouseButton2
        else
            -- For regular keys, try to convert to KeyCode
            AimbotModule.Settings.TriggerKey = Key
        end
    end,
})

-- Advanced Targeting Section
local TargetingSection = AimbotTab:Section({
    Name = "Advanced Targeting"
})

TargetingSection:Dropdown({
    Name = "Target Priority",
    Items = { "Closest", "Health", "Threat", "Random" },
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

TargetingSection:Toggle({
    Name = "Auto Switch Target",
    Default = AimbotModule.Settings.AutoSwitch or false,
    Callback = function(Value)
        AimbotModule.Settings.AutoSwitch = Value
    end,
})

TargetingSection:Slider({
    Name = "Switch Delay (ms)",
    Max = 2000,
    Min = 0,
    Default = AimbotModule.Settings.SwitchDelay or 500,
    Callback = function(Value)
        AimbotModule.Settings.SwitchDelay = Value
    end,
})

-- Prediction Settings Section
local PredictionSection = AimbotTab:Section({
    Name = "Prediction Settings"
})

PredictionSection:Toggle({
    Name = "Enable Prediction",
    Default = AimbotModule.Settings.OffsetToMoveDirection,
    Callback = function(Value)
        AimbotModule.Settings.OffsetToMoveDirection = Value
    end,
})

PredictionSection:Dropdown({
    Name = "Prediction Method",
    Items = { "Basic", "Velocity", "Advanced", "Adaptive" },
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

PredictionSection:Slider({
    Name = "Prediction Strength",
    Max = 30,
    Min = 1,
    Default = AimbotModule.Settings.OffsetIncrement,
    Callback = function(Value)
        AimbotModule.Settings.OffsetIncrement = Value
    end,
})

PredictionSection:Toggle({
    Name = "Ping Compensation",
    Default = AimbotModule.Settings.PingCompensation or false,
    Callback = function(Value)
        AimbotModule.Settings.PingCompensation = Value
    end,
})

-- Anti-Detection Section
local AntiDetectionSection = AimbotTab:Section({
    Name = "Anti-Detection"
})

AntiDetectionSection:Toggle({
    Name = "Randomize Aim",
    Default = AimbotModule.Settings.RandomizeAim or false,
    Callback = function(Value)
        AimbotModule.Settings.RandomizeAim = Value
    end,
})

AntiDetectionSection:Slider({
    Name = "Randomization",
    Max = 20,
    Min = 0,
    Default = AimbotModule.Settings.RandomizationAmount or 5,
    Callback = function(Value)
        AimbotModule.Settings.RandomizationAmount = Value
    end,
})

AntiDetectionSection:Toggle({
    Name = "Humanize Aim",
    Default = AimbotModule.Settings.HumanizeAim or false,
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

AntiDetectionSection:Toggle({
    Name = "Delayed Aim",
    Default = AimbotModule.Settings.DelayedAim or false,
    Callback = function(Value)
        AimbotModule.Settings.DelayedAim = Value
    end,
})

AntiDetectionSection:Slider({
    Name = "Reaction Time (ms)",
    Max = 500,
    Min = 0,
    Default = AimbotModule.Settings.ReactionTime or 150,
    Callback = function(Value)
        AimbotModule.Settings.ReactionTime = Value
    end,
})

-- FOV Settings Section
local FOVCircleSection = FOVTab:Section({
    Name = "FOV Circle"
})

FOVCircleSection:Toggle({
    Name = "Enable FOV Circle",
    Default = AimbotModule.FOVSettings.Enabled,
    Callback = function(Value)
        AimbotModule.FOVSettings.Enabled = Value
    end,
})

FOVCircleSection:Toggle({
    Name = "Visible",
    Default = AimbotModule.FOVSettings.Visible,
    Callback = function(Value)
        AimbotModule.FOVSettings.Visible = Value
    end,
})

FOVCircleSection:Slider({
    Name = "Radius",
    Max = 500,
    Min = 10,
    Default = AimbotModule.FOVSettings.Radius,
    Callback = function(Value)
        AimbotModule.FOVSettings.Radius = Value
    end,
})

FOVCircleSection:Slider({
    Name = "Thickness",
    Max = 10,
    Min = 1,
    Default = AimbotModule.FOVSettings.Thickness,
    Callback = function(Value)
        AimbotModule.FOVSettings.Thickness = Value
    end,
})

FOVCircleSection:Slider({
    Name = "Number of Sides",
    Max = 100,
    Min = 3,
    Default = AimbotModule.FOVSettings.NumSides,
    Callback = function(Value)
        AimbotModule.FOVSettings.NumSides = Value
    end,
})

FOVCircleSection:Toggle({
    Name = "Filled",
    Default = AimbotModule.FOVSettings.Filled,
    Callback = function(Value)
        AimbotModule.FOVSettings.Filled = Value
    end,
})

-- FOV Colors Section
local FOVColorsSection = FOVTab:Section({
    Name = "FOV Colors"
})

FOVColorsSection:Toggle({
    Name = "Rainbow Color",
    Default = AimbotModule.FOVSettings.RainbowColor,
    Callback = function(Value)
        AimbotModule.FOVSettings.RainbowColor = Value
    end,
})

FOVColorsSection:Toggle({
    Name = "Rainbow Outline",
    Default = AimbotModule.FOVSettings.RainbowOutlineColor,
    Callback = function(Value)
        AimbotModule.FOVSettings.RainbowOutlineColor = Value
    end,
})

FOVColorsSection:Colorpicker({
    Name = "FOV Circle Color",
    DefaultColor = AimbotModule.FOVSettings.Color,
    Callback = function(Color)
        AimbotModule.FOVSettings.Color = Color
    end,
})

FOVColorsSection:Colorpicker({
    Name = "FOV Outline Color",
    DefaultColor = AimbotModule.FOVSettings.OutlineColor,
    Callback = function(Color)
        AimbotModule.FOVSettings.OutlineColor = Color
    end,
})

FOVColorsSection:Toggle({
    Name = "Custom Locked Color",
    Default = false,
    Callback = function(Value)
        -- This can be used to enable/disable custom locked color
    end,
})

FOVColorsSection:Colorpicker({
    Name = "FOV Locked Color",
    DefaultColor = AimbotModule.FOVSettings.LockedColor,
    Callback = function(Color)
        AimbotModule.FOVSettings.LockedColor = Color
    end,
})

FOVColorsSection:Slider({
    Name = "Transparency",
    Max = 1,
    Min = 0,
    Default = AimbotModule.FOVSettings.Transparency,
    Callback = function(Value)
        AimbotModule.FOVSettings.Transparency = Value
    end,
})

-- ESP Settings
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
    Names = false,
    Distances = false,
    Weapons = false,
    Chams = false,

    -- Off-screen indicator settings
    OffScreenArrows = false,
    OffScreenArrowColor = Color3.fromRGB(255, 255, 255),
    OffScreenArrowSize = 16,
    OffScreenArrowRadius = 80,
    OffScreenArrowFilled = true,
    OffScreenArrowTransparency = 0,
    OffScreenArrowThickness = 1,
    OffScreenArrowAntiAliasing = false,

    -- Radar settings
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

-- ESP Implementation
local ESPObjects = {}
local SkeletonESPObjects = {}
local OffScreenArrowObjects = {}
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

-- Helper functions for off-screen arrows
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
    if not DrawingAvailable or not DrawingLib then return {Visible = false, Remove = function() end} end

    local l = DrawingLib.new("Triangle")
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

-- Function to get text bounds (simplified to avoid TextService errors)
local function GetTextBounds(text, size, font)
    -- Use simple approximation to avoid TextService issues
    local charWidth = (size or 14) * 0.6 -- Approximate character width
    local textLength = #tostring(text or "")
    return Vector2.new(textLength * charWidth, size or 14)
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

    -- Create text object for name display if Drawing library supports it
    if DrawingLib and DrawingLib.new then
        library.nameText = DrawingLib.new("Text")
        if library.nameText then
            library.nameText.Visible = false
            library.nameText.Size = 14
            library.nameText.Color = Color3.fromRGB(255, 255, 255)
            library.nameText.Center = true
            library.nameText.Outline = true
            library.nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
            library.nameText.Font = 2 -- Enum.Font.SourceSansBold
            library.nameText.Text = plr.Name
        end
    end

    ESPObjects[plr.Name] = library

    local function Colorize(color)
        for u, x in pairs(library) do
            if x and x.Color and x ~= library.healthbar and x ~= library.greenhealth and x ~= library.blacktracer and x ~= library.black and x ~= library.nameText then
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

                    -- Names Display
                    if ESPSettings.Names and library.nameText then
                        library.nameText.Position = Vector2.new(HumPos.X, HumPos.Y - DistanceY*2 - 15)
                        library.nameText.Visible = true

                        -- Apply team colors to name if team check is enabled
                        if ESPSettings.TeamCheck then
                            if plr.TeamColor == player.TeamColor then
                                library.nameText.Color = ESPSettings.Green
                            else
                                library.nameText.Color = ESPSettings.Red
                            end
                        elseif ESPSettings.TeamColor then
                            library.nameText.Color = plr.TeamColor.Color
                        else
                            library.nameText.Color = Color3.fromRGB(255, 255, 255)
                        end
                    else
                        if library.nameText then
                            library.nameText.Visible = false
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
                Visibility(false, library)
                if game.Players:FindFirstChild(plr.Name) == nil then
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

-- Off-screen arrows function
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

                        SkeletonVisibility(true)

                        -- Team Check and Colors
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
                    end
                else
                    SkeletonVisibility(false)
                end
            else
                SkeletonVisibility(false)
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                    if SkeletonESPObjects[plr.Name] then
                        SkeletonESPObjects[plr.Name] = nil
                    end
                    -- Remove from SkeletonESPConnections tracking
                    if SkeletonESPConnections[plr.Name .. "_skeleton"] then
                        SkeletonESPConnections[plr.Name .. "_skeleton"] = nil
                    end
                end
            end
        end)
        -- Store connection for cleanup
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
                    -- Head
                    local H = camera:WorldToViewportPoint(plr.Character.Head.Position)
                    -- Torso
                    local T = camera:WorldToViewportPoint(plr.Character.Torso.Position)
                    -- Left Arm
                    local LA = camera:WorldToViewportPoint(plr.Character["Left Arm"].Position)
                    -- Right Arm
                    local RA = camera:WorldToViewportPoint(plr.Character["Right Arm"].Position)
                    -- Left Leg
                    local LL = camera:WorldToViewportPoint(plr.Character["Left Leg"].Position)
                    -- Right Leg
                    local RL = camera:WorldToViewportPoint(plr.Character["Right Leg"].Position)

                    -- Head
                    limbs.Head_Spine.From = Vector2.new(H.X, H.Y)
                    limbs.Head_Spine.To = Vector2.new(T.X, T.Y)

                    -- Left Arm
                    limbs.LeftArm.From = Vector2.new(LA.X, LA.Y)
                    limbs.LeftArm.To = Vector2.new(LA.X, LA.Y)

                    limbs.LeftArm_UpperTorso.From = Vector2.new(T.X, T.Y)
                    limbs.LeftArm_UpperTorso.To = Vector2.new(LA.X, LA.Y)

                    -- Right Arm
                    limbs.RightArm.From = Vector2.new(RA.X, RA.Y)
                    limbs.RightArm.To = Vector2.new(RA.X, RA.Y)

                    limbs.RightArm_UpperTorso.From = Vector2.new(T.X, T.Y)
                    limbs.RightArm_UpperTorso.To = Vector2.new(RA.X, RA.Y)

                    -- Left Leg
                    limbs.LeftLeg.From = Vector2.new(LL.X, LL.Y)
                    limbs.LeftLeg.To = Vector2.new(LL.X, LL.Y)

                    limbs.LeftLeg_LowerTorso.From = Vector2.new(T.X, T.Y)
                    limbs.LeftLeg_LowerTorso.To = Vector2.new(LL.X, LL.Y)

                    -- Right Leg
                    limbs.RightLeg.From = Vector2.new(RL.X, RL.Y)
                    limbs.RightLeg.To = Vector2.new(RL.X, RL.Y)

                    limbs.RightLeg_LowerTorso.From = Vector2.new(T.X, T.Y)
                    limbs.RightLeg_LowerTorso.To = Vector2.new(RL.X, RL.Y)

                    SkeletonVisibility(true)

                    -- Team Check and Colors
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
                else
                    SkeletonVisibility(false)
                end
            else
                SkeletonVisibility(false)
                if game.Players:FindFirstChild(plr.Name) == nil then
                    connection:Disconnect()
                    if SkeletonESPObjects[plr.Name] then
                        SkeletonESPObjects[plr.Name] = nil
                    end
                    -- Remove from SkeletonESPConnections tracking
                    if SkeletonESPConnections[plr.Name .. "_skeleton"] then
                        SkeletonESPConnections[plr.Name .. "_skeleton"] = nil
                    end
                end
            end
        end)
        -- Store connection for cleanup
        SkeletonESPConnections[plr.Name .. "_skeleton"] = connection
    end

    if R15 then
        coroutine.wrap(UpdaterR15)()
    else
        coroutine.wrap(UpdaterR6)()
    end
end

-- Initialize ESP for existing players
for _, plr in pairs(game:GetService("Players"):GetPlayers()) do
    if plr ~= player then
        ESP(plr)
        DrawSkeletonESP(plr)
        DrawOffScreenArrows(plr)
    end
end

-- Initialize ESP for new players
game:GetService("Players").PlayerAdded:Connect(function(plr)
    if plr ~= player then
        ESP(plr)
        DrawSkeletonESP(plr)
        DrawOffScreenArrows(plr)
    end
end)

-- Radar implementation
local function NewCircle(transparency, color, radius, filled, thickness)
    if not DrawingAvailable or not DrawingLib then return {Visible = false, Remove = function() end} end

    local c = DrawingLib.new("Circle")
    c.Visible = false
    c.Color = color
    c.Radius = radius
    c.Filled = filled
    c.Thickness = thickness
    c.Transparency = transparency
    c.NumSides = 64
    return c
end

-- Initialize radar
local RadarBackground = NewCircle(0.9, ESPSettings.RadarBack, ESPSettings.RadarRadius, true, 1)
RadarBackground.Visible = ESPSettings.Radar
RadarBackground.Position = ESPSettings.RadarPosition

local RadarBorder = NewCircle(0.75, ESPSettings.RadarBorder, ESPSettings.RadarRadius, false, 3)
RadarBorder.Visible = ESPSettings.Radar
RadarBorder.Position = ESPSettings.RadarPosition

-- ESP Settings Section
local ESPSection = ESPTab:Section({
    Name = "ESP Settings"
})

ESPSection:Toggle({
    Name = "Enable ESP",
    Default = ESPSettings.Enabled,
    Callback = function(Value)
        ESPSettings.Enabled = Value
        if Value then
            -- Initialize ESP
            Library:Notify({
                Name = "ESP Enabled",
                Text = "All ESP features are now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            -- Clean up ESP
            Library:Notify({
                Name = "ESP Disabled",
                Text = "All ESP features are now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

ESPSection:Dropdown({
    Name = "ESP Preset",
    Items = { "Default", "Competitive", "Stealth", "Colorful", "Minimal", "Custom" },
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

        Library:Notify({
            Name = "ESP Preset Applied",
            Text = Value .. " preset has been applied",
            Icon = "rbxassetid://11401835376",
            Duration = 2,
        })
    end,
})

ESPSection:Toggle({
    Name = "Show Boxes",
    Default = ESPSettings.Boxes,
    Callback = function(Value)
        ESPSettings.Boxes = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Tracers",
    Default = ESPSettings.Tracers,
    Callback = function(Value)
        ESPSettings.Tracers = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Health Bars",
    Default = ESPSettings.HealthBars,
    Callback = function(Value)
        ESPSettings.HealthBars = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Skeletons",
    Default = ESPSettings.Skeletons,
    Callback = function(Value)
        ESPSettings.Skeletons = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Off-Screen Arrows",
    Default = ESPSettings.OffScreenArrows,
    Callback = function(Value)
        ESPSettings.OffScreenArrows = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Names",
    Default = ESPSettings.Names,
    Callback = function(Value)
        ESPSettings.Names = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Distances",
    Default = ESPSettings.Distances,
    Callback = function(Value)
        ESPSettings.Distances = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Weapons",
    Default = ESPSettings.Weapons,
    Callback = function(Value)
        ESPSettings.Weapons = Value
    end,
})

ESPSection:Toggle({
    Name = "Show Chams",
    Default = ESPSettings.Chams,
    Callback = function(Value)
        ESPSettings.Chams = Value
    end,
})

ESPSection:Dropdown({
    Name = "Tracer Origin",
    Items = { "Bottom", "Middle" },
    Callback = function(Value)
        ESPSettings.Tracer_Origin = Value
    end,
})

ESPSection:Toggle({
    Name = "Tracer Follow Mouse",
    Default = ESPSettings.Tracer_FollowMouse,
    Callback = function(Value)
        ESPSettings.Tracer_FollowMouse = Value
    end,
})

ESPSection:Slider({
    Name = "Box Thickness",
    Max = 5,
    Min = 1,
    Default = ESPSettings.Box_Thickness,
    Callback = function(Value)
        ESPSettings.Box_Thickness = Value
    end,
})

ESPSection:Slider({
    Name = "Tracer Thickness",
    Max = 5,
    Min = 1,
    Default = ESPSettings.Tracer_Thickness,
    Callback = function(Value)
        ESPSettings.Tracer_Thickness = Value
    end,
})

ESPSection:Slider({
    Name = "Skeleton Thickness",
    Max = 5,
    Min = 1,
    Default = ESPSettings.Skeleton_Thickness,
    Callback = function(Value)
        ESPSettings.Skeleton_Thickness = Value
    end,
})

-- ESP Colors Section
local ESPColorsSection = ESPTab:Section({
    Name = "ESP Colors"
})

ESPColorsSection:Toggle({
    Name = "Custom Box Color",
    Default = true,
    Callback = function(Value)
        ESPSettings.UseCustomBoxColor = Value
    end,
})

ESPColorsSection:Colorpicker({
    Name = "ESP Box Color",
    DefaultColor = ESPSettings.Box_Color,
    Callback = function(Color)
        ESPSettings.Box_Color = Color
    end,
})

ESPColorsSection:Toggle({
    Name = "Custom Tracer Color",
    Default = true,
    Callback = function(Value)
        ESPSettings.UseCustomTracerColor = Value
    end,
})

ESPColorsSection:Colorpicker({
    Name = "ESP Tracer Color",
    DefaultColor = ESPSettings.Tracer_Color,
    Callback = function(Color)
        ESPSettings.Tracer_Color = Color
    end,
})

ESPColorsSection:Toggle({
    Name = "Custom Skeleton Color",
    Default = true,
    Callback = function(Value)
        ESPSettings.UseCustomSkeletonColor = Value
    end,
})

ESPColorsSection:Colorpicker({
    Name = "ESP Skeleton Color",
    DefaultColor = ESPSettings.Skeleton_Color,
    Callback = function(Color)
        ESPSettings.Skeleton_Color = Color
    end,
})

ESPColorsSection:Toggle({
    Name = "Team Check",
    Default = ESPSettings.TeamCheck,
    Callback = function(Value)
        ESPSettings.TeamCheck = Value
    end,
})

ESPColorsSection:Toggle({
    Name = "Team Color",
    Default = ESPSettings.TeamColor,
    Callback = function(Value)
        ESPSettings.TeamColor = Value
    end,
})

ESPColorsSection:Colorpicker({
    Name = "Teammate Color",
    DefaultColor = ESPSettings.Green,
    Callback = function(Color)
        ESPSettings.Green = Color
    end,
})

ESPColorsSection:Colorpicker({
    Name = "Enemy Color",
    DefaultColor = ESPSettings.Red,
    Callback = function(Color)
        ESPSettings.Red = Color
    end,
})

-- Players Tab
local PlayersSection = PlayersTab:Section({
    Name = "Player Management"
})

-- Create a dropdown for player selection
local playerList = {}
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    if player ~= game:GetService("Players").LocalPlayer then
        table.insert(playerList, player.Name)
    end
end

PlayersSection:Dropdown({
    Name = "Select Player",
    Items = playerList,
    Callback = function(Value)
        getgenv().SelectedPlayer = Value
    end,
})

PlayersSection:Button({
    Name = "Blacklist Player",
    Callback = function()
        if getgenv().SelectedPlayer then
            AimbotModule:Blacklist(getgenv().SelectedPlayer)
            Library:Notify({
                Name = "Player Blacklisted",
                Text = "Blacklisted: " .. getgenv().SelectedPlayer,
                Icon = "rbxassetid://11401835376",
                Duration = 3,
            })
        else
            Library:Notify({
                Name = "No Player Selected",
                Text = "Please select a player first!",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

PlayersSection:Button({
    Name = "Whitelist Player",
    Callback = function()
        if getgenv().SelectedPlayer then
            pcall(function()
                AimbotModule:Whitelist(getgenv().SelectedPlayer)
                Library:Notify({
                    Name = "Player Whitelisted",
                    Text = "Whitelisted: " .. getgenv().SelectedPlayer,
                    Icon = "rbxassetid://11401835376",
                    Duration = 3,
                })
            end)
        else
            Library:Notify({
                Name = "No Player Selected",
                Text = "Please select a player first!",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

-- Control Buttons
local ControlSection = PlayersTab:Section({
    Name = "Aimbot Control"
})

ControlSection:Button({
    Name = "Start Aimbot",
    Callback = function()
        if not AimbotModule.Loaded then
            AimbotModule.Load()
            Library:Notify({
                Name = "Aimbot Started",
                Text = "Aimbot module initialized successfully!",
                Icon = "rbxassetid://11401835376",
                Duration = 3,
            })
        else
            Library:Notify({
                Name = "Already Running",
                Text = "Aimbot is already active!",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

ControlSection:Button({
    Name = "Restart Aimbot",
    Callback = function()
        AimbotModule.Restart()
        Library:Notify({
            Name = "Aimbot Restarted",
            Text = "Aimbot module has been restarted!",
            Icon = "rbxassetid://11401835376",
            Duration = 3,
        })
    end,
})

ControlSection:Button({
    Name = "Get Closest Player",
    Callback = function()
        local closest = AimbotModule.GetClosestPlayer()
        if closest then
            Library:Notify({
                Name = "Closest Player Found",
                Text = "Closest Player: " .. closest.Name,
                Icon = "rbxassetid://11401835376",
                Duration = 3,
            })
        else
            Library:Notify({
                Name = "No Target Found",
                Text = "No player found in FOV range",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

-- Silent Aim Settings
local SilentAimSettings = {
    Enabled = false,
    TeamCheck = false,
    VisibleCheck = false,
    TargetPart = "HumanoidRootPart",
    SilentAimMethod = "Raycast",

    FOVRadius = 130,
    FOVVisible = false,
    ShowSilentAimTarget = false,

    MouseHitPrediction = false,
    MouseHitPredictionAmount = 0.165,
    HitChance = 100
}

-- Silent Aim Tab Implementation
local SilentAimMainSection = SilentAimTab:Section({
    Name = "Silent Aim Settings"
})

SilentAimMainSection:Toggle({
    Name = "Enable Silent Aim",
    Default = SilentAimSettings.Enabled,
    Callback = function(Value)
        SilentAimSettings.Enabled = Value
        if Value then
            Library:Notify({
                Name = "Silent Aim Enabled",
                Text = "Silent Aim is now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            Library:Notify({
                Name = "Silent Aim Disabled",
                Text = "Silent Aim is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

SilentAimMainSection:Toggle({
    Name = "Team Check",
    Default = SilentAimSettings.TeamCheck,
    Callback = function(Value)
        SilentAimSettings.TeamCheck = Value
    end,
})

SilentAimMainSection:Toggle({
    Name = "Visible Check",
    Default = SilentAimSettings.VisibleCheck,
    Callback = function(Value)
        SilentAimSettings.VisibleCheck = Value
    end,
})

SilentAimMainSection:Dropdown({
    Name = "Target Part",
    Items = { "Head", "HumanoidRootPart", "Torso", "UpperTorso", "LowerTorso", "Random" },
    Callback = function(Value)
        SilentAimSettings.TargetPart = Value
    end,
})

SilentAimMainSection:Dropdown({
    Name = "Silent Aim Method",
    Items = {
        "Raycast",
        "FindPartOnRay",
        "FindPartOnRayWithWhitelist",
        "FindPartOnRayWithIgnoreList",
        "Mouse.Hit/Target"
    },
    Callback = function(Value)
        SilentAimSettings.SilentAimMethod = Value
    end,
})

SilentAimMainSection:Slider({
    Name = "Hit Chance (%)",
    Max = 100,
    Min = 0,
    Default = SilentAimSettings.HitChance,
    Callback = function(Value)
        SilentAimSettings.HitChance = Value
    end,
})

-- FOV Settings for Silent Aim
local SilentAimFOVSection = SilentAimTab:Section({
    Name = "FOV Settings"
})

SilentAimFOVSection:Toggle({
    Name = "Show FOV Circle",
    Default = SilentAimSettings.FOVVisible,
    Callback = function(Value)
        SilentAimSettings.FOVVisible = Value
    end,
})

SilentAimFOVSection:Slider({
    Name = "FOV Circle Radius",
    Max = 500,
    Min = 10,
    Default = SilentAimSettings.FOVRadius,
    Callback = function(Value)
        SilentAimSettings.FOVRadius = Value
    end,
})

SilentAimFOVSection:Toggle({
    Name = "Show Silent Aim Target",
    Default = SilentAimSettings.ShowSilentAimTarget,
    Callback = function(Value)
        SilentAimSettings.ShowSilentAimTarget = Value
    end,
})

SilentAimFOVSection:Colorpicker({
    Name = "FOV Circle Color",
    DefaultColor = Color3.fromRGB(54, 57, 241),
    Callback = function(Color)
        -- Update FOV circle color
    end,
})

SilentAimFOVSection:Colorpicker({
    Name = "Target Indicator Color",
    DefaultColor = Color3.fromRGB(54, 57, 241),
    Callback = function(Color)
        -- Update target indicator color
    end,
})

-- Prediction Settings for Silent Aim
local SilentAimPredictionSection = SilentAimTab:Section({
    Name = "Prediction Settings"
})

SilentAimPredictionSection:Toggle({
    Name = "Mouse.Hit/Target Prediction",
    Default = SilentAimSettings.MouseHitPrediction,
    Callback = function(Value)
        SilentAimSettings.MouseHitPrediction = Value
    end,
})

SilentAimPredictionSection:Slider({
    Name = "Prediction Amount",
    Max = 1,
    Min = 0.001,
    Default = SilentAimSettings.MouseHitPredictionAmount,
    Callback = function(Value)
        SilentAimSettings.MouseHitPredictionAmount = Value
    end,
})

-- Sweat Tab
local SweatAdvancedSection = SweatTab:Section({
    Name = "Sweat Settings"
})

-- Create a separate section for Low Graphics
local LowGraphicsSection = SweatTab:Section({
    Name = "Low Graphics Settings"
})

-- Add Low Graphics toggle to its own section
LowGraphicsSection:Toggle({
    Name = "Enable Low Graphics",
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
                Name = "Low Graphics Enabled",
                Text = "Low graphics mode is now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
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
                Name = "Low Graphics Disabled",
                Text = "Low graphics mode is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

-- Stretch Resolution
SweatAdvancedSection:Toggle({
    Name = "Enable Stretch Resolution",
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
                Name = "Stretch Resolution Enabled",
                Text = "Stretch resolution is now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            -- Disable stretch resolution (reset to default)
            if getgenv().Resolution then
                getgenv().Resolution[".gg/scripters"] = 1
            end

            Library:Notify({
                Name = "Stretch Resolution Disabled",
                Text = "Stretch resolution is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

SweatAdvancedSection:Slider({
    Name = "Stretch Amount",
    Max = 10,
    Min = 1,
    Default = 5,
    Callback = function(Value)
        if getgenv().Resolution then
            -- Convert from 1-10 scale to 1-0.1 scale (inverted)
            -- 1 on slider = 1 (no stretch)
            -- 10 on slider = 0.1 (maximum stretch)
            local stretchValue = 1 - (Value - 1) / 9 * 0.9
            getgenv().Resolution[".gg/scripters"] = stretchValue
        end
    end,
})

-- FOV Changer
SweatAdvancedSection:Toggle({
    Name = "Enable FOV Changer",
    Default = false,
    Callback = function(Value)
        if Value then
            -- Save original FOV to restore later
            if not getgenv().OriginalFOV then
                getgenv().OriginalFOV = workspace.Camera.FieldOfView
            end

            -- Set FOV to the value from the slider or default to 120
            workspace.Camera.FieldOfView = 120

            Library:Notify({
                Name = "FOV Changer Enabled",
                Text = "FOV changer is now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            -- Restore original FOV
            if getgenv().OriginalFOV then
                workspace.Camera.FieldOfView = getgenv().OriginalFOV
            end

            Library:Notify({
                Name = "FOV Changer Disabled",
                Text = "FOV changer is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

SweatAdvancedSection:Slider({
    Name = "FOV Value",
    Max = 120,
    Min = 70,
    Default = 120,
    Callback = function(Value)
        -- Only update FOV if FOV Changer is enabled
        workspace.Camera.FieldOfView = Value
    end,
})

-- Movement Tab
local MovementSection = MovementTab:Section({
    Name = "Movement Features"
})

local MovementAdvancedSection = MovementTab:Section({
    Name = "Advanced Movement"
})

-- Variables for CFrame Fly
local CFspeed = 50
local CFloop = nil

-- CFrame Fly Toggle
MovementSection:Toggle({
    Name = "CFrame Fly",
    Default = false,
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
                Name = "CFrame Fly Enabled",
                Text = "CFrame flying is now active",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
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
                    Name = "CFrame Fly Disabled",
                    Text = "CFrame flying is now inactive",
                    Icon = "rbxassetid://11401835376",
                    Duration = 2,
                })
            end
        end
    end,
})

MovementSection:Slider({
    Name = "CFrame Fly Speed",
    Max = 200,
    Min = 10,
    Default = 50,
    Callback = function(Value)
        CFspeed = Value
    end,
})

-- WalkSpeed Feature
local WalkSpeedValue = 16
local WalkSpeedLoop = nil
local WalkSpeedCA = nil

MovementSection:Toggle({
    Name = "Enable WalkSpeed",
    Default = false,
    Callback = function(Value)
        local player = game.Players.LocalPlayer
        if Value then
            -- Set walkspeed
            if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
                player.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = WalkSpeedValue
            end

            Library:Notify({
                Name = "WalkSpeed Enabled",
                Text = "WalkSpeed set to " .. WalkSpeedValue,
                Icon = "rbxassetid://11401835376",
                Duration = 2,
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
                Name = "WalkSpeed Disabled",
                Text = "WalkSpeed reset to default",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

MovementSection:Slider({
    Name = "WalkSpeed Value",
    Max = 200,
    Min = 16,
    Default = 16,
    Callback = function(Value)
        WalkSpeedValue = Value

        -- Update walkspeed if enabled
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
            player.Character:FindFirstChildOfClass('Humanoid').WalkSpeed = Value
        end
    end,
})

MovementSection:Toggle({
    Name = "Loop WalkSpeed",
    Default = false,
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
                Name = "Loop WalkSpeed Enabled",
                Text = "Your walkspeed will be maintained at " .. WalkSpeedValue,
                Icon = "rbxassetid://11401835376",
                Duration = 2,
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
                Name = "Loop WalkSpeed Disabled",
                Text = "WalkSpeed loop stopped",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

-- Jump Power Feature
local JumpPowerValue = 50
local JumpPowerLoop = nil
local JumpPowerCA = nil

MovementSection:Toggle({
    Name = "Enable Jump Power",
    Default = false,
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
                Name = "Jump Power Enabled",
                Text = "Jump Power set to " .. JumpPowerValue,
                Icon = "rbxassetid://11401835376",
                Duration = 2,
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
                Name = "Jump Power Disabled",
                Text = "Jump Power reset to default",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

MovementSection:Slider({
    Name = "Jump Power Value",
    Max = 300,
    Min = 50,
    Default = 50,
    Callback = function(Value)
        JumpPowerValue = Value

        -- Update jump power if enabled
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
            if player.Character:FindFirstChildOfClass('Humanoid').UseJumpPower then
                player.Character:FindFirstChildOfClass('Humanoid').JumpPower = Value
            else
                player.Character:FindFirstChildOfClass('Humanoid').JumpHeight = Value / 2.5
            end
        end
    end,
})

-- Float Feature
local Floating = false
local floatName = "FloatPart_" .. math.random(1000, 9999)
local FloatingFunc = nil
local qUp, eUp, qDown, eDown, floatDied = nil, nil, nil, nil, nil

MovementSection:Toggle({
    Name = "Float/Platform",
    Default = false,
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
                        Name = "Float Enabled",
                        Text = "Float platform active (Q = down & E = up)",
                        Icon = "rbxassetid://11401835376",
                        Duration = 2,
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
                Name = "Float Disabled",
                Text = "Float platform removed",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
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

MovementAdvancedSection:Toggle({
    Name = "NoClip",
    Default = false,
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
                Name = "NoClip Enabled",
                Text = "You can now walk through objects",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            -- Disable NoClip
            if Noclipping then
                Noclipping:Disconnect()
                Noclipping = nil
            end

            Clip = true

            Library:Notify({
                Name = "NoClip Disabled",
                Text = "NoClip is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

-- Infinite Jump Feature
local InfiniteJump = false
local InfiniteJumpConnection = nil

MovementAdvancedSection:Toggle({
    Name = "Infinite Jump",
    Default = false,
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
                Name = "Infinite Jump Enabled",
                Text = "You can now jump infinitely",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        else
            -- Disable Infinite Jump
            if InfiniteJumpConnection then
                InfiniteJumpConnection:Disconnect()
                InfiniteJumpConnection = nil
            end

            Library:Notify({
                Name = "Infinite Jump Disabled",
                Text = "Infinite Jump is now inactive",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })
        end
    end,
})

-- UI Settings Tab
local UISettingsSection = UISettingsTab:Section({
    Name = "UI Settings"
})

UISettingsSection:Toggle({
    Name = "Darkmode",
    Default = true,
    Callback = function(Value)
        if Value then
            Library:SetTheme({
                Main = Color3.fromRGB(45, 45, 45),
                Secondary = Color3.fromRGB(31, 31, 31),
                Tertiary = Color3.fromRGB(31, 31, 31),
                Text = Color3.fromRGB(255, 255, 255),
                PlaceholderText = Color3.fromRGB(175, 175, 175),
                Textbox = Color3.fromRGB(61, 61, 61),
                NavBar = Color3.fromRGB(35, 35, 35),
                Theme = Color3.fromRGB(232, 202, 35),
            })
        else
            Library:SetTheme({
                Main = Color3.fromRGB(238, 238, 238),
                Secondary = Color3.fromRGB(194, 194, 194),
                Tertiary = Color3.fromRGB(163, 163, 163),
                Text = Color3.fromRGB(0, 0, 0),
                PlaceholderText = Color3.fromRGB(15, 15, 15),
                Textbox = Color3.fromRGB(255, 255, 255),
                NavBar = Color3.fromRGB(239, 239, 239),
                Theme = Color3.fromRGB(232, 55, 55),
            })
        end
    end,
})

UISettingsSection:Button({
    Name = "Hide UI",
    Callback = function()
        Window:Toggled(false)
        task.wait(3)
        Window:Toggled(true)
    end,
})

UISettingsSection:Button({
    Name = "Task Bar Only",
    Callback = function()
        Window:TaskBarOnly(true)
        task.wait(3)
        Window:TaskBarOnly(false)
    end,
})

UISettingsSection:Keybind({
    Name = "Toggle UI Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        -- This will be triggered when the key is pressed
    end,
    UpdateKeyCallback = function(Key)
        Window:ChangeTogglekey(Key)
    end,
})

UISettingsSection:Button({
    Name = "Unload Script",
    Callback = function()
        -- Clean up function
        local function cleanupAndUnload()
            -- Show notification before unloading
            Library:Notify({
                Name = "Unloading GUI",
                Text = "Cleaning up all objects...",
                Icon = "rbxassetid://11401835376",
                Duration = 2,
            })

            -- Make sure the aimbot is disabled by setting its Enabled property to false
            if getgenv().ExunysDeveloperAimbot and getgenv().ExunysDeveloperAimbot.Settings then
                getgenv().ExunysDeveloperAimbot.Settings.Enabled = false
            end

            -- Clean up aimbot and FOV circles properly
            local AimbotEnvironment = getgenv().ExunysDeveloperAimbot
            if AimbotEnvironment then
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
            Library:Destroy()
        end

        cleanupAndUnload()
    end,
})

-- Silent Aim FOV Circle Implementation
local silent_fov_circle = nil

-- Function to create or recreate the FOV circle
local function CreateSilentAimFOVCircle()
    -- Clean up existing circle if it exists
    if silent_fov_circle and silent_fov_circle.Remove then
        pcall(function() silent_fov_circle:Remove() end)
    end

    -- Check if Drawing library is available
    if not DrawingAvailable or not DrawingLib then
        warn("Drawing library not available for FOV circle")
        return
    end

    -- Create FOV circle
    silent_fov_circle = DrawingLib.new("Circle")
    silent_fov_circle.Thickness = 1
    silent_fov_circle.NumSides = 100
    silent_fov_circle.Radius = SilentAimSettings.FOVRadius
    silent_fov_circle.Filled = false
    silent_fov_circle.Visible = SilentAimSettings.FOVVisible
    silent_fov_circle.ZIndex = 999
    silent_fov_circle.Transparency = 1
    silent_fov_circle.Color = Color3.fromRGB(54, 57, 241)

    -- Set initial position to mouse position for consistency
    local success, mousePos = pcall(function()
        return game:GetService("UserInputService"):GetMouseLocation()
    end)

    if success and mousePos then
        silent_fov_circle.Position = mousePos
    else
        -- Fallback to center of screen if getting mouse position fails
        silent_fov_circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    end
end

-- Create the FOV circle initially
CreateSilentAimFOVCircle()

-- Update FOV circle when settings change
SilentAimFOVSection:Toggle({
    Name = "Show FOV Circle",
    Default = SilentAimSettings.FOVVisible,
    Callback = function(Value)
        SilentAimSettings.FOVVisible = Value

        -- Try to update existing FOV circle
        if silent_fov_circle then
            silent_fov_circle.Visible = Value
        end

        -- If FOV circle doesn't exist or is invalid, recreate it
        if not silent_fov_circle or not pcall(function() return silent_fov_circle.Visible end) then
            CreateSilentAimFOVCircle()
        end
    end,
})

SilentAimFOVSection:Slider({
    Name = "FOV Circle Radius",
    Max = 500,
    Min = 10,
    Default = SilentAimSettings.FOVRadius,
    Callback = function(Value)
        SilentAimSettings.FOVRadius = Value

        -- Try to update existing FOV circle
        if silent_fov_circle then
            silent_fov_circle.Radius = Value
        end

        -- If FOV circle doesn't exist or is invalid, recreate it
        if not silent_fov_circle or not pcall(function() return silent_fov_circle.Radius end) then
            CreateSilentAimFOVCircle()
        end
    end,
})

SilentAimFOVSection:Colorpicker({
    Name = "FOV Circle Color",
    DefaultColor = Color3.fromRGB(54, 57, 241),
    Callback = function(Color)
        -- Try to update existing FOV circle
        if silent_fov_circle then
            silent_fov_circle.Color = Color
        end

        -- If FOV circle doesn't exist or is invalid, recreate it
        if not silent_fov_circle or not pcall(function() return silent_fov_circle.Color end) then
            CreateSilentAimFOVCircle()
        end
    end,
})

-- Set up a RenderStepped connection to update the FOV circle position
local fovCircleUpdateConnection = game:GetService("RunService").RenderStepped:Connect(function()
    -- Use pcall to catch any errors and prevent the connection from breaking
    local success, err = pcall(function()
        if silent_fov_circle and SilentAimSettings.FOVVisible then
            -- Get current mouse position using UserInputService for better accuracy
            local mouseSuccess, mousePos = pcall(function()
                return game:GetService("UserInputService"):GetMouseLocation()
            end)

            if mouseSuccess and mousePos then
                -- Update FOV circle position
                silent_fov_circle.Position = mousePos
                silent_fov_circle.Visible = true
            else
                -- Fallback to center of screen if getting mouse position fails
                silent_fov_circle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                silent_fov_circle.Visible = true
            end
        elseif silent_fov_circle then
            silent_fov_circle.Visible = false
        end
    end)

    -- If there's an error, try to recreate the FOV circle
    if not success and err then
        warn("FOV Circle update error:", err)
        pcall(function() CreateSilentAimFOVCircle() end)
    end
end)

-- Set up a heartbeat connection to monitor and maintain the FOV circle
local heartbeatConnection = game:GetService("RunService").Heartbeat:Connect(function()
    pcall(function()
        -- Check if the FOV circle is still valid
        if not silent_fov_circle or not pcall(function() return silent_fov_circle.Visible end) then
            -- Recreate the FOV circle if it's invalid
            CreateSilentAimFOVCircle()
            return
        end

        -- Double-check that the FOV circle is following the mouse when it should
        if silent_fov_circle and SilentAimSettings.FOVVisible and silent_fov_circle.Visible then
            local mouseSuccess, mousePos = pcall(function()
                return game:GetService("UserInputService"):GetMouseLocation()
            end)

            if mouseSuccess and mousePos then
                -- If the circle position is significantly different from mouse position, update it
                local distance = (silent_fov_circle.Position - mousePos).Magnitude
                if distance > 5 then -- Allow small differences due to timing
                    silent_fov_circle.Position = mousePos
                end
            end
        end
    end)
end)

-- Add cleanup for FOV circle to the unload function
local originalCleanupAndUnload = cleanupAndUnload
cleanupAndUnload = function()
    -- Clean up FOV circle
    if silent_fov_circle and silent_fov_circle.Remove then
        pcall(function() silent_fov_circle:Remove() end)
        silent_fov_circle = nil
    end

    -- Disconnect update connection
    if fovCircleUpdateConnection then
        fovCircleUpdateConnection:Disconnect()
        fovCircleUpdateConnection = nil
    end

    -- Disconnect heartbeat connection
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end

    -- Call original cleanup function
    originalCleanupAndUnload()
end

-- Initialize the aimbot
AimbotModule.Load()
AimbotModule.Loaded = true

-- Welcome notification
Library:Notify({
    Name = "Universal Aimbot",
    Text = "Aimbot script loaded successfully!",
    Icon = "rbxassetid://11401835376",
    Duration = 5,
})
