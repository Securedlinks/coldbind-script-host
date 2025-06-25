-- Simple Auto Strong Hit Script
-- Toggle GUI to always hit strong areas

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Variables
local autoHitEnabled = false
local connection = nil

-- Create Simple GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoStrongHitGUI"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.BorderSizePixel = 2
Frame.BorderColor3 = Color3.fromRGB(255, 255, 255)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0, 0, 0, 0)
Title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
Title.Text = "Auto Strong Hit"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0.8, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.1, 0, 0.4, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleButton.Text = "OFF"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextScaled = true
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0.8, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Waiting..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.SourceSans
StatusLabel.Parent = Frame

-- Make GUI draggable
local dragging = false
local dragStart = nil
local startPos = nil

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Frame.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Auto Hit Function
local function autoStrongHit()
    if not autoHitEnabled then return end
    
    local digUI = PlayerGui:FindFirstChild("Dig")
    if not digUI then 
        StatusLabel.Text = "No dig minigame"
        return 
    end
    
    local safezone = digUI:FindFirstChild("Safezone")
    if not safezone then return end
    
    local holder = safezone:FindFirstChild("Holder")
    if not holder then return end
    
    local playerBar = holder:FindFirstChild("PlayerBar")
    local areaStrong = holder:FindFirstChild("Area_Strong")
    
    if not playerBar or not areaStrong then return end
    if not areaStrong.Visible or areaStrong.AbsoluteSize.X < 2 then 
        StatusLabel.Text = "Waiting for strong area..."
        return 
    end
    
    -- Get positions
    local playerPos = playerBar.Position.X.Scale
    local strongLeft = areaStrong.Position.X.Scale
    local strongRight = strongLeft + areaStrong.Size.X.Scale
    local strongCenter = strongLeft + (areaStrong.Size.X.Scale / 2)
    
    StatusLabel.Text = "Strong area detected!"
    
    -- Instantly hit if player is in strong area (no delay, no cooldown)
    if playerPos >= strongLeft and playerPos <= strongRight then
        StatusLabel.Text = "🎯 HITTING STRONG!"
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
        VIM:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    else
        local distance = math.abs(playerPos - strongCenter)
        StatusLabel.Text = "Waiting... (dist: " .. math.floor(distance * 1000) .. ")"
    end
end

-- Toggle Function
local function toggleAutoHit()
    autoHitEnabled = not autoHitEnabled
    
    if autoHitEnabled then
        ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        ToggleButton.Text = "ON"
        StatusLabel.Text = "Auto hit enabled"
        
        -- Start the auto hit loop
        connection = RunService.Heartbeat:Connect(autoStrongHit)
        print("🟢 Auto Strong Hit ENABLED")
    else
        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        ToggleButton.Text = "OFF"
        StatusLabel.Text = "Auto hit disabled"
        
        -- Stop the auto hit loop
        if connection then
            connection:Disconnect()
            connection = nil
        end
        print("🔴 Auto Strong Hit DISABLED")
    end
end

-- Connect toggle button
ToggleButton.MouseButton1Click:Connect(toggleAutoHit)

-- Keyboard shortcut (X key)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.X then
        toggleAutoHit()
    end
end)

print("=== AUTO STRONG HIT LOADED ===")
print("• Click the toggle button or press X to enable/disable")
print("• Script will automatically hit strong areas when enabled")
print("• Drag the GUI to move it around")
