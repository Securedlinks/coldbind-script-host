-- Dig Script using Obsidian Library
-- Created with Auto Equip Shovel and Auto Dig functionality

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local autoEquipEnabled = false
local autoDigEnabled = false
local autoSellInventoryEnabled = false
local autoSellItemEnabled = false
local autoWalkEnabled = false
local hoverEnabled = false
local autoEquipConnection = nil
local autoDigConnection = nil
local autoSellItemConnection = nil
local autoWalkConnection = nil
local hoverConnection = nil
local updatePositionConnection = nil -- For teleport tab position tracking
local selectedNPC = nil -- Variable for Teleport tab
local lastDigPosition = nil -- For auto walk functionality
local lastAutoWalkTime = 0 -- Timer for continuous auto walk
local autoWalkInterval = 3 -- Move every 3 seconds in auto walk mode

-- Zone bypass variables
local noDig_bypass_enabled = false
local noDig_last_check = 0 -- Rate limit to prevent ping spikes

-- Low Graphics variables
local lowGraphicsEnabled = false

-- Hover system variables
local hoverHeight = 5 -- Height in studs to hover above ground
local originalWalkSpeed = 16 -- Store original walkspeed
local bodyPosition = nil -- BodyPosition object for hovering
local bodyVelocity = nil -- BodyVelocity for smooth movement

-- Create Window
local Window = Library:CreateWindow({
    Title = "COLDBIND",
    Footer = "Auto Dig & Equip Tools",
    Icon = 128685627581112,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

-- Create Tabs
local Tabs = {
    Dig = Window:AddTab("Dig", "pickaxe"),
    Sell = Window:AddTab("Sell", "dollar-sign"),
    Teleport = Window:AddTab("Teleport", "map-pin"),
    Quest = Window:AddTab("Quest", "scroll"),
    Boss = Window:AddTab("Boss", "skull"),
    World = Window:AddTab("World", "globe"),
    Player = Window:AddTab("Player", "user"),
    ["UI Settings"] = Window:AddTab("UI Settings", "settings")
}

-- Create main groupbox for dig functions
local DigGroupBox = Tabs.Dig:AddLeftGroupbox("Dig Functions", "tool")

-- Auto Equip Shovel Function
local function autoEquipShovel()
    if not autoEquipEnabled then return end

    local character = LocalPlayer.Character
    if not character then return end

    -- Check if player already has a tool equipped
    local currentTool = character:FindFirstChildOfClass("Tool")
    if currentTool then
        -- Check if it's a shovel
        if string.find(currentTool.Name:lower(), "shovel") then
            return -- Already has shovel equipped
        end
    end

    -- Try to equip shovel from backpack
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        -- First try to find a shovel specifically
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "shovel") then
                tool.Parent = character
                print("🔧 Auto-equipped shovel:", tool.Name)
                return
            end
        end

        -- If no shovel found, try to equip any digging tool
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local toolName = tool.Name:lower()
                if string.find(toolName, "dig") or string.find(toolName, "pick") or string.find(toolName, "mine") then
                    tool.Parent = character
                    print("🔧 Auto-equipped digging tool:", tool.Name)
                    return
                end
            end
        end
    end
end

-- Enhanced Bar Control Function (SUPER EXTREME BYPASS from SimpleDig)
local function controlPlayerBar()
    local character = LocalPlayer.Character
    if not character then return false end

    -- Check if minigame is active
    local digUI = PlayerGui:FindFirstChild("Dig")
    if not digUI then return false end

    -- TREASURE-SAFE: Modified approach to ensure treasure collection works properly
    -- Instead of aggressively bypassing the minigame, we'll complete it properly

    -- First, check if there's a treasure collection UI that we need to be careful with
    local treasureUI = false
    pcall(function()
        -- Look for common treasure-related UI elements
        for _, child in pairs(digUI:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("ImageLabel") then
                local name = child.Name:lower()
                if string.find(name, "treasure") or string.find(name, "reward") or
                        string.find(name, "collect") or string.find(name, "item") or
                        string.find(name, "loot") then
                    treasureUI = true
                    break
                end
            end
        end
    end)

    -- If we detected treasure UI, be extra careful
    if treasureUI then
        -- Don't manipulate the UI directly, just focus on completing the minigame
        -- We'll handle this in the main game loop
        return false
    end

    -- If no treasure UI detected, we can try a more direct approach
    -- but still be careful not to break the treasure collection
    pcall(function()
        local character = LocalPlayer.Character
        if character then
            local shovel = character:FindFirstChildOfClass("Tool")
            if shovel then
                -- Only fire the most essential remote events with safe arguments
                for _, remoteName in pairs({"OnDigSuccessRemote", "SuccessEvent"}) do
                    local remote = shovel:FindFirstChild(remoteName)
                    if remote and remote:IsA("RemoteEvent") then
                        pcall(function() remote:FireServer("success") end)
                        -- Minimal delay to allow game to process
                        task.wait(0.01)
                    end
                end

                -- Activate the tool normally
                pcall(function() shovel:Activate() end)
                task.wait(0.01) -- Minimal wait for activation to register
            end
        end
    end)

    local safezone = digUI:FindFirstChild("Safezone")
    if not safezone then return false end

    -- TREASURE-SAFE: Be more careful with UI manipulation
    -- Instead of hiding the entire safezone, we'll focus on just the minigame elements

    local holder = safezone:FindFirstChild("Holder")
    if not holder then return false end

    -- Check for treasure-related UI again at this level
    local treasureUIInHolder = false
    pcall(function()
        for _, child in pairs(holder:GetDescendants()) do
            if child:IsA("Frame") or child:IsA("TextLabel") or child:IsA("ImageLabel") then
                local name = child.Name:lower()
                if string.find(name, "treasure") or string.find(name, "reward") or
                        string.find(name, "collect") or string.find(name, "item") or
                        string.find(name, "loot") then
                    treasureUIInHolder = true
                    break
                end
            end
        end
    end)

    -- If treasure UI is detected in the holder, be extra careful
    if treasureUIInHolder then
        -- Don't manipulate holder elements, just focus on the player bar and strong area
    else
        -- If no treasure UI in holder, we can carefully manipulate some elements
        -- but avoid manipulating all elements at once
        pcall(function()
            -- Only manipulate non-critical UI elements
            for _, child in pairs(holder:GetChildren()) do
                if child:IsA("Frame") or child:IsA("ImageLabel") then
                    -- Skip elements that might be related to treasure collection
                    local name = child.Name:lower()
                    if not (string.find(name, "player") or string.find(name, "bar") or
                            string.find(name, "area") or string.find(name, "strong") or
                            string.find(name, "treasure") or string.find(name, "reward") or
                            string.find(name, "collect") or string.find(name, "item")) then
                        -- Quick toggle visibility with minimal delay
                        child.Visible = false
                        task.delay(0.01, function()
                            if child and child.Parent then
                                child.Visible = true
                            end
                        end)
                    end
                end
            end
        end)
    end

    local playerBar = holder:FindFirstChild("PlayerBar")
    local areaStrong = holder:FindFirstChild("Area_Strong")

    if not playerBar or not areaStrong then return false end
    if not areaStrong.Visible or areaStrong.AbsoluteSize.X < 2 then return false end

    -- Get strong area position
    local strongLeft = areaStrong.Position.X.Scale
    local strongRight = strongLeft + areaStrong.Size.X.Scale
    local strongCenter = strongLeft + (areaStrong.Size.X.Scale / 2)

    -- EXTREME SPEED: Try to instantly complete the minigame without visual delay

    -- 1. Force bar to center of strong area with no animation
    pcall(function()
        -- Disable any tweens that might be running
        playerBar:CancelTweens()
        -- Force position directly (no tween)
        playerBar.Position = UDim2.new(strongCenter, 0, playerBar.Position.Y.Scale, 0)
        -- Force to front - skip any animations
        playerBar.ZIndex = 10
        -- Try to manipulate properties to force success
        playerBar.Size = areaStrong.Size -- Make bar same size as strong area
    end)

    -- 2. Trigger space input with reduced inputs to prevent freezing
    local VIM = game:GetService("VirtualInputManager")
    if VIM then
        -- Reduced number of inputs to prevent overload
        for i = 1, 3 do -- Reduced from 10 to 3
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            -- No delay between inputs for maximum speed
        end
    end

    -- 3. Try to exploit remote events with reduced calls to prevent server overload
    pcall(function()
        local shovel = character:FindFirstChildOfClass("Tool")
        if shovel then
            -- Try to trigger remote events directly (for bypassing dig mechanics)
            -- Reduced number of remotes and arguments to prevent overload
            for _, remoteName in pairs({"OnDigSuccessRemote", "CompleteEvent", "SuccessEvent"}) do
                local remote = shovel:FindFirstChild(remoteName)
                if remote and remote:IsA("RemoteEvent") then
                    -- Reduced arguments to just the most important ones
                    remote:FireServer("success")
                    -- No delay between calls for maximum speed
                end
            end

            -- Try to directly invoke the tool's functions
            shovel:Activate()
        end
    end)

    -- 4. Try to manipulate UI elements to force completion - ENHANCED
    pcall(function()
        -- Try to bypass the UI check by hiding safezone or completing UI
        if holder:FindFirstChild("Base") then
            holder.Base.Visible = false
        end

        -- Try to manipulate all UI elements to force completion
        for _, child in pairs(holder:GetChildren()) do
            if child ~= playerBar and child ~= areaStrong then
                pcall(function() child.Visible = false end)
            end
        end

        -- Set position again to ensure it's in the right place
        playerBar.Position = UDim2.new(strongCenter, 0, playerBar.Position.Y.Scale, 0)

        -- Try to force the game to think the bar is in the strong area
        if holder:FindFirstChild("Hit") then
            holder.Hit.Visible = true
        end
    end)

    return true
end

-- HYPER SPEED Auto Hit Function (Complete version from SimpleDig)
local function autoStrongHit()
    if not autoDigEnabled then return end

    -- Enhanced zone bypass for _NoDig areas (OPTIMIZED)
    if noDig_bypass_enabled then
        local currentTime = tick()
        -- Only run every 1 second to reduce ping
        if currentTime - noDig_last_check >= 1 then
            noDig_last_check = currentTime

            pcall(function()
                -- Temporarily disable zone checking by manipulating the _NoDig zone
                local world = workspace:FindFirstChild("World")
                if world then
                    local zones = world:FindFirstChild("Zones")
                    if zones then
                        local noDig = zones:FindFirstChild("_NoDig")
                        if noDig then
                            -- Temporarily disable the _NoDig zone by setting it as inactive
                            for _, part in pairs(noDig:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                    part.CanTouch = false
                                    part.CanQuery = false
                                    part.Transparency = 1
                                end
                            end
                        end
                    end
                end

                -- Also try to bypass any client-side zone validation
                local character = LocalPlayer.Character
                if character then
                    local zone = character:FindFirstChild("Zone")
                    if zone and zone.Value and zone.Value:find("NoDig") then
                        -- Temporarily change zone to allow digging
                        zone.Value = "Fernhill Forest" -- Safe zone that allows digging
                    end
                end
            end)
        end
    end

    -- TREASURE-SAFE: Modified to ensure treasure collection works properly
    task.spawn(function()
        pcall(function()
            -- Try to find the main dig UI only (more targeted approach)
            local digUI = PlayerGui:FindFirstChild("Dig")
            if digUI and digUI:IsA("ScreenGui") then
                -- Instead of disabling the entire UI, we'll just manipulate the minigame elements
                -- This ensures the treasure collection process isn't interrupted

                local safezone = digUI:FindFirstChild("Safezone")
                if safezone then
                    -- Find the strong area and player bar to complete the minigame properly
                    local holder = safezone:FindFirstChild("Holder")
                    if holder then
                        local playerBar = holder:FindFirstChild("PlayerBar")
                        local areaStrong = holder:FindFirstChild("Area_Strong")

                        if playerBar and areaStrong and areaStrong.Visible then
                            -- Position the bar in the strong area to trigger success
                            local strongCenter = areaStrong.Position.X.Scale + (areaStrong.Size.X.Scale / 2)
                            pcall(function()
                                playerBar:CancelTweens()
                                playerBar.Position = UDim2.new(strongCenter, 0, playerBar.Position.Y.Scale, 0)
                                playerBar.Size = areaStrong.Size
                            end)

                            -- Minimal wait time for the game to register the hit
                            task.wait(0.01)

                            -- Trigger the success UI elements
                            if holder:FindFirstChild("Hit") then
                                holder.Hit.Visible = true
                            end
                            if holder:FindFirstChild("Success") then
                                holder.Success.Visible = true
                            end
                        end
                    end
                end
            end
        end)
    end)

    -- Always attempt to initiate a dig if no minigame is active
    local digUI = PlayerGui:FindFirstChild("Dig")
    if not digUI then
        -- Try to trigger a dig with the equipped tool - ENHANCED
        pcall(function()
            local character = LocalPlayer.Character
            if not character then return end

            local shovel = character:FindFirstChildOfClass("Tool")
            if not shovel then
                -- Try to equip shovel from backpack - ENHANCED to try all tools
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    -- First try to find a shovel
                    for _, tool in pairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") and string.find(tool.Name:lower(), "shovel") then
                            tool.Parent = character
                            shovel = tool
                            break
                        end
                    end

                    -- If no shovel found, try any tool
                    if not shovel then
                        for _, tool in pairs(backpack:GetChildren()) do
                            if tool:IsA("Tool") then
                                tool.Parent = character
                                shovel = tool
                                break
                            end
                        end
                    end
                end
            end

            if shovel then
                -- ULTRA-FAST activation to start dig
                for i = 1, 10 do -- Increased for faster execution
                    shovel:Activate()
                    -- No delay between activations for maximum speed

                    -- Try one dig-related method at a time with error handling
                    if i == 1 and shovel.Dig then
                        pcall(function() shovel:Dig() end)
                    elseif i == 2 and shovel.Mine then
                        pcall(function() shovel:Mine() end)
                    elseif i == 3 and shovel.StartDigging then
                        pcall(function() shovel:StartDigging() end)
                    end
                end

                -- Try direct remote bypass - REDUCED to prevent overload
                for _, remoteName in pairs({
                    "OnDigSuccessRemote", "CompleteEvent", "SuccessEvent"
                }) do
                    local remote = shovel:FindFirstChild(remoteName)
                    if remote and remote:IsA("RemoteEvent") then
                        -- Reduced arguments to just the most important ones
                        pcall(function() remote:FireServer("success") end)
                        -- No delay between calls for maximum speed
                    end
                end

                -- Try a LIMITED number of remote events in the tool
                local remoteCount = 0
                for _, child in pairs(shovel:GetDescendants()) do
                    if child:IsA("RemoteEvent") and remoteCount < 3 then
                        pcall(function() child:FireServer("success") end)
                        remoteCount = remoteCount + 1
                        -- No delay between calls for maximum speed
                    end
                end
            end
        end)

        -- Try to simulate key presses that might trigger digging (reduced)
        local VIM = game:GetService("VirtualInputManager")
        if VIM then
            -- Only use Space key to reduce input load
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            -- No delay after input for maximum speed
        end

        return
    end

    -- If minigame is active, try SUPER EXTREME bar control
    if controlPlayerBar() then
        -- After successful bar control, try to IMMEDIATELY start next dig with NO DELAY
        for i = 1, 3 do -- Try multiple times to ensure it works
            task.spawn(function()
                -- Try to immediately activate tool again for next dig
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        local shovel = character:FindFirstChildOfClass("Tool")
                        if shovel then
                            shovel:Activate()

                            -- Try to fire all possible remote events
                            for _, child in pairs(shovel:GetDescendants()) do
                                if child:IsA("RemoteEvent") then
                                    pcall(function() child:FireServer() end)
                                    pcall(function() child:FireServer("success") end)
                                end
                            end
                        end
                    end
                end)
            end)
        end
        return
    end

    -- Last resort: try enhanced strong area detection and manipulation
    local safezone = digUI:FindFirstChild("Safezone")
    if not safezone then return end

    -- Try to manipulate the entire safezone to force completion
    pcall(function()
        safezone.Visible = false
        task.delay(0.01, function() safezone.Visible = true end)
    end)

    local holder = safezone:FindFirstChild("Holder")
    if not holder then return end

    -- Try to manipulate all holder elements to force completion
    for _, child in pairs(holder:GetChildren()) do
        pcall(function()
            if child:IsA("Frame") or child:IsA("ImageLabel") then
                child.Visible = false
                task.delay(0.01, function() child.Visible = true end)
            end
        end)
    end

    local playerBar = holder:FindFirstChild("PlayerBar")
    local areaStrong = holder:FindFirstChild("Area_Strong")

    if not playerBar or not areaStrong then return end
    if not areaStrong.Visible or areaStrong.AbsoluteSize.X < 2 then return end

    -- Get positions
    local playerPos = playerBar.Position.X.Scale
    local strongLeft = areaStrong.Position.X.Scale
    local strongRight = strongLeft + areaStrong.Size.X.Scale
    local strongCenter = strongLeft + (areaStrong.Size.X.Scale / 2)

    -- Force bar to match strong area exactly
    pcall(function()
        -- Cancel any animations
        playerBar:CancelTweens()
        -- Make bar same size as strong area for guaranteed hit
        playerBar.Size = areaStrong.Size
        -- Force position to center of strong area
        playerBar.Position = UDim2.new(strongCenter, 0, playerBar.Position.Y.Scale, 0)
        -- Force to front
        playerBar.ZIndex = 10
    end)

    -- Reduced inputs to prevent freezing while still ensuring it registers
    local VIM = game:GetService("VirtualInputManager")
    if VIM then
        for i = 1, 10 do -- Increased for faster execution
            VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            -- No delay between inputs for maximum speed
        end
    end

    -- Try to force success UI elements to appear (with safety checks)
    pcall(function()
        if holder and holder.Parent then
            if holder:FindFirstChild("Hit") then
                holder.Hit.Visible = true
            end
            if holder:FindFirstChild("Success") then
                holder.Success.Visible = true
            end
        end
    end)
end

-- Auto Walk Function
local function autoWalk()
    if not autoWalkEnabled then return end

    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")
        if not humanoidRootPart or not humanoid then return end

        -- Check if player finished digging (no dig UI active)
        local digUI = PlayerGui:FindFirstChild("Dig")
        if digUI then
            -- Still digging, save current position as last dig position
            lastDigPosition = humanoidRootPart.Position
            return
        end


        -- Regular auto walk behavior (after digging)
        if lastDigPosition then
            local currentPosition = humanoidRootPart.Position
            local distanceFromLastDig = (currentPosition - lastDigPosition).Magnitude

            -- If we're still close to the last dig spot (within 5 studs), move away
            if distanceFromLastDig < 5 then
                -- Generate random walk direction
                local randomAngle = math.random() * math.pi * 2
                local walkDistance = math.random(3, 7) -- Random distance between 3-7 studs

                -- Calculate new position
                local newPosition = currentPosition + Vector3.new(
                        math.cos(randomAngle) * walkDistance,
                        0,
                        math.sin(randomAngle) * walkDistance
                )

                -- Move to new position
                humanoid:MoveTo(newPosition)
                print("🚶 Auto Walk: Moving away from dig spot")

                -- Wait a bit for the movement to complete
                task.wait(2)

                -- Clear the last dig position so we don't keep moving
                lastDigPosition = nil
            end
        end
    end)
end

-- Add Auto Equip Shovel Toggle
DigGroupBox:AddToggle("AutoEquipShovel", {
    Text = "Auto Equip Shovel",
    Tooltip = "Automatically equips shovel when not equipped",
    Default = false,

    Callback = function(Value)
        autoEquipEnabled = Value

        if autoEquipEnabled then
            print("🔧 Auto Equip Shovel ENABLED")

            -- Start auto equip loop
            autoEquipConnection = RunService.Heartbeat:Connect(autoEquipShovel)
        else
            print("🔧 Auto Equip Shovel DISABLED")

            -- Stop auto equip loop
            if autoEquipConnection then
                autoEquipConnection:Disconnect()
                autoEquipConnection = nil
            end
        end
    end,
})

-- Add Auto Dig Toggle
DigGroupBox:AddToggle("AutoDig", {
    Text = "Auto Dig",
    Tooltip = "Automatically completes dig mini-games and initiates digging",
    Default = false,

    Callback = function(Value)
        autoDigEnabled = Value

        if autoDigEnabled then
            print("⚡ Auto Dig ENABLED - Mini-game will be skipped!")

            -- ULTRA-FAST ACTIVATION: Run the auto hit function multiple times to ensure immediate response
            for i = 1, 5 do -- Run 5 times immediately for instant activation
                task.spawn(function()
                    pcall(autoStrongHit)
                end)
            end

            -- Start auto dig loop with multiple connections for maximum speed
            local renderConnection = RunService.RenderStepped:Connect(function()
                for i = 1, 3 do -- Run 3 times per frame for ultra-fast execution
                    task.spawn(function()
                        pcall(autoStrongHit)
                    end)
                end
            end)

            local heartbeatConnection = RunService.Heartbeat:Connect(function()
                task.spawn(function()
                    pcall(autoStrongHit)
                end)
            end)

            autoDigConnection = {
                Disconnect = function()
                    renderConnection:Disconnect()
                    heartbeatConnection:Disconnect()
                end
            }

            -- Try to trigger dig UI completion (ULTRA-FAST TREASURE-SAFE version)
            -- Run multiple times to ensure instant completion
            for i = 1, 3 do -- Run 3 times for maximum reliability
                task.spawn(function()
                    -- Only target the main Dig UI instead of searching all GUIs
                    local digUI = PlayerGui:FindFirstChild("Dig")
                    if digUI and digUI:IsA("ScreenGui") then
                        -- Instead of disabling the entire UI, we'll focus on completing the minigame properly
                        pcall(function()
                            local safezone = digUI:FindFirstChild("Safezone")
                            if safezone then
                                local holder = safezone:FindFirstChild("Holder")
                                if holder then
                                    -- Find and manipulate the player bar and strong area
                                    local playerBar = holder:FindFirstChild("PlayerBar")
                                    local areaStrong = holder:FindFirstChild("Area_Strong")

                                    if playerBar and areaStrong and areaStrong.Visible then
                                        -- Position the bar in the strong area to trigger success
                                        local strongCenter = areaStrong.Position.X.Scale + (areaStrong.Size.X.Scale / 2)
                                        playerBar:CancelTweens()
                                        playerBar.Position = UDim2.new(strongCenter, 0, playerBar.Position.Y.Scale, 0)
                                        playerBar.Size = areaStrong.Size

                                        -- No wait for ultra-fast execution
                                        -- Trigger success UI elements immediately
                                        if holder:FindFirstChild("Hit") then
                                            holder.Hit.Visible = true
                                        end
                                        if holder:FindFirstChild("Success") then
                                            holder.Success.Visible = true
                                        end
                                    end
                                end
                            end
                        end)
                    end
                end)
            end

            print("⚡⚡⚡ ULTRA-FAST Auto Strong Hit ENABLED - MINI-GAME WILL BE INSTANTLY SKIPPED!")
            print("🚀 Running at MAXIMUM SPEED for instant treasure collection!")
            print("💎 TREASURE PROTECTION ACTIVE - Your treasures will be collected properly!")
        else
            print("⚡ Auto Dig DISABLED")

            -- Stop auto dig loops
            if autoDigConnection then
                autoDigConnection:Disconnect()
                autoDigConnection = nil
            end
        end
    end,
})

-- Add Auto Walk Toggle
DigGroupBox:AddToggle("AutoWalk", {
    Text = "Auto Walk",
    Tooltip = "Automatically moves player after digging to avoid cooldown",
    Default = false,

    Callback = function(Value)
        autoWalkEnabled = Value

        if autoWalkEnabled then
            print("🚶 Auto Walk ENABLED - Will move continuously!")

            -- Start auto walk loop with higher frequency for continuous movement
            autoWalkConnection = RunService.Heartbeat:Connect(function()
                autoWalk()
            end)
        else
            print("🚶 Auto Walk DISABLED")

            -- Stop auto walk loop
            if autoWalkConnection then
                autoWalkConnection:Disconnect()
                autoWalkConnection = nil
            end

            -- Reset last dig position
            lastDigPosition = nil
        end
    end,
})

-- Add _NoDig Zone Bypass Toggle
DigGroupBox:AddToggle("DigAnywhere", {
    Text = "DigAnywhere",
    Tooltip = "Bypasses the _NoDig zone restrictions to allow digging anywhere",
    Default = false,

    Callback = function(Value)
        noDig_bypass_enabled = Value

        if noDig_bypass_enabled then
            print("🔓 _NoDig Zone Bypass ENABLED - Can now dig in restricted areas!")

            -- Immediately apply the bypass to current _NoDig zone if it exists
            task.spawn(function()
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local noDig = workspace:FindFirstChild("_NoDig")

                if noDig then
                    print("🔓 Found _NoDig zone, applying bypass...")

                    -- Disable all collision, touch, query and set transparency for all parts in _NoDig
                    local function disableNoDig(parent)
                        for _, obj in pairs(parent:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                obj.CanCollide = false
                                obj.CanTouch = false
                                obj.CanQuery = false
                                obj.Transparency = 0.8
                            end
                        end
                    end

                    disableNoDig(noDig)
                    print("🔓 _NoDig zone disabled - all parts made non-collidable and transparent")
                end

                -- Override player's zone if currently in _NoDig
                local replicator = ReplicatedStorage:FindFirstChild("ClientReplicator")
                if replicator then
                    local zoneRemote = replicator:FindFirstChild("Zone")
                    if zoneRemote and zoneRemote:IsA("RemoteEvent") then
                        local currentZone = LocalPlayer:GetAttribute("Zone")
                        if currentZone == "_NoDig" then
                            print("🔓 Player in _NoDig zone, overriding to Fernhill Forest...")
                            zoneRemote:FireServer("Fernhill Forest")
                            LocalPlayer:SetAttribute("Zone", "Fernhill Forest")
                        end
                    end
                end
            end)
        else
            print("🔒 _NoDig Zone Bypass DISABLED - Zone restrictions restored")

            -- Restore the _NoDig zone restrictions
            task.spawn(function()
                local noDig = workspace:FindFirstChild("_NoDig")

                if noDig then
                    print("🔒 Restoring _NoDig zone restrictions...")

                    -- Re-enable collision, touch, query and reset transparency for all parts in _NoDig
                    local function restoreNoDig(parent)
                        for _, obj in pairs(parent:GetDescendants()) do
                            if obj:IsA("BasePart") then
                                obj.CanCollide = true
                                obj.CanTouch = true
                                obj.CanQuery = true
                                obj.Transparency = 0
                            end
                        end
                    end

                    restoreNoDig(noDig)
                    print("🔒 _NoDig zone restored - all parts made collidable and opaque")
                end
            end)
        end
    end,
})

-- Sell Tab Variables and Functions
local sellInventoryLoop = nil

-- Add a debug function to see what's available
local function debugReplicatedStorage()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    print("=== ReplicatedStorage Debug ===")

    -- List all children in ReplicatedStorage
    for _, child in pairs(ReplicatedStorage:GetChildren()) do
        print("ReplicatedStorage child:", child.Name, "-", child.ClassName)

        -- If it's the Remotes folder, list its contents
        if child.Name == "Remotes" then
            print("  Remotes contents:")
            for _, remote in pairs(child:GetChildren()) do
                print("    -", remote.Name, "-", remote.ClassName)
            end
        end

        -- If it's DialogueRemotes, list its contents
        if child.Name == "DialogueRemotes" then
            print("  DialogueRemotes contents:")
            for _, remote in pairs(child:GetChildren()) do
                print("    -", remote.Name, "-", remote.ClassName)
            end
        end
    end
    print("=== End Debug ===")
end

local function autoSellInventory()
    if not autoSellInventoryEnabled then return end

    spawn(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local Players = game:GetService("Players")
        local localPlayer = Players.LocalPlayer

        -- Get Rocky NPC reference (needed for selling)
        local rocky = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("NPCs") and workspace.World.NPCs:FindFirstChild("Rocky")
        if not rocky then
            print("⚠️ Cannot sell inventory - Rocky NPC not found!")
            return
        end

        -- Try DialogueRemotes
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")
        if not dialogueRemotes then
            print("⚠️ Cannot sell inventory - DialogueRemotes not found!")
            return
        end

        local sellHeldItem = dialogueRemotes:FindFirstChild("SellHeldItem")
        if not sellHeldItem then
            print("⚠️ Cannot sell inventory - SellHeldItem remote not found!")
            return
        end

        -- Method 1: Try to sell all items one by one from backpack
        -- This mimics the manual selling process that all players can use
        local itemsSold = 0
        local backpack = localPlayer:FindFirstChild("Backpack")

        if backpack then
            local tools = {}
            -- Collect all tools first to avoid modifying while iterating
            for _, item in pairs(backpack:GetChildren()) do
                if item:IsA("Tool") then
                    table.insert(tools, item)
                end
            end

            -- Sell each tool individually
            for _, tool in pairs(tools) do
                local success = pcall(function()
                    -- Temporarily equip the tool to sell it
                    localPlayer.Character.Humanoid:EquipTool(tool)
                    wait(0.1) -- Small delay to ensure equipping completes

                    -- Now sell it using the same method as "Sell Item"
                    sellHeldItem:FireServer(tool, rocky)
                    itemsSold = itemsSold + 1
                end)

                if not success then
                    print("⚠️ Failed to sell item:", tool.Name)
                end

                wait(0.2) -- Small delay between sales to avoid spam
            end
        end

        -- Also try to sell any currently equipped item
        local character = localPlayer.Character
        if character then
            for _, item in pairs(character:GetChildren()) do
                if item:IsA("Tool") then
                    local success = pcall(function()
                        sellHeldItem:FireServer(item, rocky)
                        itemsSold = itemsSold + 1
                    end)

                    if not success then
                        print("⚠️ Failed to sell equipped item:", item.Name)
                    end
                    break -- Only one equipped item at a time
                end
            end
        end

        if itemsSold > 0 then
            print("💰 Auto-sold "..itemsSold.." items from inventory!")
        else
            print("⚠️ No items found to sell in inventory")
        end

        -- Fallback: Try the gamepass method (works only for gamepass owners)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local sellRemote = remotes:FindFirstChild("Player_SellInventory")
            if sellRemote then
                pcall(function()
                    sellRemote:FireServer()
                    print("💰 Also attempted gamepass sell (if you have Sell Anywhere gamepass)")
                end)
            end
        end
    end)
end

local function autoSellItem()
    if not autoSellItemEnabled then return end

    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("SellHeldItem") then
            -- Only check for equipped tool in character's hand
            local character = LocalPlayer.Character
            if character then
                local equippedTool = character:FindFirstChildOfClass("Tool")

                if equippedTool then
                    -- Found a tool equipped, try to sell it
                    local rocky = workspace:FindFirstChild("World") and workspace.World:FindFirstChild("NPCs") and workspace.World.NPCs:FindFirstChild("Rocky")
                    if rocky then
                        dialogueRemotes.SellHeldItem:FireServer(equippedTool, rocky)
                        print("💎 Auto-sold equipped item:", equippedTool.Name)
                    else
                        -- Try without Rocky parameter
                        dialogueRemotes.SellHeldItem:FireServer(equippedTool)
                        print("💎 Auto-sold equipped item (no NPC):", equippedTool.Name)
                    end
                else
                    -- No tool equipped, nothing to sell
                    print("⚠️ No item equipped to sell")
                end
            end
        else
            print("⚠️ SellHeldItem remote not found in DialogueRemotes")
        end
    end)
end

-- Create sell groupbox
local SellGroupBox = Tabs.Sell:AddLeftGroupbox("Sell Functions", "dollar-sign")

-- Add Auto Sell Inventory Toggle
SellGroupBox:AddToggle("AutoSellInventory", {
    Text = "Auto Sell Inventory",
    Tooltip = "Automatically sells entire inventory every 10 seconds",
    Default = false,

    Callback = function(Value)
        autoSellInventoryEnabled = Value

        if autoSellInventoryEnabled then
            print("💰 Auto Sell Inventory ENABLED (every 10 seconds)")

            -- Start auto sell inventory loop (10 second intervals)
            task.spawn(function()
                while autoSellInventoryEnabled do
                    autoSellInventory()
                    task.wait(10) -- 10 second delay between sells
                end
            end)
        else
            print("💰 Auto Sell Inventory DISABLED")
        end
    end,
})

-- Add Auto Sell Item Toggle
SellGroupBox:AddToggle("AutoSellItem", {
    Text = "Auto Sell Items",
    Tooltip = "Automatically sells individual items",
    Default = false,

    Callback = function(Value)
        autoSellItemEnabled = Value

        if autoSellItemEnabled then
            print("💎 Auto Sell Items ENABLED")

            -- Start auto sell item loop (safe rate to prevent kick)
            autoSellItemConnection = RunService.Heartbeat:Connect(function()
                task.wait(3) -- 3 second delay between item sells for safety
                autoSellItem()
            end)
        else
            print("💎 Auto Sell Items DISABLED")

            -- Stop auto sell item loop
            if autoSellItemConnection then
                autoSellItemConnection:Disconnect()
                autoSellItemConnection = nil
            end
        end
    end,
})

-- Teleport Tab Functionality
-- Variables for Teleport tab
local selectedNPC = nil
local selectedPurchasable = nil

-- Create teleport groupbox in Teleport tab
local NPCTeleportBox = Tabs.Teleport:AddLeftGroupbox("NPC Teleport", "users")

-- Add teleport function
local function teleportToNPC(npcName)
    if not npcName then return end

    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        local world = workspace:FindFirstChild("World")
        if not world then return end

        local npcs = world:FindFirstChild("NPCs")
        if not npcs then return end

        local npc = npcs:FindFirstChild(npcName)
        if not npc then return end

        -- Find a suitable part to teleport to
        local targetPart = npc.PrimaryPart or npc:FindFirstChildOfClass("Part") or npc:FindFirstChildOfClass("MeshPart")
        if not targetPart then return end

        -- Calculate position slightly in front of NPC
        local npcCFrame = targetPart.CFrame
        local teleportCFrame = npcCFrame * CFrame.new(0, 0, 3) -- 3 studs in front of NPC

        -- Teleport
        humanoidRootPart.CFrame = teleportCFrame
        print("🧙 Teleported to " .. npcName)
    end)
end

-- Build NPC list from the images you provided
local npcList = {
    "Albert", "Andrew", "Andy", "Annabelle", "Annie Rae", "Appraiser",
    "Arthur Dig", "Ava Carter", "Banker", "Barry", "Berry Dust", "Billy Joe",
    "Blueshroom", "Blueshroom Merchant", "Brooke Kali", "Bu Ran", "Carly Enzo",
    "Cave Worker", "Chad", "Chaiya Ran", "Cindy", "Cole Blood", "Collin", "Dani Snow",
    "Discoshroom", "Drawstick Liz", "Erin Field", "Ethan Bands", "Ferry Conductor",
    "Finka", "Gary Bull", "Granny Glenda", "Grant Thorn", "Hale", "Jane", "Jenn Diamond",
    "Jie Ran", "Jim Diamond", "John", "Kei Ran", "Kira Pale", "Magnet Cave Worker",
    "Magnus", "Malcom Wheels", "Mark Lever", "Max", "Merchant Cart", "Mourning Family Member",
    "Mr.Salty", "Mrs.Salty", "Mrs.Tiki", "Mushroom Azali", "Mushroom Researcher", "Nate",
    "Ninja Deciple", "O'Myers", "Old Blueshroom", "Penguin Customer", "Penguin Mechanic",
    "Pete R.", "Pizza Penguin", "Purple Imp", "Rocky", "Sam Colby", "Silver",
    "Sleeping Salesman", "Smith", "Sophie Stone", "Soten Ran", "Steve Levi", "Stranded Steve",
    "Sydney", "Tom Baker", "Tribe Leader", "Tribes Mate", "Will", "Wise Oak", "Young Guitarist",
    "Zoho Ran"
}

-- Create dropdown for NPCs
NPCTeleportBox:AddDropdown("NPCDropdown", {
    Text = "Select NPC",
    Tooltip = "Choose an NPC to teleport to",
    Values = npcList,
    Default = 1, -- First NPC in the list

    Callback = function(Value)
        selectedNPC = Value
        print("Selected NPC: " .. Value)
    end
})

-- Add teleport button
NPCTeleportBox:AddButton({
    Text = "Teleport to NPC",
    Func = function()
        if selectedNPC then
            teleportToNPC(selectedNPC)
        else
            print("⚠️ Please select an NPC first")
        end
    end,
    Tooltip = "Teleport to the selected NPC",
})



-- Purchasables Teleport groupbox
local PurchasablesBox = Tabs.Teleport:AddLeftGroupbox("Teleport to Purchasables", "shopping-cart")

-- Function to teleport to purchasable items
local function teleportToPurchasable(itemName)
    if not itemName then return end

    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        local world = workspace:FindFirstChild("World")
        if not world then return end

        -- Look in Interactive/Purchaseable folder first (correct path from workspace explorer)
        local interactive = world:FindFirstChild("Interactive")
        if interactive then
            local purchaseable = interactive:FindFirstChild("Purchaseable")
            if purchaseable then
                local item = purchaseable:FindFirstChild(itemName)
                if item then
                    local targetPart = nil

                    -- Handle different types of objects
                    if item:IsA("Model") then
                        -- For models, try PrimaryPart first
                        targetPart = item.PrimaryPart
                        if not targetPart then
                            -- AGGRESSIVE SEARCH: Search through ALL descendants for ANY teleportable part
                            local function findAnyPart(obj)
                                -- Try the object itself first
                                if obj:IsA("Part") or obj:IsA("MeshPart") or obj:IsA("BasePart") or obj:IsA("SpawnLocation") then
                                    return obj
                                end

                                -- Search all descendants
                                for _, descendant in pairs(obj:GetDescendants()) do
                                    if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("BasePart") or descendant:IsA("SpawnLocation") then
                                        return descendant
                                    end
                                end

                                return nil
                            end

                            targetPart = findAnyPart(item)

                            -- If still nothing found, try to get position from the model itself
                            if not targetPart then
                                -- Check if the model has a CFrame we can use
                                local success, modelCFrame = pcall(function()
                                    return item:GetBoundingBox()
                                end)

                                if success and modelCFrame then
                                    -- Create a virtual teleport position using the model's bounding box
                                    local teleportCFrame = modelCFrame * CFrame.new(0, 0, 5)
                                    humanoidRootPart.CFrame = teleportCFrame
                                    print("🛒 Teleported to " .. itemName .. " (using model bounding box)")
                                    return
                                end
                            end
                        end
                    elseif item:IsA("Part") or item:IsA("MeshPart") then
                        -- Direct part/meshpart
                        targetPart = item
                    else
                        -- For other types, search descendants
                        for _, child in pairs(item:GetDescendants()) do
                            if child:IsA("Part") or child:IsA("MeshPart") or child:IsA("BasePart") then
                                targetPart = child
                                break
                            end
                        end
                    end

                    if targetPart then
                        -- Calculate position slightly in front of item
                        local itemCFrame = targetPart.CFrame
                        local teleportCFrame = itemCFrame * CFrame.new(0, 0, 5) -- 5 studs in front for models

                        -- Teleport
                        humanoidRootPart.CFrame = teleportCFrame
                        print("🛒 Teleported to " .. itemName .. " (found as " .. item.ClassName .. " using " .. targetPart.ClassName .. ")")
                        return
                    else
                        print("⚠️ Found " .. itemName .. " but no valid teleport target (no parts found)")
                        print("🔍 " .. itemName .. " children:")
                        for _, child in pairs(item:GetChildren()) do
                            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
                        end
                        return
                    end
                end
            end
        end

        -- If not found in Interactive/Purchaseable, try other locations
        local locations = {"Interactive", "Important", "NPCs"}
        for _, location in ipairs(locations) do
            local folder = world:FindFirstChild(location)
            if folder then
                -- First check if this folder has a Purchaseable subfolder
                local purchaseableSubfolder = folder:FindFirstChild("Purchaseable")
                if purchaseableSubfolder then
                    local item = purchaseableSubfolder:FindFirstChild(itemName)
                    if item then
                        local targetPart = nil

                        -- Handle different types of objects
                        if item:IsA("Model") then
                            targetPart = item.PrimaryPart
                            if not targetPart then
                                for _, child in pairs(item:GetDescendants()) do
                                    if child:IsA("Part") or child:IsA("MeshPart") then
                                        targetPart = child
                                        break
                                    end
                                end
                            end
                        elseif item:IsA("Part") or item:IsA("MeshPart") then
                            targetPart = item
                        else
                            for _, child in pairs(item:GetDescendants()) do
                                if child:IsA("Part") or child:IsA("MeshPart") then
                                    targetPart = child
                                    break
                                end
                            end
                        end

                        if targetPart then
                            local itemCFrame = targetPart.CFrame
                            local teleportCFrame = itemCFrame * CFrame.new(0, 0, 5)
                            humanoidRootPart.CFrame = teleportCFrame
                            print("🛒 Teleported to " .. itemName .. " (found in " .. location .. ")")
                            return
                        end
                    end
                end

                -- Also check directly in the folder
                local item = folder:FindFirstChild(itemName)
                if item then
                    local targetPart = nil

                    if item:IsA("Model") then
                        targetPart = item.PrimaryPart
                        if not targetPart then
                            for _, child in pairs(item:GetDescendants()) do
                                if child:IsA("Part") or child:IsA("MeshPart") then
                                    targetPart = child
                                    break
                                end
                            end
                        end
                    elseif item:IsA("Part") or item:IsA("MeshPart") then
                        targetPart = item
                    else
                        for _, child in pairs(item:GetDescendants()) do
                            if child:IsA("Part") or child:IsA("MeshPart") then
                                targetPart = child
                                break
                            end
                        end
                    end

                    if targetPart then
                        local itemCFrame = targetPart.CFrame
                        local teleportCFrame = itemCFrame * CFrame.new(0, 0, 5)
                        humanoidRootPart.CFrame = teleportCFrame
                        print("🛒 Teleported to " .. itemName .. " (found directly in " .. location .. ")")
                        return
                    end
                end
            end
        end

        print("⚠️ Could not find " .. itemName .. " in any location")
        print("🔍 Searched: World/Interactive/Purchaseable, World/Interactive, World/Important, World/NPCs")
    end)
end

-- Build purchasables list from the images
local purchasablesList = {
    "Archaic Shovel", "Bakery", "Bell Shovel", "Blue Coil", "Blueberry Cupcake",
    "Chronos Totem", "Cinnamon Roll", "Controlled Glove", "Copper Shovel",
    "Draconic Shovel", "Frigid Shovel", "Glinted Shovel", "Glistening Totem",
    "Horizon Horn", "Item Detector", "Jam Shovel", "Key Lime Cupcake",
    "Lemon Cupcake", "Lucky Bell", "Lucky Shovel", "Magnet Crate",
    "Magnet Shovel", "Map", "Obsidian Shovel", "Red Velvet Cupcake",
    "Rock Shovel", "Ruby Shovel", "Slayers Shovel", "Solstice Shovel",
    "Spore Spade", "Stormcaller Horn", "Sweetberry Cupcake", "Tempest Horn",
    "Toy Shovel", "Training Shovel", "Vision Goggles"
}

-- Create dropdown for purchasables
PurchasablesBox:AddDropdown("PurchasablesDropdown", {
    Text = "Select Item",
    Tooltip = "Choose a purchasable item to teleport to",
    Values = purchasablesList,
    Default = 1, -- First item in the list

    Callback = function(Value)
        selectedPurchasable = Value
        print("Selected Purchasable: " .. Value)
    end
})

-- Add teleport button for purchasables
PurchasablesBox:AddButton({
    Text = "Teleport to Item",
    Func = function()
        if selectedPurchasable then
            teleportToPurchasable(selectedPurchasable)
        else
            print("⚠️ Please select a purchasable item first")
        end
    end,
    Tooltip = "Teleport to the selected purchasable item",
})

-- Islands Teleport groupbox
local IslandsBox = Tabs.Teleport:AddLeftGroupbox("Islands", "map")

-- Variables for Islands tab
local selectedIsland = nil

-- Function to teleport to islands/spawns
local function teleportToIsland(islandName)
    if not islandName then return end

    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            print("⚠️ No HumanoidRootPart found")
            return
        end

        print("🔍 Searching for: " .. islandName)

        -- Look directly in workspace.Spawns (not workspace.World.Spawns)
        local spawns = workspace:FindFirstChild("Spawns")
        if not spawns then
            print("⚠️ Spawns folder not found in workspace")
            return
        end

        print("🔍 Available spawn folders in workspace.Spawns:")
        for _, child in pairs(spawns:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end

        -- Look for TeleportSpawns model
        local teleportSpawns = spawns:FindFirstChild("TeleportSpawns")
        if teleportSpawns then
            print("✅ Found TeleportSpawns model")
            print("🔍 TeleportSpawns children:")
            for _, child in pairs(teleportSpawns:GetChildren()) do
                print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
            end

            -- Search through all children for the island (exact match first)
            for _, child in pairs(teleportSpawns:GetChildren()) do
                if child.Name == islandName then
                    print("✅ Found exact match: " .. child.Name)
                    local targetPart = nil

                    -- Handle different types of spawn objects
                    if child:IsA("Part") then
                        -- Direct part - this matches your structure (Alona Jungle is a Part)
                        targetPart = child
                        print("🎯 Using Part directly: " .. child.Name)
                    elseif child:IsA("Model") then
                        -- For models, try PrimaryPart first, then any Part/MeshPart
                        targetPart = child.PrimaryPart
                        if not targetPart then
                            for _, descendant in pairs(child:GetDescendants()) do
                                if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("SpawnLocation") then
                                    targetPart = descendant
                                    print("🎯 Using descendant Part: " .. descendant.Name)
                                    break
                                end
                            end
                        else
                            print("🎯 Using PrimaryPart: " .. targetPart.Name)
                        end
                    elseif child:IsA("MeshPart") or child:IsA("SpawnLocation") then
                        targetPart = child
                        print("🎯 Using " .. child.ClassName .. ": " .. child.Name)
                    else
                        -- For other types, search descendants
                        for _, descendant in pairs(child:GetDescendants()) do
                            if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("SpawnLocation") then
                                targetPart = descendant
                                print("🎯 Using descendant: " .. descendant.Name)
                                break
                            end
                        end
                    end

                    if targetPart then
                        -- Calculate position slightly above the spawn point
                        local spawnCFrame = targetPart.CFrame
                        local teleportCFrame = spawnCFrame * CFrame.new(0, 5, 0) -- 5 studs above spawn

                        -- Teleport
                        humanoidRootPart.CFrame = teleportCFrame
                        print("🏝️ Successfully teleported to " .. islandName .. "!")
                        return
                    else
                        print("⚠️ Found " .. islandName .. " but no valid teleport target")
                        return
                    end
                end
            end

            -- If exact match not found, try partial match
            print("🔍 No exact match found, trying partial matches...")
            for _, child in pairs(teleportSpawns:GetChildren()) do
                if string.find(child.Name:lower(), islandName:lower()) or string.find(islandName:lower(), child.Name:lower()) then
                    print("✅ Found partial match: " .. child.Name .. " for " .. islandName)
                    local targetPart = nil

                    if child:IsA("Part") then
                        targetPart = child
                    elseif child:IsA("Model") then
                        targetPart = child.PrimaryPart
                        if not targetPart then
                            for _, descendant in pairs(child:GetDescendants()) do
                                if descendant:IsA("Part") or descendant:IsA("MeshPart") then
                                    targetPart = descendant
                                    break
                                end
                            end
                        end
                    elseif child:IsA("MeshPart") or child:IsA("SpawnLocation") then
                        targetPart = child
                    else
                        for _, descendant in pairs(child:GetDescendants()) do
                            if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("SpawnLocation") then
                                targetPart = descendant
                                break
                            end
                        end
                    end

                    if targetPart then
                        local spawnCFrame = targetPart.CFrame
                        local teleportCFrame = spawnCFrame * CFrame.new(0, 5, 0)
                        humanoidRootPart.CFrame = teleportCFrame
                        print("🏝️ Teleported to " .. child.Name .. " (partial match for " .. islandName .. ")")
                        return
                    end
                end
            end

            print("⚠️ No matches found for: " .. islandName)
        else
            print("⚠️ TeleportSpawns model not found in workspace.Spawns")
        end

        print("🔍 Searched: workspace.Spawns.TeleportSpawns")
    end)
end

-- Build islands/spawns list from the workspace structure
local islandsList = {
    "Alona Jungle", "Azure Hollow", "Boss Arena (Molten Monstrosity)", "Cinder Approach",
    "Cinder Cavern", "Cinder Shores", "Combat Guild", "Copper Mesa", "Everything",
    "Fernhill Forest", "Fox Town", "Glacial Cavern", "Jail Cells", "Monks Workshop",
    "Mount Charcoal", "Mount Cinder", "NPC (Sydney)", "Penguins Pizza", "Phoenix Tribe",
    "Rooftop Woodlands", "Saltys Saloon", "Solstice Shrine", "Sovereign Chasm",
    "Spiders Keep", "The Interlude", "Tom's Bakery", "Verdant Vale", "Volcano"
}

-- Create dropdown for islands
IslandsBox:AddDropdown("IslandsDropdown", {
    Text = "Select Island",
    Tooltip = "Choose an island/spawn to teleport to",
    Values = islandsList,
    Default = 1, -- First island in the list

    Callback = function(Value)
        selectedIsland = Value
        print("Selected Island: " .. Value)
    end
})

-- Add teleport button for islands
IslandsBox:AddButton({
    Text = "Teleport to Island",
    Func = function()
        if selectedIsland then
            teleportToIsland(selectedIsland)
        else
            print("⚠️ Please select an island first")
        end
    end,
    Tooltip = "Teleport to the selected island/spawn",
})



-- Boss Teleport groupbox
local BossBox = Tabs.Teleport:AddLeftGroupbox("Boss Teleport", "skull")

-- Variables for Boss tab
local selectedBoss = nil

-- Function to teleport to boss spawns
local function teleportToBoss(bossName)
    if not bossName then return end

    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            print("⚠️ No HumanoidRootPart found")
            return
        end

        print("🔍 Searching for boss: " .. bossName)

        -- Look in workspace.Spawns.BossSpawns
        local spawns = workspace:FindFirstChild("Spawns")
        if not spawns then
            print("⚠️ Spawns folder not found in workspace")
            return
        end

        local bossSpawns = spawns:FindFirstChild("BossSpawns")
        if not bossSpawns then
            print("⚠️ BossSpawns folder not found in workspace.Spawns")
            return
        end

        print("🔍 Available boss spawn folders:")
        for _, child in pairs(bossSpawns:GetChildren()) do
            print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
        end

        -- Look for the specific boss folder
        local bossFolder = bossSpawns:FindFirstChild(bossName)
        if bossFolder then
            print("✅ Found boss folder: " .. bossName)
            print("🔍 Boss folder contents:")
            for _, child in pairs(bossFolder:GetChildren()) do
                print("  - " .. child.Name .. " (" .. child.ClassName .. ")")
            end

            local targetPart = nil

            -- Try to find any teleportable part in the boss folder
            -- This will work even if boss isn't spawned yet, but will work when it spawns
            local function findBossPart(folder)
                -- First check if there's a direct Part/MeshPart in the folder
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("Part") or child:IsA("MeshPart") or child:IsA("SpawnLocation") then
                        return child
                    end
                end

                -- Check for models that might contain parts
                for _, child in pairs(folder:GetChildren()) do
                    if child:IsA("Model") then
                        -- Look for PrimaryPart first
                        if child.PrimaryPart then
                            return child.PrimaryPart
                        end

                        -- Search descendants for any part
                        for _, descendant in pairs(child:GetDescendants()) do
                            if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("SpawnLocation") then
                                return descendant
                            end
                        end
                    end
                end

                -- Check all descendants of the folder
                for _, descendant in pairs(folder:GetDescendants()) do
                    if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("SpawnLocation") then
                        return descendant
                    end
                end

                return nil
            end

            targetPart = findBossPart(bossFolder)

            if targetPart then
                -- Calculate position near the boss spawn
                local bossCFrame = targetPart.CFrame
                local teleportCFrame = bossCFrame * CFrame.new(0, 10, 10) -- 10 studs above and away from boss

                -- Teleport
                humanoidRootPart.CFrame = teleportCFrame
                print("💀 Successfully teleported to " .. bossName .. " spawn!")
                return
            else
                print("⚠️ Found " .. bossName .. " folder but no boss parts found (boss may not be spawned)")
                print("💡 Try again when the boss spawns - the teleport will work then!")

                -- Try to teleport to the general area using folder position if possible
                -- Look for ChatLocation or ChatPrefix parts which might indicate spawn area
                for _, child in pairs(bossFolder:GetChildren()) do
                    if child.Name == "ChatLocation" and child:IsA("Part") then
                        local chatCFrame = child.CFrame
                        local teleportCFrame = chatCFrame * CFrame.new(0, 10, 0)
                        humanoidRootPart.CFrame = teleportCFrame
                        print("💀 Teleported to " .. bossName .. " general area (using ChatLocation)")
                        return
                    end
                end

                return
            end
        else
            print("⚠️ Boss folder not found: " .. bossName)
        end

        print("🔍 Searched: workspace.Spawns.BossSpawns")
    end)
end

-- Build boss list from the workspace structure shown in image
local bossList = {
    "Basilisk",
    "Candlelight Phantom",
    "Fuzzball",
    "Giant Spider",
    "King Crab",
    "Molten Monstrosity"
}

-- Create dropdown for bosses
BossBox:AddDropdown("BossDropdown", {
    Text = "Select Boss",
    Tooltip = "Choose a boss spawn to teleport to",
    Values = bossList,
    Default = 1, -- First boss in the list

    Callback = function(Value)
        selectedBoss = Value
        print("Selected Boss: " .. Value)
    end
})

-- Add teleport button for bosses
BossBox:AddButton({
    Text = "Teleport to Boss",
    Func = function()
        if selectedBoss then
            teleportToBoss(selectedBoss)
        else
            print("⚠️ Please select a boss first")
        end
    end,
    Tooltip = "Teleport to the selected boss spawn area",
})

-- Important Teleport groupbox
local ImportantBox = Tabs.Teleport:AddLeftGroupbox("Important", "star")

-- Function to teleport to Merchant Cart
local function teleportToMerchant()
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            print("⚠️ No HumanoidRootPart found")
            return
        end

        print("🔍 Searching for Merchant Cart...")

        -- Look in workspace.World.NPCs for Merchant Cart
        local world = workspace:FindFirstChild("World")
        if not world then
            print("⚠️ World folder not found in workspace")
            return
        end

        local npcs = world:FindFirstChild("NPCs")
        if not npcs then
            print("⚠️ NPCs folder not found in World")
            return
        end

        local merchantCart = npcs:FindFirstChild("Merchant Cart")
        if not merchantCart then
            print("⚠️ Merchant Cart not found in NPCs")
            return
        end

        print("✅ Found Merchant Cart")

        -- Find a suitable part to teleport to
        local targetPart = merchantCart.PrimaryPart or merchantCart:FindFirstChildOfClass("Part") or merchantCart:FindFirstChildOfClass("MeshPart")
        if not targetPart then
            -- Search descendants for any part
            for _, child in pairs(merchantCart:GetDescendants()) do
                if child:IsA("Part") or child:IsA("MeshPart") or child:IsA("BasePart") then
                    targetPart = child
                    break
                end
            end
        end

        if targetPart then
            -- Calculate position slightly in front of Merchant Cart
            local merchantCFrame = targetPart.CFrame
            local teleportCFrame = merchantCFrame * CFrame.new(0, 0, 5) -- 5 studs in front

            -- Teleport
            humanoidRootPart.CFrame = teleportCFrame
            print("🛒 Successfully teleported to Merchant Cart!")
        else
            print("⚠️ Found Merchant Cart but no valid teleport target")
        end
    end)
end

-- Add teleport to merchant button
ImportantBox:AddButton({
    Text = "Teleport To Merchant",
    Func = function()
        teleportToMerchant()
    end,
    Tooltip = "Teleport to the Merchant Cart",
})

-- Function to teleport to TerrainDetail in Fernhill Forest
local function teleportToTerrainDetail()
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            print("⚠️ No HumanoidRootPart found")
            return
        end

        print("🔍 Searching for TerrainDetail in Fernhill Forest...")

        -- Navigate to workspace.World.Map."Cinder Isle"."Fernhill Forest".Grass
        local world = workspace:FindFirstChild("World")
        if not world then
            print("⚠️ World folder not found")
            return
        end

        local map = world:FindFirstChild("Map")
        if not map then
            print("⚠️ Map folder not found")
            return
        end

        local cinderIsle = map:FindFirstChild("Cinder Isle")
        if not cinderIsle then
            print("⚠️ Cinder Isle not found")
            return
        end

        local fernhillForest = cinderIsle:FindFirstChild("Fernhill Forest")
        if not fernhillForest then
            print("⚠️ Fernhill Forest not found")
            return
        end

        local grass = fernhillForest:FindFirstChild("Grass")
        if not grass then
            print("⚠️ Grass folder not found")
            return
        end

        -- Find the first TerrainDetail part
        local terrainDetail = nil
        for _, child in pairs(grass:GetChildren()) do
            if child.Name:find("TerrainDetail") and child:IsA("Part") then
                terrainDetail = child
                break
            end
        end

        if terrainDetail then
            -- Teleport to the TerrainDetail part
            local terrainCFrame = terrainDetail.CFrame
            local teleportCFrame = terrainCFrame * CFrame.new(0, 5, 0) -- 5 studs above

            humanoidRootPart.CFrame = teleportCFrame
            print("🌱 Successfully teleported to TerrainDetail in Fernhill Forest!")
        else
            print("⚠️ No TerrainDetail parts found in Fernhill Forest/Grass")
        end
    end)
end



-- Quest Tab Functionality
-- Variables for Quest automation
local guitaristQuestEnabled = false
local guitaristQuestConnection = nil
local questStarted = false
local initialDigCount = 0
local targetDigCount = 15

-- Function to start Guitarists Inspo quest
local function startGuitaristQuest()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("StartQuest") then
            dialogueRemotes.StartQuest:InvokeServer("Guitarists Inspo")
            print("🎸 Started Guitarists Inspo quest!")
            questStarted = true
        else
            print("⚠️ StartQuest remote not found")
        end
    end)
end

-- Function to complete Guitarists Inspo quest
local function completeGuitaristQuest()
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("CompleteQuest") then
            dialogueRemotes.CompleteQuest:InvokeServer("Guitarists Inspo")
            print("🎸 Completed Guitarists Inspo quest!")

            -- Disable auto dig and quest automation
            if Toggles.AutoDig then
                Toggles.AutoDig:SetValue(false)
            end
            guitaristQuestEnabled = false
            questStarted = false
        else
            print("⚠️ CompleteQuest remote not found")
        end
    end)
end

-- Function to teleport to Node in DefaultSpawns
local function teleportToNode()
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return end

        -- Look for Node in workspace.Spawns.DefaultSpawns
        local spawns = workspace:FindFirstChild("Spawns")
        if not spawns then
            print("⚠️ Spawns folder not found")
            return
        end

        local defaultSpawns = spawns:FindFirstChild("DefaultSpawns")
        if not defaultSpawns then
            print("⚠️ DefaultSpawns folder not found")
            return
        end

        -- Find first available Node
        local node = nil
        for _, child in pairs(defaultSpawns:GetChildren()) do
            if child.Name == "Node" and child:IsA("Part") then
                node = child
                break
            end
        end

        if node then
            local nodeCFrame = node.CFrame
            local teleportCFrame = nodeCFrame * CFrame.new(0, 5, 0) -- 5 studs above
            humanoidRootPart.CFrame = teleportCFrame
            print("⚡ Teleported to Node in DefaultSpawns!")
        else
            print("⚠️ No Node found in DefaultSpawns")
        end
    end)
end

-- Function to get current dig count from quest progress
local function getCurrentDigCount()
    local count = 0
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local playerStats = ReplicatedStorage:FindFirstChild("PlayerStats")
        if not playerStats then return end

        local localPlayerStats = playerStats:FindFirstChild(LocalPlayer.Name)
        if not localPlayerStats then return end

        local quests = localPlayerStats:FindFirstChild("Quests")
        if not quests then return end

        local guitaristQuest = quests:FindFirstChild("Guitarists Inspo")
        if not guitaristQuest then return end

        -- Try different ways to get progress
        -- Method 1: Look for Progress IntValue
        local progressValue = guitaristQuest:FindFirstChild("Progress")
        if progressValue and progressValue:IsA("IntValue") then
            count = progressValue.Value
            return
        end

        -- Method 2: Look for any IntValue that might contain progress
        for _, child in pairs(guitaristQuest:GetChildren()) do
            if child:IsA("IntValue") then
                count = child.Value
                return
            end
        end

        -- Method 3: Check attributes

        local progressAttr = guitaristQuest:GetAttribute("Progress")
        if progressAttr then
            count = progressAttr
            return
        end

        -- Method 4: Check for NumberValue
        for _, child in pairs(guitaristQuest:GetChildren()) do
            if child:IsA("NumberValue") then
                count = child.Value
                return
            end
        end
    end)
    return count
end

-- Function to check if quest is complete
local function isQuestComplete()

    local isComplete = false
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local playerStats = ReplicatedStorage:FindFirstChild("PlayerStats")
        if not playerStats then return end

        local localPlayerStats = playerStats:FindFirstChild(LocalPlayer.Name)
        if not localPlayerStats then return end

        local quests = localPlayerStats:FindFirstChild("Quests")
        if not quests then return end

        local guitaristQuest = quests:FindFirstChild("Guitarists Inspo")
        if not guitaristQuest then return end

        -- Check if quest is complete via attribute
        isComplete = guitaristQuest:GetAttribute("IsComplete") == true

        -- Also check if we have reached the target dig count
        local currentCount = getCurrentDigCount()
        if currentCount >= targetDigCount then
            isComplete = true
        end
    end)
    return isComplete
end

-- Main quest automation function
local function guitaristQuestLoop()
    if not guitaristQuestEnabled then return end

    task.spawn(function()
        pcall(function()
            -- Start quest if not started
            if not questStarted then
                startGuitaristQuest()
                task.wait(2) -- Wait for quest to register

                -- Teleport to Node for digging
                teleportToNode()
                task.wait(1)

                -- Enable auto dig
                if Toggles.AutoDig then
                    Toggles.AutoDig:SetValue(true)
                end

                -- Enable auto walk
                if Toggles.AutoWalk then
                    Toggles.AutoWalk:SetValue(true)
                end

                initialDigCount = getCurrentDigCount()
                questStarted = true
                print("🎸 Quest automation started! Auto Dig and Auto Walk enabled.")
                return -- Exit after setup
            end

            -- Only check progress every 5 seconds to reduce server calls
            local currentDigCount = getCurrentDigCount()
            local itemsLeft = targetDigCount - currentDigCount

            if itemsLeft > 0 then
                print("🎸 Guitarists Inspo Progress: " .. currentDigCount .. "/" .. targetDigCount .. " (" .. itemsLeft .. " items left)")
            end

            -- Check if quest is complete
            if isQuestComplete() or currentDigCount >= targetDigCount then
                print("🎸 Quest completed! Finishing up...")

                -- Disable auto dig and auto walk
                if Toggles.AutoDig then
                    Toggles.AutoDig:SetValue(false)
                end
                if Toggles.AutoWalk then
                    Toggles.AutoWalk:SetValue(false)
                end

                -- Complete quest
                completeGuitaristQuest()

                -- Stop the automation
                if guitaristQuestConnection then
                    guitaristQuestConnection:Disconnect()
                    guitaristQuestConnection = nil
                end
                guitaristQuestEnabled = false
                questStarted = false

                print("🎸 Quest automation finished! Auto Dig and Auto Walk disabled.")
            end
        end)
    end)
end

-- Create Quest groupbox
local QuestGroupBox = Tabs.Quest:AddLeftGroupbox("Guitarist", "music")

-- Add Guitarists Inspo quest toggle
QuestGroupBox:AddToggle("GuitaristQuest", {
    Text = "Auto Guitarists Inspo Quest",
    Tooltip = "Automatically complete the Guitarists Inspo quest (dig 15 items)",
    Default = false,

    Callback = function(Value)
        guitaristQuestEnabled = Value

        if guitaristQuestEnabled then
            print("🎸 Guitarists Inspo Quest ENABLED")

            -- Start quest monitoring with much longer intervals to reduce ping
            guitaristQuestConnection = task.spawn(function()
                while guitaristQuestEnabled do
                    guitaristQuestLoop()
                    task.wait(5) -- Check every 5 seconds instead of every heartbeat
                end
            end)
        else
            print("🎸 Guitarists Inspo Quest DISABLED")

            -- Stop quest monitoring
            if guitaristQuestConnection then
                task.cancel(guitaristQuestConnection)
                guitaristQuestConnection = nil
            end

            questStarted = false
        end
    end,
})

-- Add manual quest start button
QuestGroupBox:AddButton({
    Text = "Start Quest Manually",
    Func = function()
        startGuitaristQuest()
    end,
    Tooltip = "Manually start the Guitarists Inspo quest",
})

-- Add manual quest complete button
QuestGroupBox:AddButton({
    Text = "Complete Quest Manually",
    Func = function()
        completeGuitaristQuest()
    end,
    Tooltip = "Manually complete the Guitarists Inspo quest",
})

-- Pizza Quest Functionality
-- Variables for Pizza quest automation
local pizzaQuestEnabled = false
local pizzaQuestConnection = nil
local pizzaQuestState = "none" -- "none", "started", "teleporting", "delivering", "completed"
local lastPizzaAction = 0
local pizzaCooldown = 8 -- 8 second cooldown between major actions

-- Function to get pizza customer location from PlayerStats
local function getPizzaCustomerLocation()
    local location = nil
    pcall(function()
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local playerStats = ReplicatedStorage:FindFirstChild("PlayerStats")
        if not playerStats then return end

        local localPlayerStats = playerStats:FindFirstChild(LocalPlayer.Name)
        if not localPlayerStats then return end

        local trackers = localPlayerStats:FindFirstChild("Trackers")
        if not trackers then return end

        local pizzaCustomerNode = trackers:FindFirstChild("PizzaCustomerNode")
        if not pizzaCustomerNode or pizzaCustomerNode.Value == "" then return end

        -- Parse the position from the string format "[x,y,z]"
        local posString = string.split(pizzaCustomerNode.Value, ']')[1]
        if posString then
            local coords = string.split(posString:gsub("%[", ""):gsub("=", ","), ",")
            if #coords >= 3 then
                location = Vector3.new(tonumber(coords[1]), tonumber(coords[2]), tonumber(coords[3]))
            end
        end
    end)
    return location
end

-- Function to teleport to pizza customer
local function teleportToPizzaCustomer()
    local success = false
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            success = false
            return
        end

        -- Try to get location from PlayerStats first
        local customerLocation = getPizzaCustomerLocation()
        if customerLocation then
            local teleportCFrame = CFrame.new(customerLocation + Vector3.new(0, 5, 0))
            humanoidRootPart.CFrame = teleportCFrame
            print("🍕 Teleported to pizza customer location!")
            success = true
            return
        end

        -- Fallback: Search for Valued Customer in workspace
        local world = workspace:FindFirstChild("World")
        if not world then
            success = false
            return
        end

        local active = workspace:FindFirstChild("Active")
        print("🔍 Looking for Active in workspace:", active ~= nil)
        if not active then
            print("⚠️ Active not found in workspace")
            success = false
            return
        end

        local pizzaCustomers = active:FindFirstChild("PizzaCustomers")
        if not pizzaCustomers then
            success = false
            return
        end

        local valuedCustomer = pizzaCustomers:FindFirstChild("Valued Customer")
        if not valuedCustomer then
            success = false
            return
        end

        -- Find a suitable part to teleport to
        local targetPart = valuedCustomer.PrimaryPart or valuedCustomer:FindFirstChildOfClass("Part") or valuedCustomer:FindFirstChildOfClass("MeshPart")
        if not targetPart then
            -- Search descendants
            for _, child in pairs(valuedCustomer:GetDescendants()) do
                if child:IsA("Part") or child:IsA("MeshPart") then
                    targetPart = child
                    break
                end
            end
        end

        if targetPart then
            local customerCFrame = targetPart.CFrame
            local teleportCFrame = customerCFrame * CFrame.new(0, 0, 5) -- 5 studs away from customer
            humanoidRootPart.CFrame = teleportCFrame
            print("🍕 Teleported to Valued Customer!")
            success = true
            return
        end

        success = false
    end)
    return success
end

-- Function to start Pizza Penguin quest
local function startPizzaQuest()
    pcall(function()
        if pizzaQuestState ~= "none" then
            return -- Already started or in progress
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("StartInfiniteQuest") then
            dialogueRemotes.StartInfiniteQuest:InvokeServer("Pizza Penguin")
            pizzaQuestState = "started"
            lastPizzaAction = tick()
            print("🍕 Started Pizza Penguin quest!")
        else
            print("⚠️ StartInfiniteQuest remote not found")
        end
    end)
end

-- Function to deliver pizza
local function deliverPizza()
    pcall(function()
        if pizzaQuestState ~= "teleporting" or (tick() - lastPizzaAction) < 3 then
            return -- Not ready to deliver or need time after teleport
        end

        -- Find the pizza customer in workspace
        local world = workspace:FindFirstChild("World")
        if not world then
            print("⚠️ World not found")
            return
        end

        local active = workspace:FindFirstChild("Active")
        print("🔍 Looking for Active in workspace:", active ~= nil)
        if not active then
            print("⚠️ Active not found in workspace")
            return
        end

        local pizzaCustomers = active:FindFirstChild("PizzaCustomers")
        if not pizzaCustomers then
            print("⚠️ PizzaCustomers not found")
            return
        end

        local valuedCustomer = pizzaCustomers:FindFirstChild("Valued Customer")
        if not valuedCustomer then
            print("⚠️ Valued Customer not found")
            return
        end

        -- Use the Quest_DeliverPizza remote to actually deliver the pizza
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            print("⚠️ Remotes folder not found")
            return
        end

        local questDeliverPizza = remotes:FindFirstChild("Quest_DeliverPizza")
        if not questDeliverPizza then
            print("⚠️ Quest_DeliverPizza remote not found")
            return
        end

        -- Call the actual delivery remote
        questDeliverPizza:InvokeServer()

        pizzaQuestState = "completed"  -- Skip "delivering" state since delivery is immediate
        lastPizzaAction = tick()
        print("🍕 Delivered pizza! Quest ready to turn in! State: " .. pizzaQuestState)
    end)
end

-- Function to complete Pizza Penguin quest
local function completePizzaQuest()
    pcall(function()
        if pizzaQuestState ~= "completed" or (tick() - lastPizzaAction) < 3 then
            return -- Not ready to complete or need time after delivery
        end

        -- First teleport back to Pizza Penguin
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            return
        end

        -- Look for Pizza Penguin in NPCs
        local world = workspace:FindFirstChild("World")
        if not world then
            return
        end

        local npcs = world:FindFirstChild("NPCs")
        if not npcs then
            return
        end

        local pizzaPenguin = npcs:FindFirstChild("Pizza Penguin")
        if pizzaPenguin then
            local targetPart = pizzaPenguin.PrimaryPart or pizzaPenguin:FindFirstChildOfClass("Part") or pizzaPenguin:FindFirstChildOfClass("MeshPart")
            if not targetPart then
                -- Search descendants
                for _, child in pairs(pizzaPenguin:GetDescendants()) do
                    if child:IsA("Part") or child:IsA("MeshPart") then
                        targetPart = child
                        break
                    end
                end
            end

            if targetPart then
                local penguinCFrame = targetPart.CFrame
                local teleportCFrame = penguinCFrame * CFrame.new(0, 0, 5) -- 5 studs away from penguin
                humanoidRootPart.CFrame = teleportCFrame
                print("🍕 Teleported back to Pizza Penguin!")

                -- Wait a moment then complete the quest
                task.wait(1)
            end
        end

        -- Complete the quest
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("CompleteInfiniteQuest") then
            dialogueRemotes.CompleteInfiniteQuest:InvokeServer("Pizza Penguin")
            pizzaQuestState = "none"  -- Reset to start next cycle
            lastPizzaAction = tick()
            print("🍕 Completed Pizza Penguin quest! Ready for next delivery!")
        else
            print("⚠️ CompleteInfiniteQuest remote not found")
        end
    end)
end

-- Main pizza quest automation function
local function pizzaQuestLoop()
    if not pizzaQuestEnabled then return end

    task.spawn(function()
        pcall(function()
            -- State machine for pizza quest automation
            if pizzaQuestState == "none" then
                startPizzaQuest()
            elseif pizzaQuestState == "started" then
                -- Wait a moment for customer to spawn, then teleport
                if (tick() - lastPizzaAction) >= 3 then
                    if teleportToPizzaCustomer() then
                        pizzaQuestState = "teleporting"
                        lastPizzaAction = tick()
                        print("🍕 Moving to pizza customer...")
                    else
                        print("⚠️ Could not find pizza customer, retrying...")
                        -- Stay in started state to retry
                    end
                end
            elseif pizzaQuestState == "teleporting" then
                deliverPizza()
            elseif pizzaQuestState == "completed" then
                completePizzaQuest()
            end
        end)
    end)
end

-- Create Pizza groupbox
local PizzaGroupBox = Tabs.Quest:AddLeftGroupbox("Pizza", "pizza-slice")

-- Add Pizza quest toggle
PizzaGroupBox:AddToggle("PizzaQuest", {
    Text = "Auto Pizza Penguin Quest",
    Tooltip = "Automatically complete the Pizza Penguin delivery quest",
    Default = false,

    Callback = function(Value)
        pizzaQuestEnabled = Value

        if pizzaQuestEnabled then
            print("🍕 Pizza Penguin Quest ENABLED")

            -- Reset state when enabling
            pizzaQuestState = "none"
            lastPizzaAction = 0

            -- Start pizza quest monitoring with longer intervals
            pizzaQuestConnection = task.spawn(function()
                while pizzaQuestEnabled do
                    pizzaQuestLoop()
                    task.wait(2) -- Check every 2 seconds (more responsive but still efficient)
                end
            end)
        else
            print("🍕 Pizza Penguin Quest DISABLED")

            -- Stop pizza quest monitoring
            if pizzaQuestConnection then
                pizzaQuestConnection = nil
            end

            -- Reset state when disabling
            pizzaQuestState = "none"
            lastPizzaAction = 0
        end
    end,
})

-- Graveyard Quest Functionality
-- Variables for Graveyard quest automation
local graveyardQuestEnabled = false
local graveyardQuestConnection = nil
local graveyardQuestStarted = false
local ghostsDigged = 0 -- Track number of ghosts caught
local lastGhostCheck = 0 -- Rate limiting for ghost progress checks

-- Function to get ghost progress from quest UI (enhanced)
local function getGhostProgress()
    local progress = 0

    pcall(function()
        -- Method 1: Check quest UI in PlayerGui
        local questsGui = LocalPlayer.PlayerGui:FindFirstChild("Quests")
        if questsGui then
            -- Look for Ghostbuster quest text
            for _, descendant in pairs(questsGui:GetDescendants()) do
                if descendant:IsA("TextLabel") or descendant:IsA("TextBox") then
                    local text = descendant.Text
                    if string.find(text:lower(), "ghost") then
                        -- Look for patterns like "2/3", "1/3", "0/3"
                        local progressMatch = string.match(text, "(%d+)/3")
                        if progressMatch then
                            progress = math.max(progress, tonumber(progressMatch) or 0)
                        end

                        -- Also look for "dig 3 ghosts" with numbers
                        if string.find(text:lower(), "dig") and string.find(text, "3") then
                            local digMatch = string.match(text, "dig (%d+)")
                            if digMatch then
                                progress = math.max(progress, tonumber(digMatch) or 0)
                            end
                        end
                    end
                end
            end
        end

        -- Method 2: Check player attributes
        local ghostAttr = LocalPlayer:GetAttribute("Ghostbuster_Progress")
        if ghostAttr then
            progress = math.max(progress, ghostAttr)
        end

        -- Method 3: Check for DigGhost attribute
        local digGhostAttr = LocalPlayer:GetAttribute("DigGhost")
        if digGhostAttr then
            progress = math.max(progress, digGhostAttr)
        end

        -- Method 4: Check ReplicatedStorage quest data
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local questData = replicatedStorage:FindFirstChild("QuestData_" .. LocalPlayer.Name)
        if questData then
            local ghostbusterData = questData:FindFirstChild("Ghostbuster")
            if ghostbusterData then
                local progressValue = ghostbusterData:FindFirstChild("Progress")
                if progressValue and progressValue:IsA("IntValue") then
                    progress = math.max(progress, progressValue.Value)
                end
            end
        end

        -- Method 5: Check leaderstats for any ghost-related stats
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in pairs(leaderstats:GetChildren()) do
                if stat.Name:lower():find("ghost") then
                    progress = math.max(progress, stat.Value or 0)
                end
            end
        end
    end)

    return progress
end

-- Function to enable required toggles for ghost hunting
local function enableGhostHuntingToggles()
    pcall(function()
        -- Enable Auto Dig if not already enabled
        if not autoDigEnabled then
            print("👻 Auto-enabling Auto Dig for ghost hunting...")
            Toggles.AutoDig:SetValue(true)
        end

        -- Enable _NoDig Zone Bypass if not already enabled
        if not noDig_bypass_enabled then
            print("👻 Auto-enabling _NoDig Zone Bypass for ghost hunting...")
            Toggles.DigAnywhere:SetValue(true)
        end

        -- Enable Auto Equip Shovel if not already enabled
        if not autoEquipEnabled then
            print("👻 Auto-enabling Auto Equip Shovel for ghost hunting...")
            Toggles.AutoEquipShovel:SetValue(true)
        end
    end)
end

-- Function to complete the Ghostbuster quest
local function completeGhostbusterQuest()
    pcall(function()
        print("👻 All 3 ghosts caught! Completing quest...")

        -- Teleport to Sam Colby first
        teleportToSamColby()

        -- Wait a moment for teleport to complete
        task.wait(3)

        -- Try to turn in the quest
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = replicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes then
            local turnInQuest = dialogueRemotes:FindFirstChild("TurnInQuest")
            if turnInQuest then
                turnInQuest:InvokeServer("Ghostbuster")
                print("👻 Quest turned in successfully!")

                -- Reset quest state
                graveyardQuestStarted = false
                ghostsDigged = 0
                lastGhostCheck = 0

                -- Wait a moment then check if we should restart the quest
                task.wait(5)
                if graveyardQuestEnabled then
                    print("👻 Restarting quest automation...")
                    graveyardQuestStarted = false -- Ensure it restarts
                end

                return true
            end
        end

        print("⚠️ Could not find TurnInQuest remote")
        return false
    end)
end

-- Function to teleport to Sam Colby
local function teleportToSamColby()
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            print("⚠️ No character or HumanoidRootPart found")
            return
        end

        -- Find Sam Colby in NPCs
        local world = workspace:FindFirstChild("World")
        if not world then
            print("⚠️ World not found")
            return
        end

        local npcs = world:FindFirstChild("NPCs")
        if not npcs then
            print("⚠️ NPCs folder not found")
            return
        end

        local samColby = npcs:FindFirstChild("Sam Colby")
        if not samColby then
            print("⚠️ Sam Colby not found in NPCs")
            return
        end

        -- Find a suitable part to teleport to
        local targetPart = nil
        if samColby.PrimaryPart then
            targetPart = samColby.PrimaryPart
        else
            -- Try to find any part in the model
            for _, child in pairs(samColby:GetChildren()) do
                if child:IsA("BasePart") then
                    targetPart = child
                    break
                end
            end
        end

        if targetPart then
            local samColbyCFrame = targetPart.CFrame
            local teleportCFrame = samColbyCFrame * CFrame.new(0, 0, 5) -- 5 studs away from Sam Colby
            humanoidRootPart.CFrame = teleportCFrame
            print("👻 Teleported to Sam Colby!")
        else
            print("⚠️ No suitable part found in Sam Colby model")
        end
    end)
end

-- Function to start Ghostbuster quest
local function startGhostbusterQuest()
    if graveyardQuestStarted then
        return -- Already started
    end

    pcall(function()
        local replicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = replicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("StartQuest") then
            dialogueRemotes.StartQuest:InvokeServer("Ghostbuster")
            graveyardQuestStarted = true
            print("👻 Started Ghostbuster quest!")

            -- Enable necessary toggles for ghost hunting
            enableGhostHuntingToggles()
        else
            print("⚠️ Could not find StartQuest remote")
        end
    end)
end

-- Main graveyard quest automation function (first implementation)
local function graveyardQuestLoopOld()
    if not graveyardQuestEnabled then return end

    pcall(function()
        local character = LocalPlayer.Character
        if character then
            if not graveyardQuestStarted then
                print("👻 Starting Ghostbuster quest automation...")
                -- Step 1: Teleport to Sam Colby
                teleportToSamColby()
                task.wait(3) -- Wait for teleport

                -- Step 2: Start the quest
                startGhostbusterQuest()

                -- Step 3: Enable hunting toggles after starting quest
                task.wait(1)
                enableGhostHuntingToggles()
            else
                -- Quest is started, monitor progress
                local currentTime = tick()
                if currentTime - lastGhostCheck >= 3 then -- Check every 3 seconds
                    lastGhostCheck = currentTime

                    local currentGhosts = getGhostProgress()
                    if currentGhosts ~= ghostsDigged then
                        ghostsDigged = currentGhosts
                        print("👻 Ghost Progress: " .. ghostsDigged .. "/3")

                        -- Check if quest is complete
                        if ghostsDigged >= 3 then
                            completeGhostbusterQuest()
                        end
                    end
                end
            end
        end
    end)
end
local noclipConnection = nil

-- Noclip functionality
local characterRespawnConnection = nil

local function enableNoclip()
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end

        -- Disable collision for all parts in character
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end

        -- Create connection to maintain noclip
        if noclipConnection then
            noclipConnection:Disconnect()
        end

        noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char and graveyardQuestEnabled then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)

        print("👻 Noclip ENABLED")
    end)
end

local function disableNoclip()
    pcall(function()
        -- Disconnect noclip connection
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end

        -- Disconnect character respawn connection
        if characterRespawnConnection then
            characterRespawnConnection:Disconnect()
            characterRespawnConnection = nil
        end

        local character = LocalPlayer.Character
        if not character then return end

        -- Re-enable collision for character parts (except HumanoidRootPart)
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end

        print("👻 Noclip DISABLED")
    end)
end

local function setupCharacterRespawnHandler()
    -- Handle character respawning to re-enable noclip
    if characterRespawnConnection then
        characterRespawnConnection:Disconnect()
    end

    characterRespawnConnection = LocalPlayer.CharacterAdded:Connect(function(character)
        if graveyardQuestEnabled then
            -- Wait a moment for character to fully load
            task.wait(1)
            enableNoclip()
            print("👻 Character respawned - Noclip re-enabled!")
        end
    end)
end

-- Function to teleport to Sam Colby
local function teleportToSamColby()
    local success = false
    pcall(function()
        local character = LocalPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            print("⚠️ Player character or HumanoidRootPart not found")
            return
        end

        -- Find Sam Colby in NPCs
        local world = workspace:FindFirstChild("World")
        if not world then
            print("⚠️ World not found in workspace")
            return
        end

        local npcs = world:FindFirstChild("NPCs")
        if not npcs then
            print("⚠️ NPCs folder not found in World")
            return
        end

        local samColby = npcs:FindFirstChild("Sam Colby")
        if not samColby then
            print("⚠️ Sam Colby not found in NPCs")
            return
        end

        -- Find a suitable part to teleport to
        local targetPart = samColby.PrimaryPart or samColby:FindFirstChildOfClass("Part") or samColby:FindFirstChildOfClass("MeshPart")
        if not targetPart then
            -- Search descendants for any part
            for _, child in pairs(samColby:GetDescendants()) do
                if child:IsA("Part") or child:IsA("MeshPart") then
                    targetPart = child
                    break
                end
            end
        end

        if targetPart then
            local samColbyCFrame = targetPart.CFrame
            local teleportCFrame = samColbyCFrame * CFrame.new(0, 0, 5) -- 5 studs away from Sam Colby
            humanoidRootPart.CFrame = teleportCFrame
            print("👻 Teleported to Sam Colby!")
            success = true
        else
            print("⚠️ No suitable part found in Sam Colby model")
        end
    end)
    return success
end

-- Function to start Ghostbuster quest
local function startGhostbusterQuest()
    pcall(function()
        if graveyardQuestStarted then
            return -- Already started
        end

        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local dialogueRemotes = ReplicatedStorage:FindFirstChild("DialogueRemotes")

        if dialogueRemotes and dialogueRemotes:FindFirstChild("StartQuest") then
            dialogueRemotes.StartQuest:InvokeServer("Ghostbuster")
            graveyardQuestStarted = true
            print("👻 Started Ghostbuster quest!")
        else
            print("⚠️ StartQuest remote not found")
        end
    end)
end

-- Main graveyard quest automation function (enhanced)
local function graveyardQuestLoop()
    if not graveyardQuestEnabled then return end

    task.spawn(function()
        pcall(function()
            -- If quest hasn't been started yet, teleport and start it
            if not graveyardQuestStarted then
                local teleportSuccess = teleportToSamColby()
                if teleportSuccess then
                    task.wait(2) -- Wait 2 seconds after teleport before starting quest
                    startGhostbusterQuest()

                    -- Enable hunting toggles after starting quest
                    task.wait(1)
                    enableGhostHuntingToggles()
                end
            else
                -- Quest is started, monitor progress
                local currentTime = tick()
                if currentTime - lastGhostCheck >= 3 then -- Check every 3 seconds
                    lastGhostCheck = currentTime

                    local currentGhosts = getGhostProgress()
                    if currentGhosts ~= ghostsDigged then
                        ghostsDigged = currentGhosts
                        print("👻 Ghost Progress: " .. ghostsDigged .. "/3")

                        -- Check if quest is complete
                        if ghostsDigged >= 3 then
                            completeGhostbusterQuest()
                        end
                    end
                end
            end
        end)
    end)
end

-- Create Graveyard groupbox
local GraveyardGroupBox = Tabs.Quest:AddLeftGroupbox("Graveyard", "ghost")


-- Add manual teleport button
GraveyardGroupBox:AddButton({
    Text = "Teleport to Sam Colby",
    Func = function()
        teleportToSamColby()
    end,
    Tooltip = "Manually teleport to Sam Colby",
})

-- Add manual quest start button
GraveyardGroupBox:AddButton({
    Text = "Start Ghostbuster Quest",
    Func = function()
        startGhostbusterQuest()
    end,
    Tooltip = "Manually start the Ghostbuster quest",
})


-- OnChanged events for better control
Toggles.AutoEquipShovel:OnChanged(function()
    print("Auto Equip Shovel changed to:", Toggles.AutoEquipShovel.Value)
end)

Toggles.AutoDig:OnChanged(function()
    print("Auto Dig changed to:", Toggles.AutoDig.Value)
end)

Toggles.AutoSellInventory:OnChanged(function()
    print("Auto Sell Inventory changed to:", Toggles.AutoSellInventory.Value)
end)

Toggles.AutoSellItem:OnChanged(function()
    print("Auto Sell Items changed to:", Toggles.AutoSellItem.Value)
end)

Toggles.AutoSellInventory:OnChanged(function()
    print("Auto Sell Inventory changed to:", Toggles.AutoSellInventory.Value)
end)

Toggles.AutoSellItem:OnChanged(function()
    print("Auto Sell Item changed to:", Toggles.AutoSellItem.Value)
end)

-- Add OnChanged event for Auto Walk toggle
Toggles.AutoWalk:OnChanged(function()
    print("Auto Walk changed to:", Toggles.AutoWalk.Value)
end)


-- World Tab
local WorldGroupBox = Tabs.World:AddLeftGroupbox("World Functions", "globe")

-- Function to remove particles and effects
local function removeParticlesAndEffects()
    local effectsRemoved = 0

    -- List of effect types to look for
    local effectTypes = {"ParticleEmitter", "Beam", "Trail", "Fire", "Smoke", "Sparkles", "PointLight", "SpotLight", "SurfaceLight"}

    -- Function to recursively remove effects from a container
    local function removeEffectsFromContainer(container, containerName)
        if not container then return end

        pcall(function()
            for _, child in pairs(container:GetDescendants()) do
                pcall(function()
                    for _, effectType in pairs(effectTypes) do
                        if child:IsA(effectType) then
                            if effectType == "ParticleEmitter" then
                                child.Enabled = false
                            elseif effectType == "Beam" or effectType == "Trail" then
                                child.Enabled = false
                            elseif effectType == "Fire" or effectType == "Smoke" or effectType == "Sparkles" then
                                child.Enabled = false
                            elseif string.find(effectType, "Light") then
                                child.Enabled = false
                            end
                            effectsRemoved = effectsRemoved + 1
                        end
                    end
                end)
            end
        end)
    end

    -- Remove effects from Workspace (including dig effects and general world effects)
    removeEffectsFromContainer(game.Workspace, "Workspace")

    -- Remove effects from ReplicatedStorage Resources
    removeEffectsFromContainer(game.ReplicatedStorage:FindFirstChild("Resources"), "ReplicatedStorage.Resources")

    -- Remove effects from all player characters
    for _, player in pairs(game.Players:GetPlayers()) do
        if player.Character then
            removeEffectsFromContainer(player.Character, "Player: " .. player.Name)
        end
    end

    -- Remove effects from StarterGui (UI effects)
    removeEffectsFromContainer(game.StarterGui, "StarterGui")

    -- Remove effects from ReplicatedFirst
    removeEffectsFromContainer(game.ReplicatedFirst, "ReplicatedFirst")

    -- Remove hurricane and special event effects specifically
    pcall(function()
        local specialEventEffects = game.StarterGui:FindFirstChild("SpecialEventEffects")
        if specialEventEffects then
            removeEffectsFromContainer(specialEventEffects, "SpecialEventEffects")
        end
    end)

    print("🌟 Removed/Disabled " .. effectsRemoved .. " particle effects and visual effects!")

    return effectsRemoved
end

WorldGroupBox:AddButton({
    Text = "Remove Particles and Effects",
    Func = function()
        removeParticlesAndEffects()
    end,
    Tooltip = "Remove or disable all particle emitters, beams, trails, and other visual effects in the game"
})

WorldGroupBox:AddButton({
    Text = "Remove All Lighting Effects",
    Func = function()
        local lightsRemoved = 0

        -- Function to remove lighting effects
        local function removeLightingEffects(container)
            if not container then return end

            pcall(function()
                for _, child in pairs(container:GetDescendants()) do
                    pcall(function()
                        if child:IsA("PointLight") or child:IsA("SpotLight") or child:IsA("SurfaceLight") then
                            child.Enabled = false
                            lightsRemoved = lightsRemoved + 1
                        end
                    end)
                end
            end)
        end

        -- Remove from all major containers
        removeLightingEffects(game.Workspace)
        removeLightingEffects(game.ReplicatedStorage)
        for _, player in pairs(game.Players:GetPlayers()) do
            if player.Character then
                removeLightingEffects(player.Character)
            end
        end

        print("💡 Disabled " .. lightsRemoved .. " lighting effects!")
    end,
    Tooltip = "Disable all lighting effects (PointLight, SpotLight, SurfaceLight) in the game"
})

WorldGroupBox:AddButton({
    Text = "Remove Dig Effects Only",
    Func = function()
        local digEffectsRemoved = 0

        -- Function to remove dig-specific effects
        local function removeDigEffects(container)
            if not container then return end

            pcall(function()
                for _, child in pairs(container:GetDescendants()) do
                    pcall(function()
                        -- Look for dig-related effects (commonly found in zone scripts)
                        if child:IsA("ParticleEmitter") or child:IsA("Beam") or child:IsA("Trail") then
                            -- Check if it's in a dig-related location or has dig-related names
                            local parent = child.Parent
                            local isDigEffect = false

                            if parent then
                                local parentName = parent.Name:lower()
                                if parentName:find("dig") or parentName:find("shovel") or parentName:find("mine") or
                                        parentName:find("dirt") or parentName:find("ground") or parentName:find("rock") then
                                    isDigEffect = true
                                end
                            end

                            -- Also check if it's in the workspace world areas where digging happens
                            local currentParent = child.Parent
                            while currentParent and currentParent ~= game do
                                if currentParent.Name == "World" or currentParent.Name == "Active" then
                                    isDigEffect = true
                                    break
                                end
                                currentParent = currentParent.Parent
                            end

                            if isDigEffect then
                                if child:IsA("ParticleEmitter") then
                                    child.Enabled = false
                                elseif child:IsA("Beam") or child:IsA("Trail") then
                                    child.Enabled = false
                                end
                                digEffectsRemoved = digEffectsRemoved + 1
                            end
                        end
                    end)
                end
            end)
        end

        -- Focus on Workspace where most dig effects would be
        removeDigEffects(game.Workspace)

        print("⛏️ Disabled " .. digEffectsRemoved .. " dig-related effects!")
    end,
    Tooltip = "Remove only dig-related particle effects and visual elements"
})

-- Weather groupbox
local WeatherGroupBox = Tabs.World:AddLeftGroupbox("Weather", "cloud")

-- Low Graphics toggle
WeatherGroupBox:AddToggle("LowGraphics", {
    Text = "Low Graphics",
    Tooltip = "Enable FPS booster with low graphics settings for better performance",
    Default = true, -- Auto-enabled when script executes

    Callback = function(Value)
        lowGraphicsEnabled = Value

        if lowGraphicsEnabled then
            print("🚀 Low Graphics ENABLED - FPS Booster activated!")

            -- Initialize the low graphics script (based on RIP#6666's FPS booster)
            task.spawn(function()
                -- Settings for the FPS booster (no notifications)
                _G.SendNotifications = false -- Disable notifications as requested
                _G.ConsoleLogs = false
                _G.WaitPerAmount = 500
                _G.Settings = {
                    Players = {
                        ["Ignore Me"] = true,
                        ["Ignore Others"] = true,
                        ["Ignore Tools"] = true
                    },
                    Meshes = {
                        NoMesh = false,
                        NoTexture = false,
                        Destroy = false,
                        LowDetail = true
                    },
                    Images = {
                        Invisible = true,
                        Destroy = false
                    },
                    Explosions = {
                        Smaller = true,
                        Invisible = false,
                        Destroy = false
                    },
                    Particles = {
                        Invisible = true,
                        Destroy = false
                    },
                    TextLabels = {
                        LowerQuality = false,
                        Invisible = false,
                        Destroy = false
                    },
                    MeshParts = {
                        LowerQuality = true,
                        Invisible = false,
                        NoTexture = false,
                        NoMesh = false,
                        Destroy = false
                    },
                    ["No Particles"] = true,
                    ["No Camera Effects"] = true,
                    ["No Explosions"] = true,
                    ["No Clothes"] = true,
                    ["Low Water Graphics"] = true,
                    ["No Shadows"] = true,
                    ["Low Rendering"] = true,
                    ["Low Quality Parts"] = true,
                    Other = {
                        ["FPS Cap"] = 240,
                        ["No Camera Effects"] = true,
                        ["No Clothes"] = true,
                        ["Low Water Graphics"] = true,
                        ["No Shadows"] = true,
                        ["Low Rendering"] = true,
                        ["Low Quality Parts"] = true,
                        ["Low Quality Models"] = true,
                        ["Reset Materials"] = true,
                        ["Lower Quality MeshParts"] = true
                    }
                }

                local Players, Lighting, MaterialService = game:GetService("Players"), game:GetService("Lighting"), game:GetService("MaterialService")
                local ME, CanBeEnabled = Players.LocalPlayer, {"ParticleEmitter", "Trail", "Smoke", "Fire", "Sparkles"}

                local function PartOfCharacter(Instance)
                    for i, v in pairs(Players:GetPlayers()) do
                        if v ~= ME and v.Character and Instance:IsDescendantOf(v.Character) then
                            return true
                        end
                    end
                    return false
                end

                local function CheckIfBad(Instance)
                    pcall(function()
                        if not Instance:IsDescendantOf(Players) and not PartOfCharacter(Instance) then
                            if Instance:IsA("DataModelMesh") then
                                if _G.Settings.Meshes.LowDetail and Instance:IsA("SpecialMesh") then
                                    Instance.MeshId = ""
                                end
                                if _G.Settings.Meshes.Destroy then
                                    Instance:Destroy()
                                end
                            elseif Instance:IsA("FaceInstance") then
                                if _G.Settings.Images.Invisible then
                                    Instance.Transparency = 1
                                    Instance.Shiny = 1
                                end
                            elseif Instance:IsA("ShirtGraphic") then
                                if _G.Settings.Images.Invisible then
                                    Instance.Graphic = ""
                                end
                            elseif table.find(CanBeEnabled, Instance.ClassName) then
                                if _G.Settings["No Particles"] or _G.Settings.Particles.Invisible then
                                    Instance.Enabled = false
                                end
                            elseif Instance:IsA("PostEffect") and _G.Settings["No Camera Effects"] then
                                Instance.Enabled = false
                            elseif Instance:IsA("Explosion") then
                                if _G.Settings["No Explosions"] then
                                    Instance.BlastPressure = 1
                                    Instance.BlastRadius = 1
                                    Instance.Visible = false
                                end
                            elseif Instance:IsA("Clothing") or Instance:IsA("SurfaceAppearance") or Instance:IsA("BaseWrap") then
                                if _G.Settings["No Clothes"] then
                                    Instance:Destroy()
                                end
                            elseif Instance:IsA("BasePart") and not Instance:IsA("MeshPart") then
                                if _G.Settings["Low Quality Parts"] then
                                    Instance.Material = Enum.Material.Plastic
                                    Instance.Reflectance = 0
                                end
                            elseif Instance:IsA("Model") then
                                if _G.Settings.Other["Low Quality Models"] then
                                    Instance.LevelOfDetail = 1
                                end
                            elseif Instance:IsA("MeshPart") then
                                if _G.Settings.Other["Lower Quality MeshParts"] then
                                    Instance.RenderFidelity = 2
                                    Instance.Reflectance = 0
                                    Instance.Material = Enum.Material.Plastic
                                end
                            end
                        end
                    end)
                end

                -- Apply low water graphics
                pcall(function()
                    if _G.Settings["Low Water Graphics"] then
                        local terrain = workspace:FindFirstChildOfClass("Terrain")
                        if terrain then
                            terrain.WaterWaveSize = 0
                            terrain.WaterWaveSpeed = 0
                            terrain.WaterReflectance = 0
                            terrain.WaterTransparency = 0
                            if sethiddenproperty then
                                sethiddenproperty(terrain, "Decoration", false)
                            end
                        end
                    end
                end)

                -- Apply no shadows
                pcall(function()
                    if _G.Settings["No Shadows"] then
                        Lighting.GlobalShadows = false
                        Lighting.FogEnd = 9e9
                        Lighting.ShadowSoftness = 0
                        if sethiddenproperty then
                            sethiddenproperty(Lighting, "Technology", 2)
                        end
                    end
                end)

                -- Apply low rendering
                pcall(function()
                    if _G.Settings["Low Rendering"] then
                        settings().Rendering.QualityLevel = 1
                        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
                    end
                end)

                -- Reset materials
                pcall(function()
                    if _G.Settings.Other["Reset Materials"] then
                        for i, v in pairs(MaterialService:GetChildren()) do
                            v:Destroy()
                        end
                        MaterialService.Use2022Materials = false
                    end
                end)

                -- FPS Cap
                pcall(function()
                    if _G.Settings.Other["FPS Cap"] and setfpscap then
                        setfpscap(240)
                    end
                end)

                -- Process all existing instances
                local Descendants = game:GetDescendants()
                for i, v in pairs(Descendants) do
                    CheckIfBad(v)
                    if i % 500 == 0 then
                        task.wait()
                    end
                end

                -- Connect to new instances
                game.DescendantAdded:Connect(CheckIfBad)

                print("🚀 Low Graphics FPS Booster fully loaded!")
            end)
        else
            print("🚀 Low Graphics DISABLED")
            -- Note: Some changes like destroyed objects cannot be reverted
            print("⚠️ Some low graphics changes cannot be reverted (destroyed objects)")
        end
    end,
})


-- UI Settings Tab
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu", "list")

MenuGroup:AddButton({
    Text = "Unload",
    Func = function()
        -- Stop all connections before unloading
        autoSellInventoryEnabled = false
        autoSellItemEnabled = false
        autoEquipEnabled = false
        autoDigEnabled = false
        autoWalkEnabled = false

        if autoEquipConnection then
            autoEquipConnection:Disconnect()
        end
        if autoDigConnection then
            autoDigConnection:Disconnect()
        end
        if autoSellItemConnection then
            autoSellItemConnection:Disconnect()
        end
        if autoWalkConnection then
            autoWalkConnection:Disconnect()
        end

        print("🔴 COLDBIND Unloaded")
        Library:Unload()
    end,
    Tooltip = "Unload the UI",
})

MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default = "End", NoUI = true, Text = "Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

-- Theme Manager
ThemeManager:SetLibrary(Library)
ThemeManager:SetFolder("COLDBIND")
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- Save Manager
SaveManager:SetLibrary(Library)
SaveManager:SetFolder("COLDBIND/configs")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

-- Player Tab Implementation
local PlayerGroupBox = Tabs.Player:AddLeftGroupbox("Player Movement", "user")

-- Variables for player tab
local infiniteJumpEnabled = false
local noclipEnabled = false
local cflyEnabled = false
local flyKeyDown = nil
local flyKeyUp = nil
local FLYING = false
local QEfly = true
local iyflyspeed = 1
local IsOnMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())

-- Jump Power Slider
PlayerGroupBox:AddSlider("JumpPowerSlider", {
    Text = "Jump Power",
    Default = 50,
    Min = 0,
    Max = 250,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = Value
            end
        end
    end,
})

-- Speed Slider
PlayerGroupBox:AddSlider("SpeedSlider", {
    Text = "Speed",
    Default = 16,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Compact = false,

    Callback = function(Value)
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Value
            end
        end
    end,
})

-- No Clip Toggle
PlayerGroupBox:AddToggle("NoClip", {
    Text = "No Clip",
    Default = false,

    Callback = function(Value)
        noclipEnabled = Value

        if noclipEnabled then
            print("🚀 No Clip ENABLED")

            -- Connect noclip function to RunService
            if not noclipConnection then
                noclipConnection = RunService.Stepped:Connect(function()
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        else
            print("🚀 No Clip DISABLED")

            -- Disconnect noclip function
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end

            -- Restore collision
            local character = LocalPlayer.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        if part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end
    end,
})

-- Infinite Jump Toggle
PlayerGroupBox:AddToggle("InfiniteJump", {
    Text = "Infinite Jump",
    Default = false,

    Callback = function(Value)
        infiniteJumpEnabled = Value

        if infiniteJumpEnabled then
            print("🚀 Infinite Jump ENABLED")

            -- Connect infinite jump function to UserInputService
            if not infiniteJumpConnection then
                infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local character = LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        else
            print("🚀 Infinite Jump DISABLED")

            -- Disconnect infinite jump function
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
        end
    end,
})

-- CFrame Fly Functions
local function getRoot(char)
    local rootPart = char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
    return rootPart
end

local function NOFLY()
    FLYING = false
    if flyKeyDown or flyKeyUp then 
        flyKeyDown:Disconnect() 
        flyKeyUp:Disconnect() 
    end
    if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

local function sFLY(vfly)
    repeat wait() until LocalPlayer and LocalPlayer.Character and getRoot(LocalPlayer.Character) and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    repeat wait() until UserInputService
    if flyKeyDown or flyKeyUp then flyKeyDown:Disconnect() flyKeyUp:Disconnect() end

    local T = getRoot(LocalPlayer.Character)
    local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
    local SPEED = 0

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro')
        local BV = Instance.new('BodyVelocity')
        BG.P = 9e4
        BG.Parent = T
        BV.Parent = T
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.cframe = T.CFrame
        BV.velocity = Vector3.new(0, 0, 0)
        BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            repeat wait()
                if not vfly and LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                    LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0 then
                    SPEED = 50
                elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 or CONTROL.Q + CONTROL.E ~= 0) and SPEED ~= 0 then
                    SPEED = 0
                end
                if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B) ~= 0 or (CONTROL.Q + CONTROL.E) ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (CONTROL.F + CONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                    lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
                elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and (CONTROL.Q + CONTROL.E) == 0 and SPEED ~= 0 then
                    BV.velocity = ((workspace.CurrentCamera.CoordinateFrame.lookVector * (lCONTROL.F + lCONTROL.B)) + ((workspace.CurrentCamera.CoordinateFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B + CONTROL.Q + CONTROL.E) * 0.2, 0).p) - workspace.CurrentCamera.CoordinateFrame.p)) * SPEED
                else
                    BV.velocity = Vector3.new(0, 0, 0)
                end
                BG.cframe = workspace.CurrentCamera.CoordinateFrame
            until not FLYING
            CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            lCONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if LocalPlayer.Character:FindFirstChildOfClass('Humanoid') then
                LocalPlayer.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end
    flyKeyDown = UserInputService.InputBegan:Connect(function(KEY)
        if KEY.KeyCode == Enum.KeyCode.W then
            CONTROL.F = iyflyspeed
        elseif KEY.KeyCode == Enum.KeyCode.S then
            CONTROL.B = -iyflyspeed
        elseif KEY.KeyCode == Enum.KeyCode.A then
            CONTROL.L = -iyflyspeed
        elseif KEY.KeyCode == Enum.KeyCode.D then
            CONTROL.R = iyflyspeed
        elseif QEfly and KEY.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = iyflyspeed*2
        elseif QEfly and KEY.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = -iyflyspeed*2
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)
    flyKeyUp = UserInputService.InputEnded:Connect(function(KEY)
        if KEY.KeyCode == Enum.KeyCode.W then
            CONTROL.F = 0
        elseif KEY.KeyCode == Enum.KeyCode.S then
            CONTROL.B = 0
        elseif KEY.KeyCode == Enum.KeyCode.A then
            CONTROL.L = 0
        elseif KEY.KeyCode == Enum.KeyCode.D then
            CONTROL.R = 0
        elseif KEY.KeyCode == Enum.KeyCode.E then
            CONTROL.Q = 0
        elseif KEY.KeyCode == Enum.KeyCode.Q then
            CONTROL.E = 0
        end
    end)
    FLY()
end

-- Mobile Fly Implementation
local velocityHandlerName = "VelocityHandler"
local gyroHandlerName = "GyroHandler"
local mfly1
local mfly2

local function unmobilefly(speaker)
    pcall(function()
        FLYING = false
        local root = getRoot(speaker.Character)
        root:FindFirstChild(velocityHandlerName):Destroy()
        root:FindFirstChild(gyroHandlerName):Destroy()
        speaker.Character:FindFirstChildWhichIsA("Humanoid").PlatformStand = false
        mfly1:Disconnect()
        mfly2:Disconnect()
    end)
end

local function mobilefly(speaker)
    unmobilefly(speaker)
    FLYING = true

    local root = getRoot(speaker.Character)
    local camera = workspace.CurrentCamera
    local v3none = Vector3.new()
    local v3zero = Vector3.new(0, 0, 0)
    local v3inf = Vector3.new(9e9, 9e9, 9e9)

    local controlModule = require(speaker.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
    local bv = Instance.new("BodyVelocity")
    bv.Name = velocityHandlerName
    bv.Parent = root
    bv.MaxForce = v3zero
    bv.Velocity = v3zero

    local bg = Instance.new("BodyGyro")
    bg.Name = gyroHandlerName
    bg.Parent = root
    bg.MaxTorque = v3inf
    bg.P = 1000
    bg.D = 50

    mfly1 = speaker.CharacterAdded:Connect(function()
        local bv = Instance.new("BodyVelocity")
        bv.Name = velocityHandlerName
        bv.Parent = root
        bv.MaxForce = v3zero
        bv.Velocity = v3zero

        local bg = Instance.new("BodyGyro")
        bg.Name = gyroHandlerName
        bg.Parent = root
        bg.MaxTorque = v3inf
        bg.P = 1000
        bg.D = 50
    end)

    mfly2 = RunService.RenderStepped:Connect(function()
        root = getRoot(speaker.Character)
        camera = workspace.CurrentCamera
        if speaker.Character:FindFirstChildWhichIsA("Humanoid") and root and root:FindFirstChild(velocityHandlerName) and root:FindFirstChild(gyroHandlerName) then
            local humanoid = speaker.Character:FindFirstChildWhichIsA("Humanoid")
            local VelocityHandler = root:FindFirstChild(velocityHandlerName)
            local GyroHandler = root:FindFirstChild(gyroHandlerName)

            VelocityHandler.MaxForce = v3inf
            GyroHandler.MaxTorque = v3inf
            humanoid.PlatformStand = true
            GyroHandler.CFrame = camera.CoordinateFrame
            VelocityHandler.Velocity = v3none

            local direction = controlModule:GetMoveVector()
            if direction.X > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (iyflyspeed * 50))
            end
            if direction.X < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity + camera.CFrame.RightVector * (direction.X * (iyflyspeed * 50))
            end
            if direction.Z > 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (iyflyspeed * 50))
            end
            if direction.Z < 0 then
                VelocityHandler.Velocity = VelocityHandler.Velocity - camera.CFrame.LookVector * (direction.Z * (iyflyspeed * 50))
            end
        end
    end)
end

-- CFrame Fly Toggle
PlayerGroupBox:AddToggle("CFlyToggle", {
    Text = "CFrame Fly",
    Default = false,

    Callback = function(Value)
        cflyEnabled = Value

        if cflyEnabled then
            print("🚀 CFrame Fly ENABLED")

            if not IsOnMobile then
                NOFLY()
                wait()
                sFLY()
            else
                mobilefly(LocalPlayer)
            end
        else
            print("🚀 CFrame Fly DISABLED")

            if not IsOnMobile then
                NOFLY()
            else
                unmobilefly(LocalPlayer)
            end
        end
    end,
})

-- CFrame Fly Speed Slider
PlayerGroupBox:AddSlider("CFlySpeedSlider", {
    Text = "Fly Speed",
    Default = 1,
    Min = 0.1,
    Max = 10,
    Rounding = 1,
    Compact = false,

    Callback = function(Value)
        iyflyspeed = Value
    end,
})

-- Update character values when character respawns
LocalPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Wait for character to fully load

    -- Update jump power
    local humanoid = character:WaitForChild("Humanoid")
    if humanoid then
        humanoid.JumpPower = Options.JumpPowerSlider.Value
        humanoid.WalkSpeed = Options.SpeedSlider.Value
    end

    -- Re-enable noclip if it was enabled
    if noclipEnabled and noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = RunService.Stepped:Connect(function()
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end

    -- Re-enable CFrame fly if it was enabled
    if cflyEnabled then
        if not IsOnMobile then
            NOFLY()
            wait()
            sFLY()
        else
            mobilefly(LocalPlayer)
        end
    end
end)

print("🎯 COLDBIND Loaded!")
print("📖 Use the toggles to enable Auto Equip Shovel and Auto Dig")
