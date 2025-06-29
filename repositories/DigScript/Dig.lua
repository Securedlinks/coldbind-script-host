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
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
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
		
		-- If we just finished digging and have a last dig position, move away from it
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
			print("🚶 Auto Walk ENABLED - Will move after digging!")
			
			-- Start auto walk loop
			autoWalkConnection = RunService.Heartbeat:Connect(function()
				task.wait(1) -- Check every second
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

print("🎯 COLDBIND Loaded!")
print("📖 Use the toggles to enable Auto Equip Shovel and Auto Dig")


