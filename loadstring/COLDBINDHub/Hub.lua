-- COLDBIND Hub
-- Made by COLDBIND Team
-- Version 1.0

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "COLDBINDHub"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame (Glass Panel)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 480)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -240)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Glass Effect
local glassEffect = Instance.new("Frame")
glassEffect.Name = "GlassEffect"
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.Position = UDim2.new(0, 0, 0, 0)
glassEffect.BackgroundColor3 = Color3.fromRGB(139, 69, 255)
glassEffect.BackgroundTransparency = 0.97
glassEffect.BorderSizePixel = 0
glassEffect.Parent = mainFrame

-- Corner Radius
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 16)
glassCorner.Parent = glassEffect

-- Border Glow
local borderGlow = Instance.new("UIStroke")
borderGlow.Color = Color3.fromRGB(139, 69, 255)
borderGlow.Thickness = 2
borderGlow.Transparency = 0.6
borderGlow.Parent = mainFrame

-- Shadow
local shadow = Instance.new("Frame")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundColor3 = Color3.fromRGB(139, 69, 255)
shadow.BackgroundTransparency = 0.85
shadow.BorderSizePixel = 0
shadow.ZIndex = mainFrame.ZIndex - 1
shadow.Parent = mainFrame

local shadowCorner = Instance.new("UICorner")
shadowCorner.CornerRadius = UDim.new(0, 26)
shadowCorner.Parent = shadow

-- Title Bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 60)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(139, 69, 255)
titleBar.BackgroundTransparency = 0.97
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

-- Title
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -80, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "COLDBIND HUB"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.Parent = titleBar

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 0, 40)
closeButton.Position = UDim2.new(1, -50, 0, 10)
closeButton.BackgroundColor3 = Color3.fromRGB(139, 69, 255)
closeButton.BackgroundTransparency = 0.85
closeButton.BorderSizePixel = 0
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 18
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Content Frame
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -40, 1, -100)
contentFrame.Position = UDim2.new(0, 20, 0, 70)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

-- Description
local description = Instance.new("TextLabel")
description.Name = "Description"
description.Size = UDim2.new(1, 0, 0, 50)
description.Position = UDim2.new(0, 0, 0, 0)
description.BackgroundTransparency = 1
description.Text = "Choose a script to load:"
description.TextColor3 = Color3.fromRGB(200, 200, 200)
description.TextSize = 16
description.TextXAlignment = Enum.TextXAlignment.Center
description.Font = Enum.Font.Gotham
description.Parent = contentFrame

-- Script Buttons Container
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, 0, 1, -60)
buttonsFrame.Position = UDim2.new(0, 0, 0, 60)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = contentFrame

-- Function to create script button
local function createScriptButton(name, description, position, scriptUrl)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Size = UDim2.new(1, 0, 0, 70)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    button.BackgroundTransparency = 0.15
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = buttonsFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 12)
    buttonCorner.Parent = button
    
    local buttonStroke = Instance.new("UIStroke")
    buttonStroke.Color = Color3.fromRGB(139, 69, 255)
    buttonStroke.Thickness = 1.5
    buttonStroke.Transparency = 0.7
    buttonStroke.Parent = button
    
    -- Button Title
    local buttonTitle = Instance.new("TextLabel")
    buttonTitle.Name = "Title"
    buttonTitle.Size = UDim2.new(1, -20, 0, 28)
    buttonTitle.Position = UDim2.new(0, 15, 0, 10)
    buttonTitle.BackgroundTransparency = 1
    buttonTitle.Text = name
    buttonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonTitle.TextSize = 19
    buttonTitle.TextXAlignment = Enum.TextXAlignment.Left
    buttonTitle.Font = Enum.Font.GothamBold
    buttonTitle.Parent = button
    
    -- Button Description
    local buttonDesc = Instance.new("TextLabel")
    buttonDesc.Name = "Description"
    buttonDesc.Size = UDim2.new(1, -20, 0, 22)
    buttonDesc.Position = UDim2.new(0, 15, 0, 38)
    buttonDesc.BackgroundTransparency = 1
    buttonDesc.Text = description
    buttonDesc.TextColor3 = Color3.fromRGB(180, 180, 200)
    buttonDesc.TextSize = 13
    buttonDesc.TextXAlignment = Enum.TextXAlignment.Left
    buttonDesc.Font = Enum.Font.Gotham
    buttonDesc.Parent = button
    
    -- Load Indicator
    local loadIcon = Instance.new("TextLabel")
    loadIcon.Name = "LoadIcon"
    loadIcon.Size = UDim2.new(0, 35, 0, 35)
    loadIcon.Position = UDim2.new(1, -45, 0, 17.5)
    loadIcon.BackgroundTransparency = 1
    loadIcon.Text = "→"
    loadIcon.TextColor3 = Color3.fromRGB(139, 69, 255)
    loadIcon.TextSize = 22
    loadIcon.Font = Enum.Font.GothamBold
    loadIcon.Parent = button
    
    -- Hover Effects
    local function onHover()
        local tween = TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundTransparency = 0.05,
            BackgroundColor3 = Color3.fromRGB(139, 69, 255)
        })
        local strokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.25), {
            Transparency = 0.3,
            Color = Color3.fromRGB(180, 120, 255)
        })
        local iconTween = TweenService:Create(loadIcon, TweenInfo.new(0.25), {
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
        tween:Play()
        strokeTween:Play()
        iconTween:Play()
    end
    
    local function onLeave()
        local tween = TweenService:Create(button, TweenInfo.new(0.25), {
            BackgroundTransparency = 0.15,
            BackgroundColor3 = Color3.fromRGB(18, 18, 24)
        })
        local strokeTween = TweenService:Create(buttonStroke, TweenInfo.new(0.25), {
            Transparency = 0.7,
            Color = Color3.fromRGB(139, 69, 255)
        })
        local iconTween = TweenService:Create(loadIcon, TweenInfo.new(0.25), {
            TextColor3 = Color3.fromRGB(139, 69, 255)
        })
        tween:Play()
        strokeTween:Play()
        iconTween:Play()
    end
    
    button.MouseEnter:Connect(onHover)
    button.MouseLeave:Connect(onLeave)
    
    -- Click Function
    button.MouseButton1Click:Connect(function()
        -- Loading animation
        buttonTitle.Text = "Loading..."
        loadIcon.Text = "⟳"
        
        -- Rotation animation for loading icon
        local rotationTween
        local function startRotation()
            rotationTween = TweenService:Create(loadIcon, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {
                Rotation = 360
            })
            rotationTween:Play()
        end
        startRotation()
        
        -- Load the script
        spawn(function()
            pcall(function()
                loadstring(game:HttpGet(scriptUrl))()
            end)
            
            -- Success animation
            wait(1)
            if rotationTween then
                rotationTween:Cancel()
            end
            loadIcon.Rotation = 0
            loadIcon.Text = "✓"
            buttonTitle.Text = name .. " - Loaded!"
            
            wait(2)
            -- Close hub
            screenGui:Destroy()
        end)
    end)
    
    return button
end

-- Create script buttons
local growButton = createScriptButton(
    "Grow A Garden",
    "Auto farming script for Grow A Garden",
    UDim2.new(0, 0, 0, 0),
    "https://coldbind-script-host.onrender.com/api/raw/GrowAGarden/Grow.lua?key=coldbind_access_2024"
)

local aimbotButton = createScriptButton(
    "Universal Aimbot",
    "Advanced aimbot with ESP and features",
    UDim2.new(0, 0, 0, 85),
    "https://coldbind-script-host.onrender.com/api/raw/UniAimbot/UniAimbot.lua?key=coldbind_access_2024"
)

local digButton = createScriptButton(
    "Dig Script",
    "Auto strong hit for dig minigames",
    UDim2.new(0, 0, 0, 170),
    "https://coldbind-script-host.onrender.com/api/raw/DigScript/Dig.lua?key=coldbind_access_2024"
)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 1, -35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "COLDBIND Hub v1.0 | Ready"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- Dragging functionality
local dragging = false
local dragStart = nil
local startPos = nil

local function onInputBegan(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                connection:Disconnect()
            end
        end)
    end
end

local function onInputChanged(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end

titleBar.InputBegan:Connect(onInputBegan)
UserInputService.InputChanged:Connect(onInputChanged)

-- Close button functionality
closeButton.MouseButton1Click:Connect(function()
    -- Fade out animation
    local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    local shadowTween = TweenService:Create(shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    local glassTween = TweenService:Create(glassEffect, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    local borderTween = TweenService:Create(borderGlow, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Transparency = 1
    })
    
    local titleBarTween = TweenService:Create(titleBar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    -- Fade out all text elements
    local titleTween = TweenService:Create(title, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1
    })
    
    local descTween = TweenService:Create(description, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1
    })
    
    local statusTween = TweenService:Create(statusLabel, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        TextTransparency = 1
    })
    
    local closeBtnTween = TweenService:Create(closeButton, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1,
        TextTransparency = 1
    })
    
    -- Fade out buttons and their text
    local growBtnTween = TweenService:Create(growButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    local aimbotBtnTween = TweenService:Create(aimbotButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    local digBtnTween = TweenService:Create(digButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = 1
    })
    
    -- Fade out button text elements
    for _, child in pairs(growButton:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
        elseif child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 1
            }):Play()
        end
    end
    
    for _, child in pairs(aimbotButton:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
        elseif child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 1
            }):Play()
        end
    end
    
    for _, child in pairs(digButton:GetChildren()) do
        if child:IsA("TextLabel") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                TextTransparency = 1
            }):Play()
        elseif child:IsA("UIStroke") then
            TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 1
            }):Play()
        end
    end
    
    -- Play all animations
    closeTween:Play()
    shadowTween:Play()
    glassTween:Play()
    borderTween:Play()
    titleBarTween:Play()
    titleTween:Play()
    descTween:Play()
    statusTween:Play()
    closeBtnTween:Play()
    growBtnTween:Play()
    aimbotBtnTween:Play()
    digBtnTween:Play()
    
    closeTween.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)

-- Entrance animation
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

local entranceTween = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 520, 0, 480),
    Position = UDim2.new(0.5, -260, 0.5, -240)
})
entranceTween:Play()

-- Keep GUI in fixed position after entrance animation

-- Close button hover effects
closeButton.MouseEnter:Connect(function()
    local tween = TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.6,
        BackgroundColor3 = Color3.fromRGB(255, 80, 120),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    tween:Play()
end)

closeButton.MouseLeave:Connect(function()
    local tween = TweenService:Create(closeButton, TweenInfo.new(0.2), {
        BackgroundTransparency = 0.85,
        BackgroundColor3 = Color3.fromRGB(139, 69, 255),
        TextColor3 = Color3.fromRGB(255, 255, 255)
    })
    tween:Play()
end)

print("COLDBIND Hub loaded successfully!")
