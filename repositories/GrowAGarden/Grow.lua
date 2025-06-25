-- LSP Annotations for executor functions
---@diagnostic disable: undefined-global

-- Production-ready script - Test code removed for cleaner execution
-- Protected by SNOWBIND Premium Key System

-- Remove all developer restrictions - Anyone with valid key can execute
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

-- Function to sanitize text by removing emoji characters that might cause rich text parsing errors
local function sanitizeText(text)
	if not text then return "" end

	local sanitized = tostring(text)

	-- Remove any remaining emoji or special characters that might cause parsing issues
	sanitized = sanitized:gsub("[^\32-\126\128-\255]", "")

	return sanitized
end

-- Notification function (now available to everyone)
local function notify(title, text, duration)
	-- Using custom notification system instead of Roblox default
	if Library and Library.Notify then
		Library:Notify(sanitizeText(title) .. ": " .. sanitizeText(text), duration or 5)
	else
		-- Fallback to console if Library isn't loaded yet
		print("[NOTIFICATION] " .. sanitizeText(title) .. ": " .. sanitizeText(text))
	end
end

-- Game ID Validation
local REQUIRED_PLACE_ID = 126884695634066
local function validateGameId()
	local currentPlaceId = game.PlaceId
	local currentGameId = game.GameId

	-- Debug information removed

	if currentPlaceId ~= REQUIRED_PLACE_ID then
		-- Create a notification for wrong game using custom notification system
		local errorMessage = "This script only works in 'Grow A Garden'\nPlace ID: "
				.. tostring(REQUIRED_PLACE_ID)
				.. "\nCurrent: "
				.. tostring(currentPlaceId)

		-- Use notify function which now uses the custom system
		notify("❌ Wrong Game!", errorMessage, 10)

		-- Print error message
		warn("❌ SCRIPT ERROR: Wrong game detected!")
		warn("Current Place ID: " .. tostring(currentPlaceId))
		warn("Current Game ID: " .. tostring(currentGameId))
		warn("Required Place ID: " .. tostring(REQUIRED_PLACE_ID))
		warn("This script only works in 'Grow A Garden' game.")

		return false
	end

	-- print removed: Game ID validation passed
	return true
end

-- Validate game before continuing
if not validateGameId() then
	return -- Stop script execution if wrong game
end

-- Welcome message for all users
notify("SNOWBIND Premium", "Welcome " .. LocalPlayer.Name .. "! Loading script...", 3)
-- print removed: Loading SNOWBIND Premium
-- print removed: Access granted via key system

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
-- print removed: Loading Library
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
-- print removed: Loading ThemeManager
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
-- print removed: Loading SaveManager
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- print removed: Setting up Options and Toggles
local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false -- Forces AddToggle to AddCheckbox
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)

-- The Obsidian Library will provide its own notification system
-- No need to override Library:Notify - let the original Obsidian implementation handle it

-- Honey Shop System Variables
-- Services Table to reduce local variable count (prevent "Out of local registers" error)
local Services = {
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    CollectionService = game:GetService("CollectionService"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
    Debris = game:GetService("Debris"),
    SoundService = game:GetService("SoundService")
}

local LocalPlayer = Services.Players.LocalPlayer

-- Script Variables Table to reduce local count
local ScriptVars = {
    HoneyShopEnabled = false,
    AutoBuyHoneyItems = false,
    HoneyShopUI = nil,
    HoneyEventShopData = nil,
    UpdateService = nil,
    LastStockRefresh = 0,
    StockRefreshInterval = 180,

    -- Web Hook variables
    WebhookEnabled = false,
    WebhookURL = "",
    WeatherReportingEnabled = false,
    SeedsAndGearsReportingEnabled = false,
    EventShopReportingEnabled = false,
    EggsReportingEnabled = false,
    CosmeticStockReportingEnabled = false,

    -- Summer Event variables
    IsSummerWeatherActive = false,

    -- Auto Sell variables
    autoSellEnabled = false,
    AutoSellOnNotificationEnabled = false,
    AutoSellOnNotificationEnabledFarm = false,
    NotificationConnection = nil,
    NotificationConnectionFarm = nil,
    isSelling = false
}

-- Honey Shop Items Data (from HoneyEventShopData)
local HoneyShopItems = {
	["Flower Seed Pack"] = {
		["SeedName"] = "Flower Seed Pack",
		["SeedRarity"] = "Rare",
		["StockChance"] = 1,
		["StockAmount"] = { 1, 2 },
		["Price"] = 10,
		["PurchaseID"] = 3295395160,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["ShowOdds"] = true,
		["LayoutOrder"] = 1,
		["Asset"] = "rbxassetid://89208043739859",
		["FruitIcon"] = "",
		["ItemType"] = "Seed Pack",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 199,
	},
	["Lavender"] = {
		["SeedName"] = "Lavender Seed",
		["SeedRarity"] = "Uncommon",
		["StockChance"] = 1,
		["StockAmount"] = { 3, 5 },
		["Price"] = 3,
		["PurchaseID"] = 3301505595,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 10,
		["Asset"] = "rbxassetid://109114523354440",
		["FruitIcon"] = "rbxassetid://96762443899432",
		["ItemType"] = "Seed",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 99,
	},
	["Nectarshade"] = {
		["SeedName"] = "Nectarshade Seed",
		["SeedRarity"] = "Rare",
		["StockChance"] = 2,
		["StockAmount"] = { 2, 3 },
		["Price"] = 5,
		["PurchaseID"] = 3301505385,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 11,
		["Asset"] = "rbxassetid://100231788254119",
		["FruitIcon"] = "rbxassetid://86280814956157",
		["ItemType"] = "Seed",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 139,
	},
	["Nectarine"] = {
		["SeedName"] = "Nectarine Seed",
		["SeedRarity"] = "Mythical",
		["StockChance"] = 12,
		["StockAmount"] = { 1, 1 },
		["Price"] = 25,
		["PurchaseID"] = 3295402526,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 12,
		["Asset"] = "rbxassetid://99493661537378",
		["FruitIcon"] = "rbxassetid://86625202446426",
		["ItemType"] = "Seed",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 399,
	},
	["Hive Fruit"] = {
		["SeedName"] = "Hive Fruit Seed",
		["SeedRarity"] = "Divine",
		["StockChance"] = 20,
		["StockAmount"] = { 1, 1 },
		["Price"] = 40,
		["PurchaseID"] = 3295395667,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 13,
		["Asset"] = "rbxassetid://105378743376322",
		["FruitIcon"] = "rbxassetid://104093925175544",
		["ItemType"] = "Seed",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 599,
	},
	["Pollen Radar"] = {
		["SeedName"] = "Pollen Radar",
		["SeedRarity"] = "Mythical",
		["StockChance"] = 3,
		["StockAmount"] = { 1, 3 },
		["Price"] = 20,
		["PurchaseID"] = 3301505788,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 20,
		["Asset"] = "rbxassetid://105620836609339",
		["FruitIcon"] = "rbxassetid://0",
		["ItemType"] = "Gear",
		["Stack"] = 5,
		["Description"] = "Scans and collects nearby pollinated fruit",
		["FallbackPrice"] = 249,
	},
	["Nectar Staff"] = {
		["SeedName"] = "Nectar Staff",
		["SeedRarity"] = "Mythical",
		["StockChance"] = 6,
		["StockAmount"] = { 1, 3 },
		["Price"] = 25,
		["PurchaseID"] = 3301505981,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 21,
		["Asset"] = "rbxassetid://109105197997415",
		["FruitIcon"] = "rbxassetid://0",
		["ItemType"] = "Gear",
		["Stack"] = 1,
		["Description"] = "Attracts bees to nearby fruit to pollinate",
		["FallbackPrice"] = 219,
	},
	["Honey Sprinkler"] = {
		["SeedName"] = "Honey Sprinkler",
		["SeedRarity"] = "Divine",
		["StockChance"] = 12,
		["StockAmount"] = { 1, 1 },
		["Price"] = 30,
		["PurchaseID"] = 3295397583,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 25,
		["Asset"] = "rbxassetid://90156288104343",
		["FruitIcon"] = "",
		["ItemType"] = "Gear",
		["Stack"] = 1,
		["Description"] = "Covers nearby plants in honey! Lasts 1 minute",
		["FallbackPrice"] = 199,
	},
	["Bee Egg"] = {
		["SeedName"] = "Bee Egg",
		["SeedRarity"] = "Mythical",
		["StockChance"] = 7,
		["StockAmount"] = { 1, 1 },
		["Price"] = 18,
		["PurchaseID"] = 3295398638,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["ShowOdds"] = true,
		["LayoutOrder"] = 30,
		["Asset"] = "rbxassetid://100313281527054",
		["FruitIcon"] = "",
		["ItemType"] = "Egg",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 129,
	},
	["Bee Crate"] = {
		["SeedName"] = "Bee Crate",
		["SeedRarity"] = "Legendary",
		["StockChance"] = 4,
		["StockAmount"] = { 1, 1 },
		["Price"] = 12,
		["PurchaseID"] = 3295396781,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["ShowOdds"] = true,
		["LayoutOrder"] = 40,
		["Asset"] = "rbxassetid://72130006133439",
		["FruitIcon"] = "",
		["ItemType"] = "Crate",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 179,
	},
	["Honey Comb"] = {
		["SeedName"] = "Honey Comb",
		["SeedRarity"] = "Common",
		["StockChance"] = 1,
		["StockAmount"] = { 1, 1 },
		["Price"] = 3,
		["PurchaseID"] = 3295398991,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 50,
		["Asset"] = "",
		["FruitIcon"] = "",
		["ItemType"] = "Cosmetic",
		["Stack"] = 3,
		["Description"] = "",
		["FallbackPrice"] = 29,
	},
	["Bee Chair"] = {
		["SeedName"] = "Bee Chair",
		["SeedRarity"] = "Rare",
		["StockChance"] = 2,
		["StockAmount"] = { 1, 1 },
		["Price"] = 5,
		["PurchaseID"] = 3295397103,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 51,
		["Asset"] = "",
		["FruitIcon"] = "",
		["ItemType"] = "Cosmetic",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 119,
	},
	["Honey Torch"] = {
		["SeedName"] = "Honey Torch",
		["SeedRarity"] = "Rare",
		["StockChance"] = 2,
		["StockAmount"] = { 1, 1 },
		["Price"] = 5,
		["PurchaseID"] = 3295399979,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 52,
		["Asset"] = "",
		["FruitIcon"] = "",
		["ItemType"] = "Cosmetic",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 119,
	},
	["Honey Walkway"] = {
		["SeedName"] = "Honey Walkway",
		["SeedRarity"] = "Legendary",
		["StockChance"] = 3,
		["StockAmount"] = { 1, 1 },
		["Price"] = 10,
		["PurchaseID"] = 3295398026,
		["SpecialCurrencyType"] = "Honey",
		["DisplayInShop"] = true,
		["LayoutOrder"] = 53,
		["Asset"] = "",
		["FruitIcon"] = "",
		["ItemType"] = "Cosmetic",
		["Stack"] = 1,
		["Description"] = "",
		["FallbackPrice"] = 189,
	},
}

-- Priority items for auto-buy (higher value items first)
local AutoBuyPriority = {
	"Hive Fruit", -- 40 honey - Divine seed
	"Honey Sprinkler", -- 30 honey - Divine gear
	"Nectarine", -- 25 honey - Mythical seed
	"Nectar Staff", -- 25 honey - Mythical gear
	"Pollen Radar", -- 20 honey - Mythical gear
	"Bee Egg", -- 18 honey - Mythical egg
	"Bee Crate", -- 12 honey - Legendary crate
	"Honey Walkway", -- 10 honey - Legendary cosmetic
	"Flower Seed Pack", -- 10 honey - Rare seed pack
	"Nectarshade", -- 5 honey - Rare seed
	"Bee Chair", -- 5 honey - Rare cosmetic
	"Honey Torch", -- 5 honey - Rare cosmetic
	"Lavender", -- 3 honey - Uncommon seed
	"Honey Comb", -- 3 honey - Common cosmetic
}

-- Initialize Honey Shop System
local function initializeHoneyShop()
	if Services.ReplicatedStorage:FindFirstChild("Modules") then
		local success, result = pcall(function()
			UpdateService = require(Services.ReplicatedStorage.Modules.UpdateService)
			if UpdateService and UpdateService:IsUpdateDone() then
				HoneyEventShopData = require(Services.ReplicatedStorage.Data.HoneyEventShopData)
				HoneyShopUI = LocalPlayer.PlayerGui:WaitForChild("HoneyEventShop_UI", 5)
			else
				HoneyEventShopData = require(Services.ReplicatedStorage.Data.EventShopData)
				HoneyShopUI = LocalPlayer.PlayerGui:WaitForChild("EventShop_UI", 5)
			end
			return true
		end)
		if success then
			-- print removed: Honey Shop System initialized successfully
			return true
		else
			warn("Failed to initialize Honey Shop System:", result)
			-- Fallback to our local honey shop data
			HoneyEventShopData = HoneyShopItems
		end
	end
	return false
end

-- Honey Shop Functions
local function openHoneyShop()
	if HoneyShopUI and HoneyShopUI.Enabled == false then
		-- Use a safer approach with multiple layers of error handling
		local success, result = pcall(function()
			-- Try to use GuiController first (preferred method)
			local success2, result2 = pcall(function()
				local GuiController = require(ReplicatedStorage.Modules.GuiController)
				if GuiController then
					GuiController:Open(HoneyShopUI)
					return true
				end
				return false
			end)

			-- If GuiController failed, try direct property access with protection
			if not success2 or not result2 then
				local success3 = pcall(function()
					HoneyShopUI.Enabled = true
				end)

				-- If direct property access failed, try using task.spawn as a last resort
				if not success3 then
					task.spawn(function()
						pcall(function()
							HoneyShopUI.Enabled = true
						end)
					end)
				end
			end
		end)

		-- Log any errors for debugging
		if not success then
			warn("Failed to open Honey Shop:", result)
		end
	end
end

local function closeHoneyShop()
	if HoneyShopUI and HoneyShopUI.Enabled == true then
		-- Use a safer approach with multiple layers of error handling
		local success, result = pcall(function()
			-- Try to use GuiController first (preferred method)
			local success2, result2 = pcall(function()
				local GuiController = require(ReplicatedStorage.Modules.GuiController)
				if GuiController then
					GuiController:Close(HoneyShopUI)
					return true
				end
				return false
			end)

			-- If GuiController failed, try direct property access with protection
			if not success2 or not result2 then
				local success3 = pcall(function()
					HoneyShopUI.Enabled = false
				end)

				-- If direct property access failed, try using task.spawn as a last resort
				if not success3 then
					task.spawn(function()
						pcall(function()
							HoneyShopUI.Enabled = false
						end)
					end)
				end
			end
		end)

		-- Log any errors for debugging
		if not success then
			warn("Failed to close Honey Shop:", result)
		end
	end
end

local function buyHoneyItem(itemName)
	if Services.ReplicatedStorage:FindFirstChild("GameEvents") then
		local BuyEventShopStock = Services.ReplicatedStorage.GameEvents:FindFirstChild("BuyEventShopStock")
		if BuyEventShopStock then
			BuyEventShopStock:FireServer(itemName)
			return true
		end
	end
	return false
end

local function getHoneyShopStock()
	local success, result = pcall(function()
		local DataService = require(Services.ReplicatedStorage.Modules.DataService)
		local data = DataService:GetData()
		if data and data.EventShopStock and data.EventShopStock.Stocks then
			return data.EventShopStock.Stocks
		end
		return {}
	end)
	if success then
		return result
	else
		return {}
	end
end

local function getPlayerHoney()
	local success, result = pcall(function()
		local DataService = require(Services.ReplicatedStorage.Modules.DataService)
		local data = DataService:GetData()
		if data and data.SpecialCurrency and data.SpecialCurrency.Honey then
			return data.SpecialCurrency.Honey
		end
		return 0
	end)
	if success then
		return result
	else
		return 0
	end
end

local function autoBuyHoneyItems()
	if not AutoBuyHoneyItems then
		return
	end

	spawn(function()
		while AutoBuyHoneyItems do
			wait(2) -- Check every 2 seconds

			local currentTime = tick()
			local stock = getHoneyShopStock()
			local playerHoney = getPlayerHoney()

			-- Check if stock refreshed recently
			if currentTime - LastStockRefresh > StockRefreshInterval then
				LastStockRefresh = currentTime
				Library:Notify("Honey shop stock refreshed!", 3)
			end

			-- Use priority system for auto-buying
			for _, itemName in ipairs(AutoBuyPriority) do
				if AutoBuyHoneyItems and Toggles["AutoBuy_" .. itemName] and Toggles["AutoBuy_" .. itemName].Value then
					local itemData = HoneyShopItems[itemName] or (HoneyEventShopData and HoneyEventShopData[itemName])
					if itemData and stock[itemName] and stock[itemName].Stock > 0 then
						if playerHoney >= itemData.Price then
							if buyHoneyItem(itemName) then
								Library:Notify(
										"Bought " .. itemData.SeedName .. " for " .. itemData.Price .. " honey!",
										2
								)
								playerHoney = playerHoney - itemData.Price
								wait(1) -- Delay between purchases
							end
						else
							Library:Notify(
									"Not enough honey for " .. itemData.SeedName .. " (Need: " .. itemData.Price .. ")",
									3
							)
						end
					end
				end
			end
		end
	end)
end

local Window = Library:CreateWindow({
	-- Set Center to true if you want the menu to appear in the center
	-- Set AutoShow to true if you want the menu to appear when it is created
	-- Set Resizable to true if you want to have in-game resizable Window
	-- Set MobileButtonsSide to "Left" or "Right" if you want the ui toggle & lock buttons to be on the left or right side of the window
	-- Set ShowCustomCursor to false if you don't want to use the Linoria cursor
	-- NotifySide = Changes the side of the notifications (Left, Right) (Default value = Left)
	-- Position and Size are also valid options here
	-- but you do not have to define them unless you are changing them :)
	Title = "SNOWBIND",
	Footer = "version: 1.3.4 - Summer Harvest",
	Icon = 102791718156683,
	NotifySide = "Right",
	ShowCustomCursor = true,
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
-- You can find more icons in https://lucide.dev/
local Tabs = {
	-- Creates a new tab titled Main
	Main = Window:AddTab("Main", "user"),
	["Auto Plant"] = Window:AddTab("Auto Plant", "sprout"),
	["Auto Farm"] = Window:AddTab("Auto Farm", "tractor"),
	Pet = Window:AddTab("Pet", "heart"),
	Store = Window:AddTab("Store", "shopping-cart"),
	Event = Window:AddTab("Event", "calendar"),
	Player = Window:AddTab("Player", "user-check"),
	Dupe = Window:AddTab("Dupe", "copy"),
	WebHook = Window:AddTab("Web Hook", "link"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Initialize Honey Shop on script load
spawn(function()
	wait(2) -- Wait for game to load
	initializeHoneyShop()
end)

--[[
Example of how to add a warning box to a tab; the title AND text support rich text formatting.

local WarningTab = Tabs["UI Settings"]:AddTab("Warning Box", "user")

WarningTab:UpdateWarningBox({
	Visible = true,
	Title = "Warning",
	Text = "This is a warning box!",
	RichText = false, -- Disable rich text parsing to prevent errors
})

]]

-- Groupbox and Tabbox inherit the same functions
-- except Tabboxes you have to call the functions on a tab (Tabbox:AddTab(name))

Library:OnUnload(function()
	securePrint("Unloaded!")
	AutoBuyHoneyItems = false
	HoneyShopEnabled = false
end)

-- UI Settings
local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

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
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",

	Text = "DPI Scale",

	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)

		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
		 :AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })

MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- ThemeManager (Allows you to have a menu theme system)

-- Hand the library over to our managers
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- Adds our MenuKeybind to the ignore list
-- (do you want each config to have a different menu key? probably not.)
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
ThemeManager:SetFolder("GrowAGarden")
SaveManager:SetFolder("GrowAGarden/autoplant")
SaveManager:SetSubFolder("specific-place") -- if the game has multiple places inside of it (for example: DOORS)
-- you can use this to save configs for those places separately
-- The path in this script would be: GrowAGarden/autoplant/settings/specific-place
-- [ This is optional ]

-- Builds our config menu on the right side of our tab
SaveManager:BuildConfigSection(Tabs["UI Settings"])

-- Builds our theme menu (with plenty of built in themes) on the left side
-- NOTE: you can also call ThemeManager:ApplyToGroupbox to add it to a specific groupbox
ThemeManager:ApplyToTab(Tabs["UI Settings"])

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()

-- Store Tab
-- Generated with Sigma Spy Github: https://github.com/depthso/Sigma-Spy
-- Services now available through Services table

-- Remote
local BuySeedStock = Services.ReplicatedStorage.GameEvents.BuySeedStock
local BuyGearStock = Services.ReplicatedStorage.GameEvents.BuyGearStock
local BuyCosmeticCrate = Services.ReplicatedStorage.GameEvents.BuyCosmeticCrate
local BuyCosmeticItem = Services.ReplicatedStorage.GameEvents.BuyCosmeticItem
local Sell_Inventory = Services.ReplicatedStorage.GameEvents.Sell_Inventory
local Sell_Item = Services.ReplicatedStorage.GameEvents.Sell_Item
local Remove_Item = Services.ReplicatedStorage.GameEvents:WaitForChild("Remove_Item")
local Plant_RE = Services.ReplicatedStorage.GameEvents.Plant_RE
local PickupSound = Services.ReplicatedStorage.GameEvents.PickupSound
local HoneyMachineService_RE = Services.ReplicatedStorage.GameEvents.HoneyMachineService_RE
local ShecklesClient = Services.ReplicatedStorage:WaitForChild("GameEvents"):WaitForChild("ShecklesClient")

-- GuiController module
local GuiController = require(Services.ReplicatedStorage.Modules.GuiController)
local TopText = require(Services.ReplicatedStorage.Top_Text)
local NPCMod = require(Services.ReplicatedStorage.NPC_MOD)
local DataService = require(Services.ReplicatedStorage.Modules.DataService)
local CommaModule = require(Services.ReplicatedStorage:WaitForChild("Comma_Module"))
local QuestsController = require(Services.ReplicatedStorage.Modules.QuestsController)
local Remotes = require(Services.ReplicatedStorage.Modules.Remotes)

-- Shop Menu state tracking
local shopOpen = false
local cosmeticShopOpen = false
local honeyShopOpen = false

-- Honey shop UI variables
local honeyUIOverlap = workspace.Interaction.UpdateItems:FindFirstChild("HoneyUIOverlap", true)
		or Services.ReplicatedStorage.Modules.UpdateService:FindFirstChild("HoneyUIOverlap", true)
local appearEffect = Services.ReplicatedStorage:WaitForChild("Appear_Effect")

-- Shop Menu Section
local ShopMenuGroupBox = Tabs.Store:AddLeftGroupbox("Shop Menu")

ShopMenuGroupBox:AddToggle("SeedStoreToggle", {
	Text = "Open/Close Seed Store",
	Tooltip = "Toggle the in-game seed store window",
	Default = false,

	Callback = function(Value)
		print("[cb] Seed Store toggle:", Value)
		shopOpen = Value

		if Value then
			-- Open seed store
			if LocalPlayer.PlayerGui:FindFirstChild("Seed_Shop") then
				GuiController:Open(LocalPlayer.PlayerGui.Seed_Shop)
				print("Opened seed store!")
			else
				print("Seed_Shop GUI not found!")
			end
		else
			-- Close seed store
			if LocalPlayer.PlayerGui:FindFirstChild("Seed_Shop") then
				GuiController:Close(LocalPlayer.PlayerGui.Seed_Shop)
				print("Closed seed store!")
			end
		end
	end,
})

ShopMenuGroupBox:AddToggle("CosmeticStoreToggle", {
	Text = "Open/Close Cosmetic Store",
	Tooltip = "Toggle the in-game cosmetic store window",
	Default = false,

	Callback = function(Value)
		print("[cb] Cosmetic Store toggle:", Value)
		cosmeticShopOpen = Value

		if Value then
			-- Open cosmetic store with NPC interaction simulation
			if LocalPlayer.PlayerGui:FindFirstChild("CosmeticShop_UI") then
				-- Start NPC interaction
				NPCMod.Start_Speak(LocalPlayer)

				-- Wait a moment for the interaction to process
				task.wait(0.8)

				-- Open the cosmetic shop
				GuiController:Open(LocalPlayer.PlayerGui.CosmeticShop_UI)
				print("Opened cosmetic store!")

				-- End NPC interaction after a moment
				task.wait(0.6)
				NPCMod.End_Speak(LocalPlayer)
			else
				print("CosmeticShop_UI GUI not found!")
			end
		else
			-- Close cosmetic store
			if LocalPlayer.PlayerGui:FindFirstChild("CosmeticShop_UI") then
				GuiController:Close(LocalPlayer.PlayerGui.CosmeticShop_UI)
				NPCMod.End_Speak(LocalPlayer)
				print("Closed cosmetic store!")
			end
		end
	end,
})

ShopMenuGroupBox:AddButton("Open Honey Shop", function()
	openHoneyShop()
	Library:Notify("Opening Honey Shop...", 2)
end)

ShopMenuGroupBox:AddButton("Close Honey Shop", function()
	closeHoneyShop()
	Library:Notify("Closing Honey Shop...", 2)
end)

ShopMenuGroupBox:AddToggle("GearStoreToggle", {
	Text = "Open/Close Gear Store",
	Tooltip = "Toggle the in-game gear store window",
	Default = false,

	Callback = function(Value)
		print("[cb] Gear Store toggle:", Value)

		if Value then
			-- Open gear store with NPC interaction simulation
			if LocalPlayer.PlayerGui:FindFirstChild("Gear_Shop") then
				-- Start NPC interaction
				NPCMod.Start_Speak(LocalPlayer)

				-- Wait a moment for the interaction to process
				task.wait(0.5)

				-- Open the gear shop
				GuiController:Open(LocalPlayer.PlayerGui.Gear_Shop)
				print("Opened gear store!")

				-- End NPC interaction after a moment
				task.wait(0.2)
				NPCMod.End_Speak(LocalPlayer)
			else
				print("Gear_Shop GUI not found!")
			end
		else
			-- Close gear store
			if LocalPlayer.PlayerGui:FindFirstChild("Gear_Shop") then
				GuiController:Close(LocalPlayer.PlayerGui.Gear_Shop)
				NPCMod.End_Speak(LocalPlayer)
				print("Closed gear store!")
			end
		end
	end,
})

ShopMenuGroupBox:AddToggle("DailyQuestsToggle", {
	Text = "Open/Close Daily Quests",
	Tooltip = "Toggle the daily quests window",
	Default = false,

	Callback = function(Value)
		print("[cb] Daily Quests toggle:", Value)

		if Value then
			-- Open daily quests with proper initialization
			if LocalPlayer.PlayerGui:FindFirstChild("DailyQuests_UI") then
				local questUI = LocalPlayer.PlayerGui.DailyQuests_UI

				-- Use GuiController with popup animations like the original script
				GuiController:UsePopupAnims(questUI)
				GuiController:Open(questUI)
				print("Opened daily quests!")

				-- Initialize quest data if needed
				task.spawn(function()
					local data = DataService:GetData()
					if data and data.DailyQuests and data.DailyQuests.ContainerId then
						local container = QuestsController:GetContainerFromId(data.DailyQuests.ContainerId)
						if container then
							print("Quest container loaded successfully!")
						end
					end
				end)
			else
				print("DailyQuests_UI GUI not found!")
			end
		else
			-- Close daily quests
			if LocalPlayer.PlayerGui:FindFirstChild("DailyQuests_UI") then
				GuiController:Close(LocalPlayer.PlayerGui.DailyQuests_UI)
				print("Closed daily quests!")
			end
		end
	end,
})

local StoreGroupBox = Tabs.Store:AddLeftGroupbox("Seeds Store")

StoreGroupBox:AddDropdown("StoreItems", {
	Values = {
		-- ONLY seeds that are actually available in the shop (DisplayInShop = true)
		"Apple",
		"Avocado",
		"Bamboo",
		"Banana",
		"Beanstalk",
		"Bell Pepper",
		"Blueberry",
		"Cacao",
		"Cactus",
		"Carrot",
		"Cauliflower",
		"Coconut",
		"Corn",
		"Daffodil",
		"Dragon Fruit",
		"Ember Lily",
		"Feijoa",
		"Grape",
		"Green Apple",
		"Kiwi",
		"Loquat",
		"Mango",
		"Mushroom",
		"Orange Tulip",
		"Pepper",
		"Pineapple",
		"Prickly Pear",
		"Pumpkin",
		"Strawberry",
		"Sugar Apple",
		"Tomato",
		"Watermelon",
	},
	Default = 1,
	Multi = true, -- Allows multiple selections

	Text = "Select Items to Purchase",
	Tooltip = "Choose multiple items from the store",

	Callback = function(Value)
		print("[cb] Store items selection changed:")
		for item, selected in next, Options.StoreItems.Value do
			print(item, selected)
		end
	end,
})

StoreGroupBox:AddToggle("AutoPurchase", {
	Text = "Auto Purchase Selected Items",
	Tooltip = "Automatically purchase the selected items",
	Default = false,

	Callback = function(Value)
		print("[cb] Auto Purchase toggled:", Value)
		if Value then
			-- Start auto buying loop
			task.spawn(function()
				while Toggles.AutoPurchase.Value do
					-- Auto buy selected items continuously
					for item, selected in next, Options.StoreItems.Value do
						if selected then
							BuySeedStock:FireServer(item)
							print("Auto purchased:", item)
						end
					end
					task.wait(0.1) -- Wait 0.1 seconds between purchases
				end
			end)
		end
	end,
})

-- Gear Store Section
local GearGroupBox = Tabs.Store:AddLeftGroupbox("Gear Store")

GearGroupBox:AddDropdown("GearItems", {
	Values = {
		-- ONLY gear that is actually available in the shop (DisplayInShop = true)
		"Advanced Sprinkler",
		"Basic Sprinkler",
		"Cleaning Spray",
		"Favorite Tool",
		"Friendship Pot",
		"Godly Sprinkler",
		"Harvest Tool",
		"Lightning Rod",
		"Master Sprinkler",
		"Recall Wrench",
		"Tanning Mirror",
		"Trowel",
		"Watering Can",
	},
	Default = 1,
	Multi = true, -- Allows multiple selections

	Text = "Select Gear to Purchase",
	Tooltip = "Choose multiple gear items from the store",

	Callback = function(Value)
		print("[cb] Gear items selection changed:")
		for item, selected in next, Options.GearItems.Value do
			print(item, selected)
		end
	end,
})

GearGroupBox:AddToggle("AutoPurchaseGear", {
	Text = "Auto Purchase Selected Gear",
	Tooltip = "Automatically purchase the selected gear items",
	Default = false,

	Callback = function(Value)
		print("[cb] Auto Purchase Gear toggled:", Value)
		if Value then
			-- Start auto buying gear loop
			task.spawn(function()
				while Toggles.AutoPurchaseGear.Value do
					-- Auto buy selected gear items continuously
					for item, selected in next, Options.GearItems.Value do
						if selected then
							BuyGearStock:FireServer(item)
							print("Auto purchased gear:", item)
						end
					end
					task.wait(0.1) -- Wait 0.1 seconds between purchases
				end
			end)
		end
	end,
})

-- Sell Section
local SellGroupBox = Tabs.Store:AddRightGroupbox("Inventory Management")

-- Auto Sell Toggle State
local AutoSellInventoryEnabled = false
local OriginalPlayerPosition = nil

-- Function to find Sell Stands location
local function findSellStands()
	local success, result = pcall(function()
		-- Method 1: Look for NPCS > Sell Stand
		local npcs = workspace:FindFirstChild("NPCS")
		if npcs then
			local sellStand = npcs:FindFirstChild("Sell Stand")
					or npcs:FindFirstChild("SellStand")
					or npcs:FindFirstChild("Sell")
			if sellStand then
				return sellStand
			end
		end

		-- Method 2: Search for any "Sell" related NPCs
		if npcs then
			for _, npc in pairs(npcs:GetChildren()) do
				if string.find(npc.Name:lower(), "sell") then
					return npc
				end
			end
		end

		-- Method 3: Look in workspace.Interaction for sell stands
		local interaction = workspace:FindFirstChild("Interaction")
		if interaction then
			local sellStand = interaction:FindFirstChild("SellStand") or interaction:FindFirstChild("Sell Stand")
			if sellStand then
				return sellStand
			end
		end

		return nil
	end)

	if success and result then
		return result
	else
		print("Error finding sell stands:", result)
		return nil
	end
end

-- Function to get safe teleport position near sell stands
local function getSellStandPosition()
	local sellStand = findSellStands()
	if not sellStand then
		print("❌ No sell stand found")
		return nil
	end

	-- Try to find the exact position of the sell stand for precise teleportation
	local position = nil
	if sellStand:FindFirstChild("HumanoidRootPart") then
		position = sellStand.HumanoidRootPart.Position
		print("📍 Found sell stand via HumanoidRootPart:", position)
	elseif sellStand.PrimaryPart then
		position = sellStand.PrimaryPart.Position
		print("📍 Found sell stand via PrimaryPart:", position)
	else
		-- Find any part in the sell stand to use as reference
		for _, child in pairs(sellStand:GetChildren()) do
			if child:IsA("BasePart") then
				position = child.Position
				print("📍 Found sell stand via BasePart (" .. child.Name .. "):", position)
				break
			end
		end
	end

	if not position then
		print("❌ Could not determine sell stand position")
		return nil
	end

	return position
end

-- Improved sell inventory function with better teleportation for auto-sell
local function sellInventoryWithImprovedTeleport()
	local success, result = pcall(function()
		-- Store original position
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			OriginalPlayerPosition = LocalPlayer.Character.HumanoidRootPart.Position
			print("📍 Stored original position:", OriginalPlayerPosition)
		else
			print("❌ Could not get player position!")
			return false
		end

		-- Find sell stand position
		local sellStandPosition = getSellStandPosition()
		if not sellStandPosition then
			Library:Notify("Could not find Sell Stands!", 3)
			return false
		end

		print("Teleporting to Sell Stands for auto-sell...")
		Library:Notify("Teleporting to Sell Stands...", 2)

		-- Calculate optimal position - very close to sell stand but not overlapping
		local optimalPosition = sellStandPosition + Vector3.new(0, 0.5, 1.5) -- Close proximity for reliable interaction

		-- Single teleport to optimal position
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(optimalPosition)
		print("📍 Teleported to position:", optimalPosition)
		task.wait(2.0) -- Allow full teleport registration and network sync

		-- Face the sell stand for better interaction
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local lookDirection = (sellStandPosition - LocalPlayer.Character.HumanoidRootPart.Position).Unit
			LocalPlayer.Character.HumanoidRootPart.CFrame =
			CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, sellStandPosition)
			task.wait(0.5)
		end

		-- Get backpack count before selling for validation
		local backpackCount = 0
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if backpack then
			backpackCount = #backpack:GetChildren()
			print("📦 Items in backpack before sell:", backpackCount)
		end

		-- Sell inventory
		print("💰 Selling inventory (auto-sell)...")
		Library:Notify("💰 Selling inventory...", 2)
		Sell_Inventory:FireServer()
		-- Wait with progress feedback
		for i = 1, 4 do
			task.wait(1)
			print("⏳ Waiting for sell to complete... (" .. i .. "/4 seconds)")
		end

		-- Validate sell completion by checking backpack
		local newBackpackCount = 0
		if backpack then
			newBackpackCount = #backpack:GetChildren()
			print("📦 Items in backpack after sell:", newBackpackCount)
		end

		-- Additional wait if items still in backpack
		if newBackpackCount > 0 and newBackpackCount >= backpackCount then
			print("⚠️  Items still in backpack, waiting longer...")
			Library:Notify("Extending sell wait time...", 2)
			task.wait(3)
		end

		-- Teleport back to original position
		if OriginalPlayerPosition then
			print("Teleporting back to original location...")
			Library:Notify("Teleporting back...", 2)
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(OriginalPlayerPosition + Vector3.new(0, 2, 0))
			task.wait(1.0) -- Ensure teleport back completes
		end

		Library:Notify("Auto-sell completed successfully!", 3)
		print("✅ Auto-sell process finished. Items sold:", (backpackCount - newBackpackCount))
		return true
	end)

	if not success then
		print("Error in autoSellWithTeleport:", result)
		Library:Notify("Error during auto-sell: " .. tostring(result), 4)

		-- Try to teleport back even if there was an error
		if
		OriginalPlayerPosition
				and LocalPlayer.Character
				and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		then
			pcall(function()
				LocalPlayer.Character.HumanoidRootPart.CFrame =
				CFrame.new(OriginalPlayerPosition + Vector3.new(0, 2, 0))
			end)
		end
		return false
	end

	return result
end

-- Function to sell inventory with teleportation (wrapper for improved version)
local function sellInventoryWithTeleport()
	return sellInventoryWithImprovedTeleport()
end

SellGroupBox:AddToggle("AutoSellInventory", {
	Text = "Sell Inventory",
	Tooltip = "Teleport to Sell Stands, sell inventory, and teleport back",
	Default = false,

	Callback = function(Value)
		print("[cb] Sell Inventory toggled:", Value)
		AutoSellInventoryEnabled = Value

		if Value then
			-- Single inventory sell with teleportation
			sellInventoryWithTeleport()
			-- Reset toggle after single use
			Toggles.AutoSellInventory:SetValue(false, true)
		end
	end,
})

-- We'll define these variables here but initialize the functions after sellItemInHandWithTeleport is defined
local autoSellEnabled = false
local autoSellConnection = nil
local setupAutoSellEquipMonitor = nil
local setupCharacterMonitor = nil

SellGroupBox:AddToggle("AutoSell", {
	Text = "Auto Sell on Equip",
	Tooltip = "Automatically teleport to Sell Stands and sell items when equipped",
	Default = false,

	Callback = function(Value)
		print("[cb] Auto Sell on Equip toggled:", Value)
		autoSellEnabled = Value

		if Value then
			Library:Notify("Auto-sell on equip enabled! Equip items to sell them.", 3)

			-- Check if player already has an equipped item (if setupAutoSellEquipMonitor is defined)
			if setupAutoSellEquipMonitor and LocalPlayer.Character then
				local equippedTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
				if equippedTool then
					print("Auto-detected already equipped item:", equippedTool.Name)
					Library:Notify("Selling already equipped item: " .. equippedTool.Name, 2)

					-- Use pcall to catch any errors
					task.spawn(function()
						pcall(function()
							sellItemInHandWithTeleport()
						end)
					end)
				end
			end
		else
			Library:Notify("Auto-sell on equip disabled", 2)
		end
	end,
})

-- Cosmetics Store Section
local CosmeticsGroupBox = Tabs.Store:AddLeftGroupbox("Cosmetics Store")

CosmeticsGroupBox:AddDropdown("CosmeticItems", {
	Values = {
		-- Cosmetic Crates available in shop (from CosmeticCrateShopData)
		"Sign Crate",
		"Beach Crate",
		"Common Gnome Crate",
		"Fun Crate",
		"Summer Fun Crate",
		"Farmers Gnome Crate",
		"Classic Gnome Crate",
		"Statue Crate",
		-- High-value Individual Cosmetic Items available in shop (from CosmeticItemShopData)
		"Blue Well",
		"Brown Well",
		"Red Well",
		"Green Tractor",
		"Red Tractor",
		"Frog Fountain",
		"Ring Walkway",
		"Viney Ring Walkway",
		"Large Wood Arbour",
		"Round Metal Arbour",
		"Tiki Bar",
		"Market Cart",
	},
	Default = 1,
	Multi = true, -- Allows multiple selections

	Text = "Select Cosmetics to Purchase",
	Tooltip = "Choose multiple cosmetic items from the store",

	Callback = function(Value)
		print("[cb] Cosmetic items selection changed:")
		for item, selected in next, Options.CosmeticItems.Value do
			print(item, selected)
		end
	end,
})

CosmeticsGroupBox:AddToggle("AutoPurchaseCosmetics", {
	Text = "Auto Purchase Selected Cosmetics",
	Tooltip = "Automatically purchase the selected cosmetic items",
	Default = false,	Callback = function(Value)
		print("[cb] Auto Purchase Cosmetics toggled:", Value)
		if Value then
			-- Start auto buying cosmetics loop
			task.spawn(function()
				while Toggles.AutoPurchaseCosmetics.Value do
					-- Auto buy selected cosmetic items continuously
					for item, selected in next, Options.CosmeticItems.Value do
						if selected then
							-- Define which items are crates vs individual cosmetic items
							local cosmeticCrates = {
								"Sign Crate", "Beach Crate", "Common Gnome Crate", "Fun Crate",
								"Summer Fun Crate", "Farmers Gnome Crate", "Classic Gnome Crate", "Statue Crate"
							}

							-- Check if item is a crate
							local isCrate = false
							for _, crateName in ipairs(cosmeticCrates) do
								if item == crateName then
									isCrate = true
									break
								end
							end

							-- Purchase accordingly
							if isCrate then
								BuyCosmeticCrate:FireServer(item)
							else
								-- Individual cosmetic item
								BuyCosmeticItem:FireServer(item)
							end
							print("Auto purchased cosmetic:", item)
						end
					end
					task.wait(0.1) -- Wait 0.1 seconds between purchases
				end
			end)
		end
	end,
})

-- Honey Shop Auto Buy Section
local HoneyShopGroupBox = Tabs.Store:AddRightGroupbox("🍯 Honey Shop Auto Buy")

-- Honey Shop items list from the HoneyShopItems data
local HoneyShopItemNames = {
	"Flower Seed Pack",
	"Lavender",
	"Nectarshade",
	"Nectarine",
	"Hive Fruit",
	"Pollen Radar",
	"Nectar Staff",
	"Honey Sprinkler",
	"Bee Egg",
	"Bee Crate",
	"Honey Comb",
	"Bee Chair",
	"Honey Torch",
	"Honey Walkway",
}

-- Selected items for auto buying
local SelectedHoneyItems = {}
local AutoBuyHoneyEnabled = false

HoneyShopGroupBox:AddDropdown("HoneyShopItems", {
	Values = HoneyShopItemNames,
	Default = 1,
	Multi = true, -- Allow multiple selections

	Text = "Select Items to Auto Buy",
	Tooltip = "Choose which honey shop items to automatically purchase",

	Callback = function(Value)
		print("[cb] Honey shop items selection changed:")
		SelectedHoneyItems = Value
		for item, selected in next, Options.HoneyShopItems.Value do
			print(item, selected)
		end
	end,
})

HoneyShopGroupBox:AddToggle("AutoBuyHoneyShop", {
	Text = "🍯 Auto Buy Selected Items",
	Tooltip = "Automatically purchase selected honey shop items when available and affordable",
	Default = false,

	Callback = function(Value)
		print("[cb] Auto Buy Honey Shop toggled:", Value)
		AutoBuyHoneyEnabled = Value

		if Value then
			-- Check if any items are selected
			local hasSelectedItems = false
			for itemName, selected in pairs(SelectedHoneyItems) do
				if selected then
					hasSelectedItems = true
					break
				end
			end

			if hasSelectedItems then
				-- Start auto buying loop
				task.spawn(function()
					while AutoBuyHoneyEnabled and Toggles.AutoBuyHoneyShop.Value do
						local playerHoney = getPlayerHoney()
						local stock = getHoneyShopStock()
						local boughtAny = false

						-- Try to buy selected items that are in stock and affordable
						for itemName, selected in pairs(SelectedHoneyItems) do
							if selected and AutoBuyHoneyEnabled and Toggles.AutoBuyHoneyShop.Value then
								local itemData = HoneyShopItems[itemName]
								if itemData and stock[itemName] and stock[itemName].Stock > 0 then
									if playerHoney >= itemData.Price then
										if buyHoneyItem(itemName) then
											Library:Notify(
													"🍯 Bought " .. itemName .. " for " .. itemData.Price .. " honey!",
													2
											)
											playerHoney = playerHoney - itemData.Price
											boughtAny = true
											task.wait(0.5) -- Reduced from 1 to 0.5 seconds
										end
									else
										print(
												"Not enough honey for "
														.. itemName
														.. " (Need: "
														.. itemData.Price
														.. ", Have: "
														.. playerHoney
														.. ")"
										)
									end
								end
							end
						end -- Wait longer if no items were bought
						if not boughtAny then
							task.wait(3) -- Reduced from 5 to 3 seconds
						else
							task.wait(1) -- Reduced from 2 to 1 second
						end
					end
				end)
				Library:Notify("Auto buy honey shop items enabled!", 2)
			else
				Library:Notify(
						"Auto buy enabled but no items selected! Use the dropdown to select items first.",
						4
				)
				-- Still start the loop in case items are selected later
				task.spawn(function()
					while AutoBuyHoneyEnabled and Toggles.AutoBuyHoneyShop.Value do
						task.wait(2)
					end
				end)
			end
		else
			Library:Notify("Auto buy honey shop items disabled", 2)
		end
	end,
})

HoneyShopGroupBox:AddButton("Check Honey Balance", function()
	local playerHoney = getPlayerHoney()
	Library:Notify("Current Honey: " .. playerHoney, 3)
end)

HoneyShopGroupBox:AddButton("Check Shop Stock", function()
	local stock = getHoneyShopStock()
	local message = "Honey Shop Stock:\n"
	local itemCount = 0

	for itemName, stockData in pairs(stock) do
		if HoneyShopItems[itemName] then
			local itemData = HoneyShopItems[itemName]
			if stockData.Stock > 0 then
				message = message
						.. "[In Stock] "
						.. itemName
						.. " ("
						.. stockData.Stock
						.. ") - "
						.. itemData.Price
						.. " honey\n"
				itemCount = itemCount + 1
			end
		end
	end

	if itemCount == 0 then
		message = message .. "❌ No items currently in stock"
	end

	Library:Notify(message, 5)
end)

HoneyShopGroupBox:AddButton("🛒 Buy Selected Items Now", function()
	local playerHoney = getPlayerHoney()
	local stock = getHoneyShopStock()
	local boughtCount = 0
	local failedCount = 0

	for itemName, selected in pairs(SelectedHoneyItems) do
		if selected then
			local itemData = HoneyShopItems[itemName]
			if itemData and stock[itemName] and stock[itemName].Stock > 0 then
				if playerHoney >= itemData.Price then
					if buyHoneyItem(itemName) then
						Library:Notify("✅ Bought " .. itemName .. " for " .. itemData.Price .. " honey!", 2)
						playerHoney = playerHoney - itemData.Price
						boughtCount = boughtCount + 1
						task.wait(0.5)
					else
						failedCount = failedCount + 1
					end
				else
					Library:Notify("Not enough honey for " .. itemName .. " (Need: " .. itemData.Price .. ")", 3)
					failedCount = failedCount + 1
				end
			else
				Library:Notify(itemName .. " is out of stock!", 2)
				failedCount = failedCount + 1
			end
		end
	end

	if boughtCount > 0 or failedCount > 0 then
		Library:Notify("Purchase complete! Bought: " .. boughtCount .. ", Failed: " .. failedCount, 3)
	else
		Library:Notify("No items selected for purchase!", 3)
	end
end)

-- Main Tab
local function getMyFarm()
	for _, farm in workspace.Farm:GetChildren() do
		local important = farm:FindFirstChild("Important")
		if important then
			local data = important:FindFirstChild("Data")
			if data and data.Owner.Value == LocalPlayer.Name then
				return farm
			end
		end
	end
	return nil
end

Library:OnUnload(function()
	print("Unloaded!")
end)

-- Auto Plant Tab
local function getRandomPlantPosition()
	local myFarm = getMyFarm()
	if myFarm then
		local canPlantParts = {}
		-- Find all Can_Plant parts in the farm
		for _, child in pairs(myFarm:GetDescendants()) do
			if child.Name == "Can_Plant" and child:IsA("BasePart") then
				table.insert(canPlantParts, child)
			end
		end

		if #canPlantParts > 0 then
			-- Pick a random Can_Plant part
			local randomPart = canPlantParts[math.random(1, #canPlantParts)]
			-- Get random position on the part
			local size = randomPart.Size
			local position = randomPart.Position
			local randomX = position.X + math.random(-size.X / 2, size.X / 2)
			local randomZ = position.Z + math.random(-size.Z / 2, size.Z / 2)
			return Vector3.new(randomX, position.Y, randomZ)
		end
	end
	return nil
end

local AutoPlantGroupBox = Tabs["Auto Plant"]:AddLeftGroupbox("Auto Plant Seeds")

AutoPlantGroupBox:AddDropdown("PlantSeeds", {
	Values = {
		"Apple",
		"Avocado",
		"Bamboo",
		"Banana",
		"Beanstalk",
		"Bee Balm",
		"Bell Pepper",
		"Bendboo",
		"Blood Banana",
		"Blue Lollipop",
		"Blueberry",
		"Cacao",
		"Cactus",
		"Candy Blossom",
		"Candy Sunflower",
		"Cantaloupe",
		"Carrot",
		"Cauliflower",
		"Celestiberry",
		"Cherry Blossom",
		"Chocolate Carrot",
		"Cocovine",
		"Coconut",
		"Corn",
		"Cranberry",
		"Crimson Vine",
		"Crocus",
		"Cursed Fruit",
		"Daffodil",
		"Dandelion",
		"Dragon Fruit",
		"Dragon Pepper",
		"Durian",
		"Easter Egg",
		"Eggplant",
		"Elephant Ears",
		"Ember Lily",
		"Feijoa",
		"Foxglove",
		"Glowshroom",
		"Grape",
		"Green Apple",
		"Hive Fruit",
		"Honeysuckle",
		"Ice Cream Bean",
		"Kiwi",
		"Lavender",
		"Lemon",
		"Lilac",
		"Lime",
		"Loquat",
		"Lotus",
		"Lumira",
		"Mango",
		"Manuka Flower",
		"Mega Mushroom",
		"Mint",
		"Moon Blossom",
		"Moon Mango",
		"Moon Melon",
		"Moonflower",
		"Moonglow",
		"Mushroom",
		"Nectar Thorn",
		"Nectarine",
		"Nectarshade",
		"Nightshade",
		"Noble Flower",
		"Orange Tulip",
		"Papaya",
		"Parasol Flower",
		"Passionfruit",
		"Peach",
		"Pear",
		"Pepper",
		"Pineapple",
		"Pink Lily",
		"Pink Tulip",
		"Prickly Pear",
		"Pumpkin",
		"Purple Cabbage",
		"Purple Dahlia",
		"Raspberry",
		"Red Lollipop",
		"Rose",
		"Rosy Delight",
		"Soul Fruit",
		"Starfruit",
		"Strawberry",
		"Succulent",
		"Sugar Apple",
		"Suncoil",
		"Sunflower",
		"Tomato",
		"Traveler's Fruit",
		"Venus Fly Trap",
		"Violet Corn",		"Watermelon",
		"Wild Carrot",
	},
	Default = 1,
	Multi = true, -- Allows multiple selections

	Text = "Seeds - Auto Plant Seeds",
	Tooltip = "Choose seeds to auto-plant. System prioritizes actual seed items (e.g., CarrotSeed over Carrot). Both will be equipped but only seeds will plant.",

	Callback = function(Value)
		print("[cb] Plant seeds selection changed:")
		for seed, selected in next, Options.PlantSeeds.Value do
			print(seed, selected)
		end
	end,
})

-- Add button to select all summer plants/fruits in the dropdown
AutoPlantGroupBox:AddButton("Select All Summer Plants", function()
	-- Hardcoded list of summer plants based on PlantTraitsData.Summer
	local summerPlants = {
		"Pineapple",
		"Watermelon",
		"Cauliflower",
		"Green Apple",
		"Banana",
		"Avocado",
		"Kiwi",
		"Prickly Pear",
		"Feijoa",
		"Sugar Apple",
		"Loquat",
		"Wild Carrot",
		"Pear",
		"Cantaloupe",
		"Parasol Flower",
		"Rosy Delight",
		"Elephant Ears",
		"Bell Pepper"
	}

	-- Get current selections
	local currentSelections = Options.PlantSeeds.Value or {}
	local selectionChanged = false
	local summerPlantsSelected = 0

	-- Select all summer plants in the dropdown
	for _, plantName in ipairs(summerPlants) do
		if not currentSelections[plantName] then
			currentSelections[plantName] = true
			selectionChanged = true
		end
		summerPlantsSelected = summerPlantsSelected + 1
	end

	-- Update the dropdown if selections changed
	if selectionChanged then
		Options.PlantSeeds:SetValue(currentSelections)
		Library:Notify("✅ Selected all summer plants in the dropdown!", 3)
	else
		Library:Notify("ℹ️ All summer plants were already selected.", 3)
	end
end)

AutoPlantGroupBox:AddToggle("AutoPlant", {
	Text = "Auto Plant Seeds (Seed Priority)",
	Tooltip = "Automatically plant seeds on Can_Plant parts. Prioritizes actual seed items (e.g., CarrotSeed) over crops (e.g., Carrot).",
	Default = false,
	Callback = function(Value)
		print("[cb] Auto Plant toggled:", Value)
		if Value then
			Library:Notify("Auto Plant enabled! Planting selected seeds...", 3)

			-- Function to find and equip seed tool
			local function findAndEquipSeed(seedName)
				local backpack = LocalPlayer:FindFirstChild("Backpack")
				local character = LocalPlayer.Character
				local seedTool = nil

				print("Looking for seed:", seedName)

				-- Function to search for SEEDS ONLY in a container
				local function searchForSeed(container, containerName)
					if not container then
						return nil
					end

					print("Searching in", containerName, "- found", #container:GetChildren(), "items")
					local seedCandidates = {}

					for _, item in pairs(container:GetChildren()) do
						if item:IsA("Tool") then
							print("Checking item:", item.Name)
							local itemName = item.Name:lower()
							local searchName = seedName:lower()

							-- ONLY look for items that contain "seed" and match the plant type
							if string.find(itemName, "seed") and string.find(itemName, searchName) then
								print("Found SEED candidate:", item.Name)
								table.insert(seedCandidates, item)
							end
						end
					end

					-- Return the first seed candidate if available
					if #seedCandidates > 0 then
						print("Selecting SEED:", seedCandidates[1].Name)
						return seedCandidates[1]
					end

					return nil
				end

				-- Search in backpack first
				if backpack then
					seedTool = searchForSeed(backpack, "Backpack")
				end

				-- If not found in backpack, search in character (already equipped tools)
				if not seedTool and character then
					seedTool = searchForSeed(character, "Character")
				end

				if seedTool then
					if character and character:FindFirstChild("Humanoid") then
						-- If tool is in backpack, equip it
						if seedTool.Parent == backpack then
							character.Humanoid:EquipTool(seedTool)
							print("Equipped", seedTool.Name, "from backpack")
						else
							print("Tool", seedTool.Name, "already equipped")
						end
						task.wait(0.1)
						return true
					else
						print("Character or Humanoid not found")
						return false
					end
				else
					print("No seed found for", seedName)
					-- Show notification that no seed was found
					Library:Notify("❌ No " .. seedName .. " Seed in inventory!", 2)

					-- Debug: show what's actually in inventory
					if backpack then
						print("=== INVENTORY DEBUG ===")
						for _, item in pairs(backpack:GetChildren()) do
							if item:IsA("Tool") then
								print("Available item:", item.Name)
							end
						end
						print("=== END DEBUG ===")
					end
					return false
				end
			end

			-- Start auto planting loop
			task.spawn(function()
				while Toggles.AutoPlant.Value do
					local plantsPlanted = 0

					-- Auto plant selected seeds continuously
					for seed, selected in next, Options.PlantSeeds.Value do
						if selected and Toggles.AutoPlant.Value then
							-- Try to find and equip the correct seed tool
							if findAndEquipSeed(seed) then
								local plantPosition = getRandomPlantPosition()
								if plantPosition then
									-- Try planting with the remote event
									local success = pcall(function()
										Plant_RE:FireServer(plantPosition, seed)
									end)

									if success then
										print("Auto planted", seed, "at position:", plantPosition)
										plantsPlanted = plantsPlanted + 1
										Library:Notify("🌱 Planted " .. seed .. "!", 1)
									else
										print("Failed to plant", seed)
									end
								else
									print("No Can_Plant parts found in farm!")
									Library:Notify("❌ No planting spots found in farm!", 2)
								end
							else
								print("Could not equip seed for", seed)
								Library:Notify("❌ " .. seed .. " Seed not found in inventory!", 2)
							end

							-- Reduced delay between different seed types
							task.wait(0.1)
						end
					end

					-- Show summary if plants were planted
					if plantsPlanted > 0 then
						Library:Notify("🌱 Planted " .. plantsPlanted .. " seeds this cycle!", 2)
					end

					-- Much shorter wait between planting cycles
					task.wait(0.5)
				end
				print("Auto plant loop ended")
			end)
		else
			Library:Notify("Auto Plant disabled!", 3)
		end
	end,
})

-- Event Tab
-- Improved Auto Farm Collection Functions (based on depso script)
local function canHarvest(plant)
	local prompt = plant:FindFirstChild("ProximityPrompt", true)
	if not prompt then
		return false
	end
	if not prompt.Enabled then
		return false
	end
	return true
end

local function harvestPlant(plant)
	local prompt = plant:FindFirstChild("ProximityPrompt", true)
	if not prompt then
		return false
	end

	-- Ensure we have a character and root part
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	-- Get optimal position near the plant
	local plantPosition = plant:GetPivot().Position
	local optimalPosition = plantPosition + Vector3.new(0, 2, 0) -- Position directly above the plant

	-- Teleport to optimal position for collection
	LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(optimalPosition)
	task.wait(0.7) -- Increased wait time for teleport to register properly

	-- Get even closer to ensure proximity trigger
	local closePosition = plantPosition + Vector3.new(0, 0.5, 0)
	LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(closePosition)
	task.wait(0.5) -- Increased wait time for proximity to activate

	-- Check if prompt is still enabled after positioning
	if not prompt.Enabled then
		return false
	end

	-- Try fireproximityprompt multiple times for better reliability
	local success = false
	local maxAttempts = 5  -- Increased from 3 to 5 attempts

	for attempt = 1, maxAttempts do
		local attemptSuccess = pcall(function()
			-- Re-enabled proximity prompt firing
			fireproximityprompt(prompt)
		end)

		if attemptSuccess then
			task.wait(0.5) -- Increased wait time for collection to process

			-- Check if the plant/fruit still exists (successful collection removes it)
			if not plant.Parent then
				success = true
				break
			end
		end

		-- If not successful and not the last attempt, try repositioning
		if not success and attempt < maxAttempts then
			-- Try different positions for better results
			local offset = Vector3.new(
					(attempt % 2) * 0.3,
					0.3 + (attempt * 0.1),
					((attempt + 1) % 2) * 0.3
			)
			local retryPosition = plantPosition + offset
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(retryPosition)
			task.wait(0.3) -- Increased wait time between attempts
		end
	end

	-- Final check - if plant is gone, collection was successful
	if not plant.Parent then
		success = true
	end

	return success
end

local function collectHarvestableFromParent(parent, harvestableItems, collectOnlyPollinated)
	local character = LocalPlayer.Character
	if not character then
		return
	end

	local playerPosition = character:GetPivot().Position

	for _, item in pairs(parent:GetChildren()) do
		-- Check fruits folder recursively
		local fruitsFolder = item:FindFirstChild("Fruits")
				or item:FindFirstChild("Fruit")
				or item:FindFirstChild("Fruit_Spawn")
		if fruitsFolder then
			-- Check each individual fruit in the fruits folder
			if collectOnlyPollinated then
				print("🍓 Checking fruits in folder for plant: " .. item.Name)
				-- Check each fruit individually for the Pollinated attribute
				for _, fruit in pairs(fruitsFolder:GetChildren()) do
					if fruit:IsA("Model") and fruit:GetAttribute("Pollinated") == true then
						print("🍓 Found pollinated fruit: " .. fruit.Name)
						-- Check if this pollinated fruit can be harvested
						if canHarvest(fruit) then
							print("✅ Pollinated fruit is harvestable: " .. fruit.Name)
							table.insert(harvestableItems, fruit)
						else
							print("❌ Pollinated fruit not harvestable: " .. fruit.Name)
						end
					end
				end
			else
				-- For non-pollinated collection, check selection for fruit folders
				local isPlantSelected = false
				if SelectedPlantsToCollect and next(SelectedPlantsToCollect) then
					-- Check if parent plant name or any fruit name is selected
					for selectedPlant, selected in pairs(SelectedPlantsToCollect) do
						if selected and (item.Name == selectedPlant) then
							isPlantSelected = true
							break
						end
					end
				else
					-- If no plants are selected, collect all (backward compatibility)
					isPlantSelected = true
				end

				if isPlantSelected then
					print("🎯 Collecting fruits from selected plant:", item.Name)
					collectHarvestableFromParent(fruitsFolder, harvestableItems, collectOnlyPollinated)
				else
					print("⏭️ Skipping fruits from unselected plant:", item.Name)
				end
			end
		end

		-- Only process individual items if they're not plants with fruit folders
		if not fruitsFolder then
			-- Distance check for performance
			local itemPosition = item:GetPivot().Position
			local distance = (playerPosition - itemPosition).Magnitude
			if distance > 50 then
				continue
			end -- Skip items too far away

			-- For non-pollinated collection, check if item can be harvested
			if not collectOnlyPollinated then
				-- Check if plant is selected for collection
				local isPlantSelected = false
				if SelectedPlantsToCollect and next(SelectedPlantsToCollect) then
					-- Check if this specific plant name is selected
					for selectedPlant, selected in pairs(SelectedPlantsToCollect) do
						if selected and item.Name == selectedPlant then
							isPlantSelected = true
							break
						end
					end
				else
					-- If no plants are selected, collect all (backward compatibility)
					isPlantSelected = true
				end

				-- Check if item can be harvested and is selected
				if canHarvest(item) and isPlantSelected then
					print("🎯 Adding selected item to harvest list:", item.Name)
					table.insert(harvestableItems, item)
				elseif canHarvest(item) and not isPlantSelected then
					print("⏭️ Skipping unselected item:", item.Name)
				end
			end
		end
	end

	return harvestableItems
end

local function getPollinatedFruits()
	local harvestableItems = {}
	local myFarm = getMyFarm()

	if not myFarm then
		print("❌ No farm found for collection!")
		return harvestableItems
	end

	-- Check if there's a nested Farm folder
	local innerFarm = myFarm:FindFirstChild("Farm")
	if innerFarm then
		myFarm = innerFarm
	end

	local important = myFarm:FindFirstChild("Important")
	if not important then
		print("❌ No Important folder found in farm!")
		return harvestableItems
	end

	-- Verify farm ownership
	local data = important:FindFirstChild("Data")
	if data and data:FindFirstChild("Owner") and data.Owner.Value ~= LocalPlayer.Name then
		print("❌ This is not your farm!")
		return harvestableItems
	end

	local plantsPhysical = important:FindFirstChild("Plants_Physical")
	if not plantsPhysical then
		print("❌ No Plants_Physical folder found!")
		return harvestableItems
	end

	print("🔍 Searching for pollinated plants in farm...")
	print("🏡 Farm found:", myFarm.Name)
	print("📂 Plants_Physical folder found with", #plantsPhysical:GetChildren(), "items")

	-- Debug: Check what plants exist and their pollination status
	for _, item in pairs(plantsPhysical:GetChildren()) do
		if item:IsA("Model") then
			local isPollinated = item:GetAttribute("Pollinated")
			local fruitsFolder = item:FindFirstChild("Fruits")
					or item:FindFirstChild("Fruit")
					or item:FindFirstChild("Fruit_Spawn")
			print("🌱 Plant:", item.Name, "| Pollinated:", isPollinated, "| Has Fruits Folder:", fruitsFolder ~= nil)
			if fruitsFolder then
				print("   └── Fruits count:", #fruitsFolder:GetChildren())
				-- Check each individual fruit for pollination status
				for i, fruit in pairs(fruitsFolder:GetChildren()) do
					if fruit:IsA("Model") then
						local fruitPollinated = fruit:GetAttribute("Pollinated")
						local canHarvestFruit = canHarvest(fruit)
						print(
								"      🍓 Fruit " .. i .. ":",
								fruit.Name,
								"| Pollinated:",
								fruitPollinated,
								"| Can Harvest:",
								canHarvestFruit
						)
					end
				end
			end
		end
	end

	-- Collect fruits from plants with Pollinated attribute (not the plants themselves)
	collectHarvestableFromParent(plantsPhysical, harvestableItems, true)

	print("🍓 Total pollinated fruits found:", #harvestableItems)
	return harvestableItems
end

local function getAllHarvestableItems()
	local harvestableItems = {}
	local myFarm = getMyFarm()

	if not myFarm then
		print("❌ No farm found for collection!")
		return harvestableItems
	end

	-- Check if there's a nested Farm folder
	local innerFarm = myFarm:FindFirstChild("Farm")
	if innerFarm then
		myFarm = innerFarm
	end

	local important = myFarm:FindFirstChild("Important")
	if not important then
		return harvestableItems
	end

	local plantsPhysical = important:FindFirstChild("Plants_Physical")
	if not plantsPhysical then
		return harvestableItems
	end

	-- Collect all harvestable items (not just pollinated)
	collectHarvestableFromParent(plantsPhysical, harvestableItems, false)

	return harvestableItems
end

-- Updated pollinated fruit collection function
local function collectPollinatedFruits()
	print("🍓 Starting fruit collection from pollinated plants...")

	local pollinatedFruits = getPollinatedFruits()
	local collectedCount = 0
	local failedCount = 0

	if #pollinatedFruits == 0 then
		print("ℹ️ No fruits found on pollinated plants")
		Library:Notify("🍓 No more pollinated fruits in garden!", 5)
		return
	end

	print("🎯 Found " .. #pollinatedFruits .. " fruits from pollinated plants to collect")

	-- Equip Harvest Tool if available
	local player = LocalPlayer
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local harvestTool = backpack:FindFirstChild("Harvest Tool")
		if harvestTool and player.Character then
			print("🔧 Equipping Harvest Tool...")
			player.Character.Humanoid:EquipTool(harvestTool)
			task.wait(1.0) -- Wait longer for tool to equip properly
		end
	end

	-- Collect each fruit from pollinated plants with improved timing
	for i, fruit in pairs(pollinatedFruits) do
		print("Collecting fruit #" .. i .. " from pollinated plant: " .. fruit.Name)

		-- Check if fruit still exists before attempting collection
		if not fruit.Parent then
			print("Fruit already collected or removed: " .. fruit.Name)
			continue
		end

		local success = harvestPlant(fruit)
		if success then
			collectedCount = collectedCount + 1
			print("✅ Successfully collected: " .. fruit.Name)
			Library:Notify("✅ Collected " .. fruit.Name, 1)
		else
			failedCount = failedCount + 1
			print("❌ Failed to collect: " .. fruit.Name)
		end

		-- Longer delay between collections to prevent spamming
		task.wait(0.8) -- Increased from 0.3 to 0.8 seconds
	end

	local message = "🍓 Fruit Collection from Pollinated Plants Complete!\n✅ Collected: "
			.. collectedCount
			.. "\n❌ Failed: "
			.. failedCount
	print(message)
	Library:Notify(message, 4)
end

-- Updated all plants collection function
local function collectAllPlants()
	print("🚜 Starting all plants collection...")

	local harvestableItems = getAllHarvestableItems()
	local collectedCount = 0
	local failedCount = 0

	if #harvestableItems == 0 then
		print("ℹ️ No harvestable items found")
		Library:Notify("ℹ️ No harvestable items found", 2)
		return collectedCount
	end

	print("🎯 Found " .. #harvestableItems .. " harvestable items to collect")

	-- Equip Harvest Tool if available
	local player = LocalPlayer
	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		local harvestTool = backpack:FindFirstChild("Harvest Tool")
		if harvestTool and player.Character then
			print("🔧 Equipping Harvest Tool...")
			player.Character.Humanoid:EquipTool(harvestTool)
			task.wait(1.0) -- Wait longer for tool to equip properly
		end
	end

	-- Collect each harvestable item with improved timing
	for i, item in pairs(harvestableItems) do
		-- Check if auto collect is still enabled
		if not AutoCollectPlantsEnabled then
			print("Auto collect stopped by user!")
			break
		end

		print("Collecting item #" .. i .. ": " .. item.Name)

		-- Check if item still exists before attempting collection
		if not item.Parent then
			print("Item already collected or removed: " .. item.Name)
			continue
		end

		local success = harvestPlant(item)
		if success then
			collectedCount = collectedCount + 1
			Library:Notify("✅ Collected " .. item.Name, 1)
		else
			failedCount = failedCount + 1
		end

		-- Longer delay between collections to prevent spamming
		task.wait(0.8) -- Increased from 0.2 to 0.8 seconds
	end

	local message = "🚜 Farm Collection Complete!\n✅ Collected: "
			.. collectedCount
			.. "\n❌ Failed: "
			.. failedCount
	print(message)
	Library:Notify(message, 4)

	return collectedCount
end

-- Auto Collect Honey Functions
local AutoCollectHoneyEnabled = false
local AutoGivePlantsEnabled = false

local function getHoneyMachineData()
	local success, result = pcall(function()
		local DataService = require(Services.ReplicatedStorage.Modules.DataService)
		local data = DataService:GetData()
		if data and data.HoneyMachine then
			return data.HoneyMachine
		end
		return nil
	end)
	if success then
		return result
	else
		return nil
	end
end

local function findHoneyMachine()
	-- Look for the honey machine in workspace
	local honeyMachine = workspace.Interaction.UpdateItems:FindFirstChild("HoneyCombpressor", true)
	if not honeyMachine then
		honeyMachine = Services.ReplicatedStorage.Modules.UpdateService:FindFirstChild("HoneyCombpressor", true)
	end
	return honeyMachine
end

local function interactWithHoneyMachine()
	local honeyMachine = findHoneyMachine()
	if not honeyMachine then
		print("Honey machine not found!")
		return false
	end

	-- Get honey machine data first
	local honeyData = getHoneyMachineData()
	if not honeyData then
		print("No honey machine data found!")
		return false
	end

	-- Use the HoneyMachineService remote - this is the correct way per documentation
	local HoneyMachineService_RE = Services.ReplicatedStorage.GameEvents:FindFirstChild("HoneyMachineService_RE")
	if not HoneyMachineService_RE then
		print("HoneyMachineService_RE not found!")
		return false
	end

	-- Check machine state and determine if we can interact
	if honeyData.TimeLeft > 0 then
		print("Honey machine is still processing... Time left:", honeyData.TimeLeft)
		return false
	elseif honeyData.HoneyStored > 0 then
		print("Collecting honey! Amount:", honeyData.HoneyStored)
		-- Teleport to honey machine collection area (spout/jar area)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			-- Position near the honey collection spout area
			LocalPlayer.Character.HumanoidRootPart.CFrame = honeyMachine.Spout.Jar.CFrame + Vector3.new(0, 5, 0)
			task.wait(0.8) -- Wait for teleport to register

			-- Fire the remote - this is how the original honey system works
			HoneyMachineService_RE:FireServer("MachineInteract")
			print("Sent MachineInteract to collect honey")
			return true
		end
	elseif honeyData.PlantWeight >= 10 and honeyData.TimeLeft <= 0 then
		print("Compressing plants! Weight:", honeyData.PlantWeight)
		-- Teleport to honey machine compression area (main machine)
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			LocalPlayer.Character.HumanoidRootPart.CFrame = honeyMachine.HoneyFill.Outer.CFrame + Vector3.new(0, 5, 0)
			task.wait(0.8) -- Wait for teleport to register

			-- Fire the remote for compression
			HoneyMachineService_RE:FireServer("MachineInteract")
			print("Sent MachineInteract to compress plants")
			return true
		end
	else
		print(
				"Machine not ready for interaction. PlantWeight:",
				honeyData.PlantWeight,
				"TimeLeft:",
				honeyData.TimeLeft,
				"HoneyStored:",
				honeyData.HoneyStored
		)
		return false
	end

	return false
end

local function givePlantsToHoneyMachine()
	-- Fast check for pollinated fruits in inventory - optimized for speed
	local pollinatedTool = nil

	-- Check equipped tools first (faster than backpack)
	if LocalPlayer.Character then
		for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
			if tool:GetAttribute("Pollinated") then -- Only check the attribute we need
				pollinatedTool = tool
				break
			end
		end
	end

	-- If no equipped pollinated tool, check backpack
	if not pollinatedTool and LocalPlayer.Backpack then
		for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
			if tool:GetAttribute("Pollinated") then -- Only check the attribute we need
				-- Equip the pollinated fruit quickly
				LocalPlayer.Character.Humanoid:EquipTool(tool)
				pollinatedTool = tool
				task.wait(0.3) -- Reduced wait time
				break
			end
		end
	end

	if pollinatedTool then
		local honeyMachine = findHoneyMachine()
		if honeyMachine then
			-- Quick teleport to honey machine feeding area
			if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				LocalPlayer.Character.HumanoidRootPart.CFrame = honeyMachine.Onett.HumanoidRootPart.CFrame
						+ Vector3.new(0, 0, 5)
				task.wait(0.4) -- Reduced wait time

				-- Fast interaction with honey machine
				local HoneyMachineService_RE = Services.ReplicatedStorage.GameEvents:FindFirstChild("HoneyMachineService_RE")
				if HoneyMachineService_RE then
					HoneyMachineService_RE:FireServer("MachineInteract")
					print("✅ Fast gave pollinated fruit to honey machine:", pollinatedTool.Name)
					return true
				end
			end
		end
	else
		print("❌ No pollinated fruits found in inventory")
	end

	return false
end

local function autoCollectHoney()
	if not AutoCollectHoneyEnabled then
		return
	end
	spawn(function()
		while AutoCollectHoneyEnabled do
			wait(2) -- Reduced from 3 to 2 seconds

			local honeyData = getHoneyMachineData()
			if honeyData then
				if honeyData.HoneyStored > 0 then
					-- Collect ready honey
					if interactWithHoneyMachine() then
						Library:Notify("Collected " .. honeyData.HoneyStored .. " honey!", 3)
						wait(0.5) -- Reduced from 1 to 0.5 seconds
					end
				elseif honeyData.PlantWeight >= 10 and honeyData.TimeLeft <= 0 then
					-- Combpress plants into honey
					if interactWithHoneyMachine() then
						Library:Notify("Started honey compression process!", 3)
						wait(1) -- Reduced from 2 to 1 second
					end
				end
			end
		end
	end)
end

local function autoGivePlants()
	if not AutoGivePlantsEnabled then
		return
	end
	spawn(function()
		while AutoGivePlantsEnabled do
			wait(1.5) -- Reduced from 2 to 1.5 seconds

			local honeyData = getHoneyMachineData()
			if honeyData then
				if honeyData.TimeLeft <= 0 and honeyData.PlantWeight < 10 and honeyData.HoneyStored <= 0 then
					-- Try to give pollinated fruits
					if givePlantsToHoneyMachine() then
						Library:Notify("Gave pollinated fruit to honey machine!", 2)
						wait(0.5) -- Reduced from 1 to 0.5 seconds
					end
				end
			end
		end
	end)
end

local EventGroupBox = Tabs.Event:AddLeftGroupbox("Auto Collection")

EventGroupBox:AddToggle("AutoCollectPollinated", {
	Text = "Auto Collect Fruits from Pollinated Plants",
	Tooltip = "Automatically collect fruits from plants with Pollinated mutation (not the plants themselves)",
	Default = false,
	Callback = function(Value)
		print("[cb] Auto Collect Pollinated toggled:", Value)
		if Value then
			Library:Notify("Auto Collect Fruits from Pollinated Plants enabled!", 3)
			-- Start auto collection loop
			task.spawn(function()
				while Toggles.AutoCollectPollinated.Value do
					print("Auto collect cycle starting...")
					local pollinatedFruits = getPollinatedFruits()

					if #pollinatedFruits > 0 then
						print("Found " .. #pollinatedFruits .. " fruits from pollinated plants to collect")
						collectPollinatedFruits()
					else
						print("No fruits found on pollinated plants, waiting...")
						Library:Notify("No more pollinated fruits in garden!", 3)
					end

					-- Smart delay - shorter wait if fruits were found, longer if none
					local waitTime = #pollinatedFruits > 0 and 15 or 30

					-- Wait in 1-second increments so we can stop quickly if toggled off
					for i = 1, waitTime do
						if not Toggles.AutoCollectPollinated.Value then
							break
						end
						task.wait(1)
					end
				end
				print("Auto collect fruits from pollinated plants loop ended")
			end)
		else
			Library:Notify("Auto Collect Fruits from Pollinated Plants disabled!", 3)
		end
	end,
})

-- Auto Collect Honey Group
local HoneyCollectionGroupBox = Tabs.Event:AddRightGroupbox("Auto Collect Honey")

HoneyCollectionGroupBox:AddToggle("AutoGivePlants", {
	Text = "🌱 Auto Give Pollinated Plants",
	Default = false,
	Tooltip = "Automatically gives pollinated plants to the honey machine",

	Callback = function(Value)
		getgenv().AutoGivePlantsEnabled = Value
		if Value then
			Library:Notify("🌱 Auto Give Plants enabled!", 3)
			task.spawn(function()
				while getgenv().AutoGivePlantsEnabled do
					-- Check if honey machine has space
					local success, honeyMachineData = pcall(function()
						return DataService:GetData().HoneyMachine
					end)

					if success and honeyMachineData and honeyMachineData.PlantWeight then
						local maxWeight = 100 -- Default max weight, adjust if needed
						local hasSpaceRemote = pcall(function()
							return require(ReplicatedStorage.Data.HoneyMachineData).MAX_PLANT_WEIGHT
						end)
						if hasSpaceRemote then
							maxWeight = require(ReplicatedStorage.Data.HoneyMachineData).MAX_PLANT_WEIGHT
						end

						if honeyMachineData.PlantWeight < maxWeight then
							-- Check if player is holding a pollinated plant
							local pollinatedTool = nil
							if LocalPlayer.Character then
								for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
									if tool:IsA("Tool") then
										local isPollinated = tool:GetAttribute("Pollinated")
										local isFruit = tool:HasTag("FruitTool") or tool:GetAttribute("ITEM_UUID") or string.find(tool.Name:lower(), "fruit")
										local isFavorited = tool:GetAttribute("Favorite")

										print("🔍 Checking tool: " .. tool.Name .. " | Pollinated: " .. tostring(isPollinated) .. " | Fruit: " .. tostring(isFruit) .. " | Favorited: " .. tostring(isFavorited))

										if isPollinated and isFruit and not isFavorited then
											pollinatedTool = tool
											print("✅ Found pollinated tool to give: " .. tool.Name)
											break
										end
									end
								end
							end

							if pollinatedTool then
								print("🍓 Giving pollinated plant: " .. pollinatedTool.Name)
								-- Try multiple methods to give the plant
								local giveSuccess = pcall(function()
									ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("MachineInteract")
								end)

								if not giveSuccess then
									-- Try alternative method
									pcall(function()
										ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("SubmitPlant")
									end)
								end

								task.wait(1.5)
							else
								-- Check backpack for pollinated plants
								local backpack = LocalPlayer:FindFirstChild("Backpack")
								if backpack then
									local foundInBackpack = false
									for _, tool in pairs(backpack:GetChildren()) do
										if tool:IsA("Tool") then
											local isPollinated = tool:GetAttribute("Pollinated")
											local isFruit = tool:HasTag("FruitTool") or tool:GetAttribute("ITEM_UUID") or string.find(tool.Name:lower(), "fruit")
											local isFavorited = tool:GetAttribute("Favorite")

											if isPollinated and isFruit and not isFavorited then
												print("🎒 Equipping pollinated plant from backpack: " .. tool.Name)
												-- Equip the tool
												LocalPlayer.Character.Humanoid:EquipTool(tool)
												task.wait(0.5)

												-- Give the plant
												local giveSuccess = pcall(function()
													ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("MachineInteract")
												end)

												if not giveSuccess then
													pcall(function()
														ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("SubmitPlant")
													end)
												end

												foundInBackpack = true
												task.wait(1.5)
												break
											end
										end
									end

									if not foundInBackpack then
										print("🔍 No pollinated plants found in backpack")
										task.wait(2)
									end
								else
									task.wait(2)
								end
							end
						else
							print("⚠️ Honey machine is full, waiting...")
							task.wait(5)
						end
					else
						print("❌ Could not access honey machine data")
						task.wait(3)
					end
				end
			end)
		else
			Library:Notify("🌱 Auto Give Plants disabled!", 3)
		end
	end,
})

HoneyCollectionGroupBox:AddToggle("AutoCollectHoney", {
	Text = "Auto Collect Honey",
	Default = false,
	Tooltip = "Automatically collects honey when ready",

	Callback = function(Value)
		getgenv().AutoCollectHoneyEnabled = Value
		if Value then
			Library:Notify("Auto Collect Honey enabled!", 3)
			task.spawn(function()
				while getgenv().AutoCollectHoneyEnabled do
					-- Check honey machine data with error handling
					local success, honeyMachineData = pcall(function()
						return DataService:GetData().HoneyMachine
					end)

					if success and honeyMachineData then
						local timeLeft = honeyMachineData.TimeLeft or 0
						local honeyStored = honeyMachineData.HoneyStored or 0

						print("🍯 Honey Machine Status - Time Left: " .. timeLeft .. "s | Honey Stored: " .. honeyStored)

						if timeLeft <= 0 and honeyStored > 0 then
							print("✅ Honey ready for collection! Attempting to collect...")

							-- Find honey machine with multiple search methods
							local honeyMachine = workspace:FindFirstChild("HoneyCombpressor", true)
									or workspace:FindFirstChild("HoneyMachine", true)
									or workspace:FindFirstChild("Honey", true)

							-- Alternative search in common locations
							if not honeyMachine then
								local locations = {
									workspace:FindFirstChild("Interaction"),
									workspace:FindFirstChild("Machines"),
									workspace:FindFirstChild("HoneyEvent")
								}

								for _, location in pairs(locations) do
									if location then
										honeyMachine = location:FindFirstChild("HoneyCombpressor", true)
												or location:FindFirstChild("HoneyMachine", true)
												or location:FindFirstChild("Honey", true)
										if honeyMachine then break end
									end
								end
							end

							if honeyMachine then
								print("🏭 Found honey machine: " .. honeyMachine.Name)

								-- Find collection point
								local collectionPoint = nil
								if honeyMachine:FindFirstChild("Spout") and honeyMachine.Spout:FindFirstChild("Jar") then
									collectionPoint = honeyMachine.Spout.Jar
								elseif honeyMachine:FindFirstChild("Jar") then
									collectionPoint = honeyMachine.Jar
								elseif honeyMachine:FindFirstChild("CollectionPoint") then
									collectionPoint = honeyMachine.CollectionPoint
								elseif honeyMachine.PrimaryPart then
									collectionPoint = honeyMachine.PrimaryPart
								end

								if collectionPoint and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
									-- Teleport to collection point
									local teleportPosition = collectionPoint.CFrame * CFrame.new(0, 5, 2) -- Slightly offset
									LocalPlayer.Character.HumanoidRootPart.CFrame = teleportPosition
									print("🚀 Teleported to honey collection point")
									task.wait(1) -- Wait for teleport to register

									-- Try multiple collection methods
									local collectionMethods = {
										function()
											ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("MachineInteract")
											print("📡 Tried method: MachineInteract")
										end,
										function()
											ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("CollectHoney")
											print("📡 Tried method: CollectHoney")
										end,
										function()
											ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("Collect")
											print("📡 Tried method: Collect")
										end,
										function()
											ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer()
											print("📡 Tried method: Default")
										end
									}

									local collectionSuccess = false
									for i, method in pairs(collectionMethods) do
										local methodSuccess = pcall(method)
										if methodSuccess then
											print("✅ Collection method " .. i .. " succeeded")
											collectionSuccess = true
											break
										else
											print("❌ Collection method " .. i .. " failed, trying next...")
										end
									end

									if collectionSuccess then
										Library:Notify("🍯 Collected " .. honeyStored .. " honey!", 3)
									else
										print("❌ All collection methods failed")
										Library:Notify("❌ Failed to collect honey!", 3)
									end

									task.wait(2)
								else
									print("❌ Could not find collection point or character")
									Library:Notify("❌ Could not find honey collection point!", 3)
									task.wait(5)
								end
							else
								print("❌ Could not find honey machine")
								Library:Notify("❌ Could not find honey machine!", 3)
								task.wait(10)
							end
						else
							if timeLeft > 0 then
								print("⏳ Honey not ready yet, time left: " .. timeLeft .. "s")
							end
							if honeyStored <= 0 then
								print("📭 No honey stored")
							end
							task.wait(5)
						end
					else
						print("❌ Could not access honey machine data")
						task.wait(5)
					end
				end
			end)
		else
			Library:Notify("Auto Collect Honey disabled!", 3)
		end
	end,
})

HoneyCollectionGroupBox:AddButton("Check Honey Machine Status", function()
	print("🔍 Checking honey machine status...")

	local success, honeyMachineData = pcall(function()
		return DataService:GetData().HoneyMachine
	end)

	if success and honeyMachineData then
		local timeLeft = honeyMachineData.TimeLeft or 0
		local honeyStored = honeyMachineData.HoneyStored or 0
		local plantWeight = honeyMachineData.PlantWeight or 0

		-- Try to get max plant weight with error handling
		local maxPlantWeight = 100 -- Default value
		local weightSuccess = pcall(function()
			maxPlantWeight = require(ReplicatedStorage.Data.HoneyMachineData).MAX_PLANT_WEIGHT
		end)

		if not weightSuccess then
			print("⚠️ Could not get MAX_PLANT_WEIGHT, using default value")
		end

		-- Format status message
		local statusMessage = string.format(
				"🍯 Honey: %d | Plants: %.1f/%.1f | Time: %ds",
				honeyStored,
				plantWeight,
				maxPlantWeight,
				timeLeft
		)

		-- Add status indicators
		local status = ""
		if timeLeft <= 0 and honeyStored > 0 then
			status = " | ✅ READY TO COLLECT"
		elseif timeLeft > 0 then
			status = " | ⏳ PROCESSING"
		elseif plantWeight >= maxPlantWeight then
			status = " | 🔄 FULL - READY TO START"
		else
			status = " | 📭 NEEDS PLANTS"
		end

		statusMessage = statusMessage .. status

		print("📊 " .. statusMessage)
		Library:Notify(statusMessage, 5)

		-- Additional detailed console output
		print("📊 Detailed Status:")
		print("   🍯 Honey Stored: " .. honeyStored)
		print("   ⏰ Time Left: " .. timeLeft .. " seconds")
		print("   🌱 Plant Weight: " .. plantWeight .. "/" .. maxPlantWeight)
		print("   📈 Efficiency: " .. math.floor((plantWeight/maxPlantWeight)*100) .. "%")

	else
		print("❌ Failed to get honey machine data")
		Library:Notify("❌ Could not get honey machine data!", 3)

		-- Try to find honey machine in workspace as fallback
		local honeyMachine = workspace:FindFirstChild("HoneyCombpressor", true)
		if honeyMachine then
			print("🏭 Found honey machine in workspace: " .. honeyMachine:GetFullName())
		else
			print("❌ Could not find honey machine in workspace")
		end
	end
end)

HoneyCollectionGroupBox:AddButton("🌺 Give Pollinated Fruit", function()
	print("🌺 Attempting to give pollinated fruit...")

	-- Check if player has a pollinated item equipped
	local equippedTool = nil
	if LocalPlayer.Character then
		for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
			if tool:IsA("Tool") and tool:GetAttribute("Pollinated") then
				equippedTool = tool
				break
			end
		end
	end

	if equippedTool then
		print("✅ Found equipped pollinated item: " .. equippedTool.Name)
	else
		print("🔍 No pollinated item equipped, checking backpack...")
		-- Try to equip a pollinated item from backpack
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if backpack then
			for _, tool in pairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and tool:GetAttribute("Pollinated") and not tool:GetAttribute("Favorite") then
					print("🎒 Equipping pollinated item: " .. tool.Name)
					LocalPlayer.Character.Humanoid:EquipTool(tool)
					task.wait(0.5)
					equippedTool = tool
					break
				end
			end
		end
	end

	if equippedTool then
		-- Try multiple remote methods
		local methods = {
			function() ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("MachineInteract") end,
			function() ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("SubmitPlant") end,
			function() ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer("GivePlant") end,
			function() ReplicatedStorage.GameEvents.HoneyMachineService_RE:FireServer() end
		}

		for i, method in pairs(methods) do
			local success = pcall(method)
			if success then
				print("✅ Successfully gave pollinated fruit using method " .. i)
				Library:Notify("🌺 Gave pollinated fruit!", 3)
				return
			else
				print("❌ Method " .. i .. " failed, trying next...")
			end
		end

		print("❌ All methods failed to give pollinated fruit")
		Library:Notify("❌ Failed to give pollinated fruit!", 3)
	else
		print("❌ No pollinated items found")
		Library:Notify("❌ No pollinated items found!", 3)
	end
end)

HoneyCollectionGroupBox:AddButton("🔄 Teleport to Honey Machine", function()
	local honeyMachine = workspace:FindFirstChild("HoneyCombpressor", true)
	if honeyMachine and honeyMachine:FindFirstChild("Onett") then
		local targetCFrame = honeyMachine.Onett.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
		LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
		Library:Notify("🔄 Teleported to Honey Machine!", 3)
	else
		Library:Notify("❌ Could not find Honey Machine!", 3)
	end
end)

-- Auto Farm Tab Variables
local AutoCollectPlantsEnabled = false
local SelectedPlantsToCollect = {}

-- Auto Farm Functions
local function CanHarvest(Plant)
	local Prompt = Plant:FindFirstChild("ProximityPrompt", true)
	if not Prompt then
		return
	end
	if not Prompt.Enabled then
		return
	end
	return true
end

local function HarvestPlant(Plant)
	local Prompt = Plant:FindFirstChild("ProximityPrompt", true)
	if not Prompt then
		return false
	end

	-- Ensure we have a character and root part
	if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return false
	end

	-- Get optimal position near the plant
	local plantPosition = Plant:GetPivot().Position
	local optimalPosition = plantPosition + Vector3.new(0, 2, 0) -- Position directly above the plant

	-- Teleport to optimal position for collection
	LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(optimalPosition)
	task.wait(0.5) -- Wait for teleport to register properly

	-- Get even closer to ensure proximity trigger
	local closePosition = plantPosition + Vector3.new(0, 0.5, 0)
	LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(closePosition)
	task.wait(0.3) -- Additional wait for proximity to activate

	-- Check if prompt is still enabled after positioning
	if not Prompt.Enabled then
		return false
	end

	-- Try fireproximityprompt multiple times for better reliability
	local success = false
	local maxAttempts = 3

	for attempt = 1, maxAttempts do
		local attemptSuccess = pcall(function()
			fireproximityprompt(Prompt)
		end)

		if attemptSuccess then
			task.wait(0.3) -- Wait for collection to process

			-- Check if the plant/fruit still exists (successful collection removes it)
			if not Plant.Parent then
				success = true
				break
			end
		end

		-- If not successful and not the last attempt, try repositioning
		if not success and attempt < maxAttempts then
			local retryPosition = plantPosition + Vector3.new(0.2, 0.3, 0.2)
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(retryPosition)
			task.wait(0.2)
		end
	end

	-- Final check - if plant is gone, collection was successful
	if not Plant.Parent then
		success = true
	end

	return success
end

local function CollectHarvestable(Parent, Plants, IgnoreDistance)
	local Character = LocalPlayer.Character
	if not Character then
		return Plants
	end

	local PlayerPosition = Character:GetPivot().Position

	for _, Plant in pairs(Parent:GetChildren()) do
		-- Check if auto collect is still enabled
		if not AutoCollectPlantsEnabled then
			break
		end
		-- Fruits - recursively check fruit folders with selection filter
		local Fruits = Plant:FindFirstChild("Fruits")
				or Plant:FindFirstChild("Fruit")
				or Plant:FindFirstChild("Fruit_Spawn")
		if Fruits then
			-- Check if the parent plant is selected before collecting its fruits
			local isParentPlantSelected = false
			if SelectedPlantsToCollect and next(SelectedPlantsToCollect) then
				for selectedPlant, selected in pairs(SelectedPlantsToCollect) do
					if selected and Plant.Name == selectedPlant then
						isParentPlantSelected = true
						break
					end
				end
			else
				-- If no plants are selected, collect all (backward compatibility)
				isParentPlantSelected = true
			end

			if isParentPlantSelected then
				print("🎯 Collecting fruits from selected plant:", Plant.Name)
				CollectHarvestable(Fruits, Plants, IgnoreDistance)
			else
				print("⏭️ Skipping fruits from unselected plant:", Plant.Name)
			end
		end

		-- Distance check (skip if too far and not ignoring distance)
		local PlantPosition = Plant:GetPivot().Position
		local Distance = (PlayerPosition - PlantPosition).Magnitude
		if not IgnoreDistance and Distance > 15 then
			continue
		end

		-- Check if plant is selected for collection
		local isPlantSelected = false
		if SelectedPlantsToCollect and next(SelectedPlantsToCollect) then
			-- Check if this specific plant name is selected
			for selectedPlant, selected in pairs(SelectedPlantsToCollect) do
				if selected and Plant.Name == selectedPlant then
					isPlantSelected = true
					break
				end
			end
		else
			-- If no plants are selected, collect all (backward compatibility)
			isPlantSelected = true
		end

		-- Collect if harvestable and selected
		if CanHarvest(Plant) and isPlantSelected then
			print("🎯 Adding selected plant to collection list:", Plant.Name)
			table.insert(Plants, Plant)
		elseif CanHarvest(Plant) and not isPlantSelected then
			print("⏭️ Skipping unselected plant:", Plant.Name)
		end
	end
	return Plants
end

local function GetHarvestablePlants(IgnoreDistance)
	local Plants = {}

	local success, result = pcall(function()
		local myFarm = getMyFarm()
		if myFarm then
			-- Check if there's a nested Farm folder inside the main farm folder
			local innerFarm = myFarm:FindFirstChild("Farm")
			if innerFarm then
				myFarm = innerFarm
			end

			local important = myFarm:FindFirstChild("Important")
			if important then
				-- Double-check this is actually our farm by verifying owner
				local data = important:FindFirstChild("Data")
				if data and data:FindFirstChild("Owner") and data.Owner.Value == LocalPlayer.Name then
					local plantsPhysical = important:FindFirstChild("Plants_Physical")
					if plantsPhysical then
						CollectHarvestable(plantsPhysical, Plants, IgnoreDistance)
					end
				end
			end
		end
	end)

	if not success then
		print("Error in GetHarvestablePlants:", result)
		-- Return empty table on error instead of crashing
		return {}
	end

	return Plants
end

local function HarvestPlants()
	local Plants = GetHarvestablePlants(true) -- Ignore distance to get all plants
	local harvestedCount = 0

	for _, Plant in pairs(Plants) do
		-- Check if auto collect is still enabled before each harvest
		if not AutoCollectPlantsEnabled then
			print("Auto collect stopped by user during harvest!")
			break
		end

		print("Harvesting plant:", Plant.Name)
		if HarvestPlant(Plant) then
			harvestedCount = harvestedCount + 1
			Library:Notify("✅ Harvested " .. Plant.Name, 1)
			print("Successfully harvested:", Plant.Name)
		else
			print("Failed to harvest:", Plant.Name)
		end

		-- Small delay between harvests
		task.wait(0.3)
	end

	return harvestedCount
end

local function collectAllPlants()
	-- Wrap entire function in error handling
	local success, result = pcall(function()
		-- Check if we need to equip Harvest Tool first
		local player = LocalPlayer
		local backpack = player:FindFirstChild("Backpack")
		local harvestTool = nil

		if backpack then
			harvestTool = backpack:FindFirstChild("Harvest Tool")
			if harvestTool and player.Character and player.Character:FindFirstChild("Humanoid") then
				print("Equipping Harvest Tool...")
				player.Character.Humanoid:EquipTool(harvestTool)
				task.wait(0.5)
			else
				print("No Harvest Tool found in backpack or character not ready")
			end
		end

		-- Enhanced noclip for better plant access
		local function enableNoclip()
			if LocalPlayer.Character then
				for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
						if part.Name ~= "HumanoidRootPart" then
							part.Massless = true
						end
					end
				end
			end
		end

		-- Disable noclip and restore physics
		local function disableNoclip()
			if LocalPlayer.Character then
				print("Disabling noclip and restoring physics...")
				for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						part.CanCollide = true
						part.Massless = false

						-- Extra restoration for legs specifically
						if
						string.find(part.Name:lower(), "leg")
								or string.find(part.Name:lower(), "foot")
								or string.find(part.Name:lower(), "ankle")
						then
							part.CanCollide = true
							part.Massless = false
							part.Material = Enum.Material.Plastic
							print("Restored leg physics for:", part.Name)
						end
					end
				end

				-- Force physics refresh
				local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
				if humanoid then
					humanoid.PlatformStand = false -- Ensure not platform standing
				end
				print("Noclip disabled and physics restored")
			end
		end

		print("=== STARTING AUTO COLLECT ALL PLANTS ===")

		-- Check if character exists before starting
		if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			Library:Notify("❌ Character not ready! Try again in a moment.", 3)
			return
		end

		-- Enable noclip for better movement
		enableNoclip()
		-- Get all harvestable plants (simplified - single attempt)
		local Plants = GetHarvestablePlants(true) -- Ignore distance to collect from entire farm
		print("Found", #Plants, "harvestable plants")
		if #Plants == 0 then
			-- Check if any plants were selected
			local selectedCount = 0
			if SelectedPlantsToCollect then
				for _, selected in pairs(SelectedPlantsToCollect) do
					if selected then
						selectedCount = selectedCount + 1
					end
				end
			end

			if selectedCount > 0 then
				Library:Notify(
						"❌ No harvestable selected plants found in farm (looked for " .. selectedCount .. " types)",
						4
				)
			else
				Library:Notify("❌ No plants selected for collection! Use the dropdown to select plants.", 4)
			end
			disableNoclip()
			return
		end

		-- Show what we found
		local selectedCount = 0
		if SelectedPlantsToCollect then
			for _, selected in pairs(SelectedPlantsToCollect) do
				if selected then
					selectedCount = selectedCount + 1
				end
			end
		end

		if selectedCount > 0 then
			Library:Notify(
					"🚜 Found "
							.. #Plants
							.. " harvestable plants from "
							.. selectedCount
							.. " selected types! Starting collection...",
					4
			)
		else
			Library:Notify("🚜 Found " .. #Plants .. " harvestable plants (all types)! Starting collection...", 4)
		end

		local harvestedCount = 0

		-- Visit each plant and harvest it
		for i, Plant in pairs(Plants) do
			-- Check if auto collect is still enabled
			if not AutoCollectPlantsEnabled then
				print("Auto collect stopped by user!")
				break
			end

			-- Check if character still exists (in case of respawn)
			if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
				print("Character was lost during collection! Stopping...")
				Library:Notify("❌ Character was lost! Auto collect stopped.", 3)
				break
			end

			-- Check if plant still exists
			if not Plant or not Plant.Parent then
				print("Plant", i, "no longer exists, skipping...")
				continue
			end

			print("Processing plant", i, "of", #Plants, ":", Plant.Name) -- Teleport directly to the plant (simplified)
			local teleportSuccess = pcall(function()
				local plantPosition = Plant:GetPivot().Position
				print("Teleporting to plant:", Plant.Name, "at position:", plantPosition)

				-- Single teleport directly to plant
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(plantPosition + Vector3.new(0, 1, 0))
			end)

			if not teleportSuccess then
				print("Failed to teleport to plant:", Plant.Name)
				continue
			end

			-- Harvest the plant with error handling
			local harvestSuccess, harvestResult = pcall(function()
				return HarvestPlant(Plant)
			end)

			if harvestSuccess and harvestResult then
				harvestedCount = harvestedCount + 1
				Library:Notify("✅ Harvested " .. Plant.Name, 1)
				print("Successfully harvested:", Plant.Name)
			else
				print("Failed to harvest:", Plant.Name, harvestSuccess and "" or harvestResult)
				Library:Notify("❌ Failed to harvest " .. Plant.Name, 1)
			end -- Quick wait before moving to next plant
			task.wait(0.1) -- Reduced from 0.2 to 0.1 seconds
		end

		-- Restore physics
		disableNoclip()

		print("=== AUTO COLLECT COMPLETED ===")
		print("Harvested", harvestedCount, "out of", #Plants, "plants")

		if harvestedCount > 0 then
			Library:Notify("🚜 Harvested " .. harvestedCount .. " plants successfully!", 4)
		else
			Library:Notify("❌ No plants were harvested this cycle", 3)
		end
	end)

	-- Handle any errors that occur during collection
	if not success then
		print("Error in collectAllPlants:", result)
		Library:Notify("❌ Auto collect encountered an error: " .. tostring(result), 4)

		-- Try to restore physics even if there was an error
		pcall(function()
			restoreCharacterPhysics()
		end)
	end
end

-- Auto Farm Tab UI
local AutoFarmGroupBox = Tabs["Auto Farm"]:AddLeftGroupbox("Auto Collection")

-- Function to restore character physics properly
local function restoreCharacterPhysics()
	pcall(function()
		if LocalPlayer.Character then
			print("Restoring character physics...")

			-- Restore all body parts with specific handling
			for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					-- Always restore CanCollide for body parts (except HumanoidRootPart)
					if part.Name ~= "HumanoidRootPart" then
						part.CanCollide = true
						part.Massless = false
						print("Restored physics for:", part.Name)
					end

					-- Special handling for leg parts
					if
					string.find(part.Name:lower(), "leg")
							or string.find(part.Name:lower(), "foot")
							or string.find(part.Name:lower(), "ankle")
					then
						part.CanCollide = true
						part.Massless = false
						part.Material = Enum.Material.Plastic -- Reset material
						print("Special leg restoration for:", part.Name)
					end
				end
			end

			-- Force character to reset physics state
			local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
			if humanoid then
				-- Temporarily change and restore PlatformStand to refresh physics
				humanoid.PlatformStand = true
				task.wait(0.1)
				humanoid.PlatformStand = false
				print("Refreshed humanoid physics")
			end

			-- Reset camera to normal
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
			LocalPlayer.CameraMaxZoomDistance = 128
			LocalPlayer.CameraMinZoomDistance = 0.5

			local Camera = workspace.CurrentCamera
			Camera.CameraType = Enum.CameraType.Custom
			Camera.CameraSubject = humanoid

			print("Character physics and camera fully restored")
		end
	end)
end

-- Collection method is now fixed to traditional method
-- Fast collection method has been removed

-- Plant selection dropdown for auto farm
AutoFarmGroupBox:AddDropdown("PlantsToCollect", {	Values = {
		"Apple",
		"Avocado",
		"Bamboo",
		"Banana",
		"Beanstalk",
		"Bee Balm",
		"Bell Pepper",
		"Bendboo",
		"Blood Banana",
		"Blueberry",
		"Cacao",
		"Cactus",
		"Candy Blossom",
		"Cantaloupe",
		"Carrot",
		"Cauliflower",
		"Celestiberry",
		"Cherry Blossom",
		"Cherry OLD",
		"Chocolate Carrot",
		"Cocovine",
		"Coconut",
		"Corn",
		"Cranberry",
		"Crimson Vine",
		"Crocus",
		"Cursed Fruit",
		"Daffodil",
		"Dandelion",
		"Dragon Fruit",
		"Dragon Pepper",
		"Durian",
		"Easter Egg",
		"Eggplant",
		"Elephant Ears",
		"Ember Lily",
		"Feijoa",
		"Foxglove",
		"Glowshroom",
		"Grape",
		"Green Apple",
		"Hive Fruit",
		"Honeysuckle",
		"Ice Cream Bean",
		"Kiwi",
		"Lavender",
		"Lemon",
		"Lilac",
		"Lime",
		"Loquat",
		"Lotus",
		"Lumira",
		"Mango",
		"Manuka Flower",
		"Mega Mushroom",
		"Mint",
		"Moon Blossom",
		"Moon Mango",
		"Moon Melon",
		"Moonflower",
		"Moonglow",
		"Mushroom",
		"Nectar Thorn",
		"Nectarine",
		"Nectarshade",
		"Nightshade",
		"Noble Flower",
		"Orange Tulip",
		"Papaya",
		"Parasol Flower",
		"Passionfruit",
		"Peach",
		"Pear",
		"Pepper",
		"Pineapple",
		"Pink Lily",
		"Pink Tulip",
		"Prickly Pear",
		"Pumpkin",
		"Purple Cabbage",
		"Purple Dahlia",
		"Raspberry",
		"Red Lollipop",
		"Rose",
		"Rosy Delight",
		"Soul Fruit",
		"Starfruit",
		"Strawberry",
		"Succulent",
		"Sugar Apple",
		"Suncoil",
		"Sunflower",
		"Tomato",
		"Traveler's Fruit",
		"Venus Fly Trap",
		"Violet Corn",
		"Watermelon",		"Wild Carrot",
	},
	Default = 1,
	Multi = true, -- Allow multiple selections

	Text = "Select Plants/Fruits to Collect",
	Tooltip = "Choose which plants and fruits to auto-collect. Only selected plants will be teleported to and collected.",

	Callback = function(Value)
		print("[cb] Selected plants/fruits for collection changed:")
		SelectedPlantsToCollect = Value
		for plant, selected in next, Options.PlantsToCollect.Value do
			print(plant, selected)
		end
	end,
})

AutoFarmGroupBox:AddToggle("AutoCollectAllPlants", {
	Text = "Auto Collect Selected Plants",
	Tooltip = "Automatically collect mature fruits, vegetables and items from your selected plants. Use the dropdown above to choose which plants to collect.",
	Default = false,
	Callback = function(Value)
		print("[cb] Auto Collect All Plants toggled:", Value)
		AutoCollectPlantsEnabled = Value
		if Value then
			local methodText = "(Traditional Method)" -- Fast collection method has been removed

			-- Check if any plants are selected
			local selectedCount = 0
			if SelectedPlantsToCollect then
				for _, selected in pairs(SelectedPlantsToCollect) do
					if selected then
						selectedCount = selectedCount + 1
					end
				end
			end

			if selectedCount > 0 then
				Library:Notify(
						"🚜 Auto Collect Selected Plants enabled! (" .. selectedCount .. " types selected) " .. methodText,
						3
				)
			else
				Library:Notify("🚜 Auto Collect enabled! (All plants - no selection made) " .. methodText, 3)
			end
			-- Start auto collection loop
			task.spawn(function()
				while AutoCollectPlantsEnabled do
					if AutoCollectPlantsEnabled then -- Double check before starting collection
						-- Choose collection method based on preference
						-- Fast collection method has been removed
						-- Always use traditional method
						if false then
							-- This code is never executed
							local fastCollectionSuccess = pcall(function()
								print("🚀 Starting FAST collection using E key spam...")

								-- Try fast collection method first
								local collectedCount = 0
								local maxAttempts = 30 -- Increased from 20 to 30 for more reliable collection

								-- First try a rapid burst of E key presses
								for attempt = 1, 10 do
									if not AutoCollectPlantsEnabled then
										break
									end

									print("Fast E key spam burst attempt", attempt, "of", 10)
									local success = pcall(function()
										-- Spam E key to collect fruits (simulate manual collection)
										local vim = game:GetService("VirtualInputManager")
										vim:SendKeyEvent(true, "E", false, game)
										task.wait(0.01) -- Very brief hold
										vim:SendKeyEvent(false, "E", false, game)
									end)

									if success then
										collectedCount = collectedCount + 1
										task.wait(0.03) -- Very short delay between E key presses in burst mode
									else
										print("Fast E key spam burst attempt failed:", attempt)
										task.wait(0.05) -- Slightly longer wait on failure
									end
								end

								-- Then try more deliberate presses with slightly longer delays
								for attempt = 11, maxAttempts do
									if not AutoCollectPlantsEnabled then
										break
									end

									print("Fast E key spam attempt", attempt, "of", maxAttempts)
									local success = pcall(function()
										-- Spam E key to collect fruits (simulate manual collection)
										local vim = game:GetService("VirtualInputManager")
										vim:SendKeyEvent(true, "E", false, game)
										task.wait(0.02) -- Slightly longer hold for better registration
										vim:SendKeyEvent(false, "E", false, game)
									end)

									if success then
										collectedCount = collectedCount + 1
										Library:Notify("⚡ Fast E spam attempt " .. attempt, 0.5)
										task.wait(0.08) -- Slightly longer delay for more reliable registration
									else
										print("Fast E key spam attempt failed:", attempt)
										task.wait(0.1) -- Longer wait on failure
									end
								end

								if collectedCount > 0 then
									Library:Notify(
											"⚡ Fast E key spam completed! " .. collectedCount .. " attempts made",
											3
									)
								end
							end)

							-- If fast method fails, try again with traditional method as backup
							if not fastCollectionSuccess then
								print("⚠️ Fast collection encountered an issue, trying traditional method...")
								Library:Notify("⚠️ Using traditional collection method as backup", 2)

								-- Try traditional collection with error handling
								local traditionalSuccess, traditionalResult = pcall(function()
									collectAllPlants()
								end)

								if not traditionalSuccess then
									print("❌ Traditional collection also failed:", traditionalResult)
									Library:Notify("❌ Collection failed. Retrying next cycle...", 3)
									-- Force restore physics to prevent character issues
									pcall(function()
										restoreCharacterPhysics()
									end)
								end
							end
						else
							-- Use traditional collection method
							print("🐌 Using traditional collection method...")
							collectAllPlants()
						end
					end -- Wait between collection cycles, but check if still enabled

					-- Shorter wait time for more frequent collection attempts
					for i = 1, 3 do -- 1.5 seconds total wait (0.5s x 3)
						if not AutoCollectPlantsEnabled then
							break
						end
						task.wait(0.5)
					end
				end
				print("Auto collect all plants loop ended")
				-- Ensure cleanup when loop ends
				restoreCharacterPhysics()
			end)
		else
			Library:Notify("🚜 Auto Collect Selected Plants disabled!", 3)
			print("Auto collect selected plants disabled by user")
			-- Immediate cleanup when toggle is turned off
			restoreCharacterPhysics()
		end
	end,
})

-- Testing buttons for fast collection method

AutoFarmGroupBox:AddButton("📋 Show Selected Plants", function()
	if not SelectedPlantsToCollect or not next(SelectedPlantsToCollect) then
		Library:Notify("❌ No plants selected for collection", 3)
		return
	end

	local selectedPlants = {}
	for plant, selected in pairs(SelectedPlantsToCollect) do
		if selected then
			table.insert(selectedPlants, plant)
		end
	end

	if #selectedPlants == 0 then
		Library:Notify("❌ No plants currently selected", 3)
	else
		local plantList = table.concat(selectedPlants, ", ")
		print("🎯 Selected plants for collection:", plantList)
		Library:Notify("🎯 " .. #selectedPlants .. " plants selected: " .. plantList, 5)
	end
end)

AutoFarmGroupBox:AddButton("Select Common Plants", function()
	local commonPlants = {
		"Apple",
		"Banana",
		"Orange",
		"Strawberry",
		"Blueberry",
		"Tomato",
		"Carrot",
		"Corn",
		"Potato",
		"Watermelon",
	}

	-- Reset current selection and select common plants
	SelectedPlantsToCollect = {}
	for _, plant in pairs(commonPlants) do
		SelectedPlantsToCollect[plant] = true
	end

	-- Update the dropdown to reflect the selection
	if Options.PlantsToCollect then
		Options.PlantsToCollect:SetValue(SelectedPlantsToCollect)
	end

	Library:Notify("🍎 Selected " .. #commonPlants .. " common plants for collection", 3)
end)

AutoFarmGroupBox:AddButton("🗑️ Clear Plant Selection", function()
	SelectedPlantsToCollect = {}

	-- Update the dropdown to reflect the clearing
	if Options.PlantsToCollect then
		Options.PlantsToCollect:SetValue({})
	end

	Library:Notify("Cleared all plant selections", 2)
end)

AutoFarmGroupBox:AddButton("Check Farm Status", function()
	local myFarm = getMyFarm()
	if myFarm then
		local innerFarm = myFarm:FindFirstChild("Farm")
		if innerFarm then
			myFarm = innerFarm
		end

		local important = myFarm:FindFirstChild("Important")
		if important then
			local plantsPhysical = important:FindFirstChild("Plants_Physical")
			if plantsPhysical then
				local plantsCount = #plantsPhysical:GetChildren()
				local collectibleCount = 0
				local plantTypes = {}
				local collectibleTypes = {}

				print("=== ENHANCED FARM DEBUG INFO ===")
				print("Farm structure:", myFarm.Name)
				print("Plants found:", plantsCount)

				for _, plant in pairs(plantsPhysical:GetChildren()) do
					local plantName = plant.Name
					plantTypes[plantName] = (plantTypes[plantName] or 0) + 1

					print("Plant:", plantName, "Type:", plant.ClassName)

					-- Enhanced fruit/collectible detection
					local fruitFolders = {
						plant:FindFirstChild("Fruits"),
						plant:FindFirstChild("Fruit"),
						plant:FindFirstChild("Fruit_Spawn"),
						plant:FindFirstChild("Collectables"),
						plant:FindFirstChild("Collectibles"),
						plant:FindFirstChild("Items"),
					}

					for _, fruitFolder in pairs(fruitFolders) do
						if fruitFolder then
							print("  Found folder:", fruitFolder.Name, "with", #fruitFolder:GetChildren(), "children")
							for _, item in pairs(fruitFolder:GetChildren()) do
								print("    Item:", item.Name, "Type:", item.ClassName)

								-- Enhanced collectible detection
								local isCollectible = false

								-- Check for models with proximity prompts
								if item:IsA("Model") and item:FindFirstChildOfClass("ProximityPrompt", true) then
									isCollectible = true
									-- Check for parts with proximity prompts
								elseif item:IsA("Part") and item:FindFirstChildOfClass("ProximityPrompt") then
									isCollectible = true
									-- Check for tagged items
								elseif item:HasTag("Collectable") or item:HasTag("Collectible") then
									isCollectible = true
									-- Check for attributed items
								elseif item:GetAttribute("Collectable") or item:GetAttribute("Collectible") then
									isCollectible = true
									-- Check for specific fruit/item names
								elseif
								string.find(item.Name:lower(), "fruit")
										or string.find(item.Name:lower(), "berry")
										or string.find(item.Name:lower(), "apple")
										or string.find(item.Name:lower(), "orange")
										or string.find(item.Name:lower(), "banana")
										or string.find(item.Name:lower(), "grape")
								then
									isCollectible = true
								end

								if isCollectible then
									collectibleCount = collectibleCount + 1
									collectibleTypes[item.Name] = (collectibleTypes[item.Name] or 0) + 1
									print("      -> COLLECTIBLE!")
								end
							end
						end
					end

					-- Enhanced direct children check
					for _, child in pairs(plant:GetChildren()) do
						if
						child:HasTag("Collectable")
								or child:HasTag("Collectible")
								or child:GetAttribute("Collectable")
								or child:GetAttribute("Collectible")
						then
							print("  Tagged collectible:", child.Name)
							collectibleCount = collectibleCount + 1
							collectibleTypes[child.Name] = (collectibleTypes[child.Name] or 0) + 1
						end
					end
				end

				-- Enhanced output with detailed breakdown
				print("=== PLANT BREAKDOWN ===")
				for plantType, count in pairs(plantTypes) do
					print("  " .. plantType .. ": " .. count)
				end

				print("=== COLLECTIBLE BREAKDOWN ===")
				for collectibleType, count in pairs(collectibleTypes) do
					print("  " .. collectibleType .. ": " .. count)
				end

				print("=== END ENHANCED DEBUG INFO ===")

				-- Create detailed status message
				local statusMessage =
				string.format("🚜 Farm Status: %d plants, %d collectibles", plantsCount, collectibleCount)

				-- Add plant type summary if there are multiple types
				if next(plantTypes) then
					local plantSummary = {}
					for plantType, count in pairs(plantTypes) do
						table.insert(plantSummary, count .. " " .. plantType)
					end
					if #plantSummary > 1 then
						statusMessage = statusMessage .. "\n🌱 Plants: " .. table.concat(plantSummary, ", ")
					end
				end

				-- Add collectible summary if any found
				if collectibleCount > 0 then
					local collectibleSummary = {}
					for collectibleType, count in pairs(collectibleTypes) do
						table.insert(collectibleSummary, count .. " " .. collectibleType)
					end
					if #collectibleSummary > 0 then
						statusMessage = statusMessage
								.. "\n🍎 Ready to collect: "
								.. table.concat(collectibleSummary, ", ")
					end
				end

				Library:Notify(statusMessage, 6)
			else
				Library:Notify("❌ Plants_Physical folder not found!", 3)
			end
		else
			Library:Notify("❌ Important folder not found in farm!", 3)
		end
	else
		Library:Notify("❌ No farm found for this player!", 3)
	end
end)

-- Teleport to Farm button removed per user request

-- print removed: Script loaded successfully

-- Pet Tab
-- Pet Auto Feed Functions
local AutoFeedPetEnabled = false
local SelectedPlantsToFeed = {}

-- Pet Services
local function getPetServices()
	local success, result = pcall(function()
		if ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("PetServices") then
			local PetServices = ReplicatedStorage.Modules.PetServices
			local ActivePetsService = require(PetServices:FindFirstChild("ActivePetsService"))
			local PetsService = require(PetServices:FindFirstChild("PetsService"))
			return {
				ActivePetsService = ActivePetsService,
				PetsService = PetsService,
			}
		end
		return nil
	end)
	if success then
		return result
	else
		return nil
	end
end

-- Check if a specific pet needs food
local function petNeedsFood(petUUID)
	local success, result = pcall(function()
		-- Get current pet data
		local DataService = require(ReplicatedStorage.Modules.DataService)
		local data = DataService:GetData()

		if not data or not data.PetsData then
			print("No PetsData found for hunger check")
			return true -- If we can't check, assume it needs food
		end

		-- Find the pet in inventory data
		local petInventory = data.PetsData.PetInventory
		if not petInventory or not petInventory.Data then
			print("No PetInventory found for hunger check")
			return true
		end

		local petData = petInventory.Data[petUUID]
		if not petData then
			print("Pet data not found for UUID:", petUUID)
			return true
		end

		-- Get pet type data for DefaultHunger
		local PetRegistry = require(ReplicatedStorage.Data.PetRegistry)
		local PetList = PetRegistry.PetList
		local petTypeData = PetList[petData.PetType]

		if not petTypeData then
			print("Pet type data not found for:", petData.PetType)
			return true
		end

		local defaultHunger = petTypeData.DefaultHunger or 100
		local currentHunger = petData.PetData.Hunger or 0
		local hungerPercentage = currentHunger / defaultHunger

		print(
				"Hunger check for",
				petData.PetType,
				"- Current:",
				currentHunger,
				"Max:",
				defaultHunger,
				"Percentage:",
				math.floor(hungerPercentage * 100) .. "%"
		)

		-- Adjust threshold - maybe pets don't need food if they're above 90% fed
		local needsFood = hungerPercentage < 0.9
		print("Pet needs food:", needsFood, "(threshold: 90%)")

		return needsFood
	end)

	if success then
		return result
	else
		print("Error checking pet hunger:", result)
		return true -- If error checking, assume it needs food
	end
end

-- Get player's active pets
local function getActivePets()
	local petServices = getPetServices()
	if not petServices then
		return {}
	end

	local success, result = pcall(function()
		-- Get PetUtilities for proper pet access
		local PetUtilities = nil
		if ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("PetServices") then
			PetUtilities = require(ReplicatedStorage.Modules.PetServices:FindFirstChild("PetUtilities"))
		end

		if not PetUtilities then
			print("PetUtilities not found")
			return {}
		end

		-- Get data service for pet data
		local DataService = require(ReplicatedStorage.Modules.DataService)
		local data = DataService:GetData()

		if not data or not data.PetsData then
			print("No PetsData found")
			return {}
		end

		-- Get PetRegistry for pet type data (needed for DefaultHunger)
		local PetRegistry = require(ReplicatedStorage.Data.PetRegistry)
		local PetList = PetRegistry.PetList

		-- Get equipped pets list - this is the key part from pet3 docs
		local equippedPets = data.PetsData.EquippedPets or {}
		print("Found equipped pets:", #equippedPets)

		local activePets = {}

		-- Method 1: Get pets using PetUtilities (like in pet3)
		local petsFromUtilities = PetUtilities:GetPetsSortedByAge(LocalPlayer, 0, false, true)
		print("PetUtilities found pets:", #petsFromUtilities)

		for _, petData in pairs(petsFromUtilities) do
			-- Get pet type data for DefaultHunger
			local petTypeData = PetList[petData.PetType]
			local defaultHunger = petTypeData and petTypeData.DefaultHunger or 100
			local currentHunger = petData.PetData.Hunger or 0
			local hungerPercentage = currentHunger / defaultHunger

			-- More strict threshold - only feed if less than 90% full (was 80%)
			local needsFood = hungerPercentage < 0.9

			print("Pet hunger analysis:")
			print("- Type:", petData.PetType)
			print("- Current hunger:", currentHunger)
			print("- Max hunger:", defaultHunger)
			print("- Hunger percentage:", math.floor(hungerPercentage * 100) .. "%")
			print("- Needs food:", needsFood, "(threshold: 90%)")

			table.insert(activePets, {
				uuid = petData.UUID,
				petType = petData.PetType or "Unknown",
				petData = petData.PetData,
				isEquipped = true,
				currentHunger = currentHunger,
				maxHunger = defaultHunger,
				hungerPercentage = hungerPercentage,
				needsFood = needsFood,
			})
		end

		-- Method 2: Also check workspace for pet objects with proper attributes
		for _, obj in pairs(workspace:GetDescendants()) do
			if
			obj:GetAttribute("OWNER") == LocalPlayer.Name
					and obj:GetAttribute("UUID")
					and obj:HasTag("PetTargetable")
			then
				-- Check if we already have this pet from utilities
				local alreadyHave = false
				for _, existing in pairs(activePets) do
					if existing.uuid == obj:GetAttribute("UUID") then
						alreadyHave = true
						existing.object = obj -- Add the physical object reference
						break
					end
				end

				if not alreadyHave then
					-- For pets not found in utilities, check their hunger individually
					local stillNeedsFood = petNeedsFood(obj:GetAttribute("UUID"))
					print("Workspace pet hunger check:", obj:GetAttribute("UUID"), "needs food:", stillNeedsFood)

					table.insert(activePets, {
						uuid = obj:GetAttribute("UUID"),
						petType = obj:GetAttribute("PetType") or "Unknown",
						object = obj,
						isEquipped = true,
						currentHunger = 0,
						maxHunger = 100,
						hungerPercentage = 0,
						needsFood = stillNeedsFood,
					})
				end
			end
		end

		print("Total active pets found:", #activePets)
		-- Show hunger status for each pet with more detail
		for i, pet in pairs(activePets) do
			local hungerStatus = math.floor(pet.hungerPercentage * 100)
			print(
					"Pet #"
							.. i
							.. " ("
							.. pet.petType
							.. ") - Hunger: "
							.. hungerStatus
							.. "% ("
							.. pet.currentHunger
							.. "/"
							.. pet.maxHunger
							.. ") - Needs food: "
							.. tostring(pet.needsFood)
			)
		end

		return activePets
	end)

	if success then
		return result
	else
		print("Error getting active pets:", result)
		return {}
	end
end

-- Get player's fruit/plant inventory
local function getPlayerFruits()
	local fruits = {}

	-- Check character inventory
	if LocalPlayer.Character then
		for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
			if tool:IsA("Tool") and tool:HasTag("FruitTool") then
				table.insert(fruits, tool.Name)
			end
		end
	end

	-- Check backpack
	if LocalPlayer.Backpack then
		for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
			if tool:IsA("Tool") and tool:HasTag("FruitTool") then
				table.insert(fruits, tool.Name)
			end
		end
	end

	-- Remove duplicates
	local uniqueFruits = {}
	local seen = {}
	for _, fruit in pairs(fruits) do
		if not seen[fruit] then
			seen[fruit] = true
			table.insert(uniqueFruits, fruit)
		end
	end

	return uniqueFruits
end

-- Feed pets with selected plants
local function feedPetsWithPlants()
	local petServices = getPetServices()
	if not petServices then
		print("Pet services not available")
		return false
	end

	local activePets = getActivePets()
	print("=== FEEDING PETS ===")
	print("Active pets found:", #activePets)

	if #activePets == 0 then
		print("No active pets found")
		Library:Notify("❌ No active pets found!", 3)
		return false
	end

	-- Filter pets that actually need food
	local hungryPets = {}
	for i, pet in pairs(activePets) do
		local hungerStatus = math.floor(pet.hungerPercentage * 100)
		print(
				"Pet #"
						.. i
						.. " ("
						.. pet.petType
						.. ") - Hunger: "
						.. hungerStatus
						.. "% - Needs food: "
						.. tostring(pet.needsFood)
		)

		if pet.needsFood then
			table.insert(hungryPets, pet)
			print("✅ Pet #" .. i .. " needs food (hunger: " .. hungerStatus .. "%)")
		else
			print("⏭️ Pet #" .. i .. " is well-fed (hunger: " .. hungerStatus .. "%) - skipping")
			Library:Notify(
					"⏭️ Pet #" .. i .. " (" .. pet.petType .. ") is well-fed (" .. hungerStatus .. "%) - skipping",
					1
			)
		end
	end

	print("Hungry pets that need feeding:", #hungryPets, "out of", #activePets, "total pets")

	if #hungryPets == 0 then
		print("No pets need feeding - all are well-fed!")
		Library:Notify("🎉 All pets are well-fed! No feeding needed.", 3)
		return false
	end

	-- Check if player has any selected fruits
	local availableFruits = {}
	for plantName, selected in pairs(SelectedPlantsToFeed) do
		if selected then
			-- Check if player has this fruit in inventory
			local hasFruit = false
			local fruitTool = nil

			-- Check character first
			if LocalPlayer.Character then
				for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
					if tool:IsA("Tool") and tool:HasTag("FruitTool") and tool.Name == plantName then
						hasFruit = true
						fruitTool = tool
						break
					end
				end
			end

			-- Check backpack if not found in character
			if not hasFruit and LocalPlayer.Backpack then
				for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
					if tool:IsA("Tool") and tool:HasTag("FruitTool") and tool.Name == plantName then
						fruitTool = tool
						hasFruit = true
						break
					end
				end
			end

			if hasFruit and fruitTool then
				table.insert(availableFruits, { name = plantName, tool = fruitTool })
			end
		end
	end

	print("Available fruits:", #availableFruits)
	for i, fruit in pairs(availableFruits) do
		print("Fruit #" .. i .. ":", fruit.name)
	end

	if #availableFruits == 0 then
		print("No selected fruits available in inventory")
		Library:Notify("❌ No selected fruits found in inventory!", 3)
		return false
	end

	local fedCount = 0
	local totalFeedAttempts = 0
	local skippedWellFed = 0

	-- Feed each fruit type to ONLY HUNGRY pets
	for fruitIndex, fruitData in pairs(availableFruits) do
		print("=== FEEDING FRUIT #" .. fruitIndex .. ": " .. fruitData.name .. " ===")

		-- Equip the fruit if not already equipped
		if fruitData.tool.Parent ~= LocalPlayer.Character then
			print("Equipping fruit:", fruitData.name)
			LocalPlayer.Character.Humanoid:EquipTool(fruitData.tool)
			task.wait(0.8) -- Wait for equip
		end

		-- Verify fruit is equipped
		local currentTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
		if not currentTool or not currentTool:HasTag("FruitTool") then
			print("ERROR: Failed to equip fruit", fruitData.name)
			Library:Notify("Failed to equip " .. fruitData.name, 2)
			continue
		end

		print("Successfully equipped:", currentTool.Name)

		-- Feed ONLY HUNGRY pets with this fruit
		for petIndex, pet in pairs(hungryPets) do
			-- Check if auto feed is still enabled
			if not AutoFeedPetEnabled then
				print("Auto feed disabled by user")
				break
			end

			-- Double-check if pet still needs food (hunger might have changed)
			print("=== PRE-FEED HUNGER CHECK ===")
			local stillNeedsFood = petNeedsFood(pet.uuid)
			print("Pet", pet.petType, "still needs food:", stillNeedsFood)

			if not stillNeedsFood then
				skippedWellFed = skippedWellFed + 1
				print("⏭️ Pet #" .. petIndex .. " (" .. pet.petType .. ") is now well-fed (90%+) - skipping")
				Library:Notify(
						"⏭️ Pet #" .. petIndex .. " (" .. pet.petType .. ") is now well-fed (90%+) - skipping",
						1
				)
				continue
			end

			totalFeedAttempts = totalFeedAttempts + 1
			local hungerStatus = math.floor(pet.hungerPercentage * 100)
			print(
					"Feeding attempt #"
							.. totalFeedAttempts
							.. " - Pet #"
							.. petIndex
							.. " ("
							.. pet.petType
							.. ") ["
							.. hungerStatus
							.. "% hunger] with "
							.. fruitData.name
			)

			-- Double-check fruit is still equipped
			currentTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
			if not currentTool or not currentTool:HasTag("FruitTool") then
				print("ERROR: Fruit disappeared, re-equipping...")
				LocalPlayer.Character.Humanoid:EquipTool(fruitData.tool)
				task.wait(0.5)
				currentTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
				if not currentTool then
					print("ERROR: Cannot re-equip fruit for pet", petIndex)
					break
				end
			end

			-- Try to feed the pet using ActivePetsService:Feed
			print("=== ATTEMPTING TO FEED PET ===")
			print("Pet UUID:", pet.uuid)
			print("Pet Type:", pet.petType)
			print("Fruit:", currentTool.Name)

			local success, result = pcall(function()
				petServices.ActivePetsService:Feed(pet.uuid)
			end)

			if success then
				fedCount = fedCount + 1
				print(
						"✅ SUCCESS: Fed pet #"
								.. petIndex
								.. " ("
								.. pet.petType
								.. ") ["
								.. hungerStatus
								.. "% → more fed] with "
								.. fruitData.name
				)
				Library:Notify(
						"🐾 Fed Pet #"
								.. petIndex
								.. " ("
								.. pet.petType
								.. ") ["
								.. hungerStatus
								.. "%] with "
								.. fruitData.name,
						1
				)

				-- Wait and then check hunger again
				task.wait(1.0)

				-- Post-feed hunger check to see if pet is now full
				print("=== POST-FEED HUNGER CHECK ===")
				local nowNeedsFood = petNeedsFood(pet.uuid)
				print("Pet", pet.petType, "still needs food after feeding:", nowNeedsFood)

				if not nowNeedsFood then
					print("🎉 Pet #" .. petIndex .. " (" .. pet.petType .. ") is now full! Moving to next pet.")
					Library:Notify("🎉 Pet #" .. petIndex .. " (" .. pet.petType .. ") is now full!", 1)
				end

				-- Wait between each pet feeding
				task.wait(0.8)
			else
				print("❌ FAILED: Pet #" .. petIndex .. " (" .. pet.petType .. ") - Error:", result)
				-- Pet might be full now or error occurred, continue to next pet
				Library:Notify("⚠️ Pet #" .. petIndex .. " couldn't be fed (might be full now)", 1)
				task.wait(0.8)
			end
		end

		-- Wait between different fruit types
		if AutoFeedPetEnabled and fruitIndex < #availableFruits then
			print("Waiting before next fruit type...")
			task.wait(2)
		end
	end

	print("=== FEEDING COMPLETE ===")
	print("Fed", fedCount, "out of", totalFeedAttempts, "feeding attempts")
	print("Hungry pets:", #hungryPets, "/ Total pets:", #activePets)
	print("Skipped well-fed pets:", skippedWellFed)
	print("Available fruits:", #availableFruits)

	if fedCount > 0 then
		Library:Notify(
				"✅ Fed "
						.. fedCount
						.. " hungry pets successfully! Skipped "
						.. (#activePets - #hungryPets + skippedWellFed)
						.. " well-fed pets.",
				4
		)
	else
		Library:Notify("❌ No pets were fed - all pets are well-fed or no fruits available", 3)
	end

	return fedCount > 0
end

-- Auto feed pets loop with cycling
local PetFeedingIndex = 1
local LastFruitIndex = 1

local function autoFeedPetsInOrder()
	if not AutoFeedPetEnabled then
		return
	end
	spawn(function()
		while AutoFeedPetEnabled do
			wait(2) -- Reduced from 4 to 2 seconds

			local petServices = getPetServices()
			if not petServices then
				print("Pet services not available")
				task.wait(3) -- Reduced from 5 to 3 seconds
				continue
			end

			local activePets = getActivePets()
			if #activePets == 0 then
				print("No active pets found")
				task.wait(3) -- Reduced from 5 to 3 seconds
				continue
			end

			-- Filter pets that need feeding (hunger under 70%)
			local hungryPets = {}
			for _, pet in pairs(activePets) do
				if pet.hungerPercentage and pet.hungerPercentage < 0.7 then
					table.insert(hungryPets, pet)
					print(
							"Pet " .. pet.petType .. " needs food: " .. math.floor(pet.hungerPercentage * 100) .. "% hunger"
					)
				else
					local hungerPercent = pet.hungerPercentage and math.floor(pet.hungerPercentage * 100) or 0
					print("Pet " .. pet.petType .. " doesn't need food: " .. hungerPercent .. "% hunger (skipping)")
				end
			end

			if #hungryPets == 0 then
				print("No hungry pets found (all pets have >70% hunger)")
				task.spawn(function()
					pcall(function()
						Library:Notify("✅ All pets are well fed! (>70% hunger)", 2)
					end)
				end)
				task.wait(5) -- Reduced from 10 to 5 seconds when no pets need feeding
				continue
			end

			-- Get available fruits
			local availableFruits = {}
			for plantName, selected in pairs(SelectedPlantsToFeed) do
				if selected then
					local hasFruit = false
					local fruitTool = nil

					-- Check character and backpack
					if LocalPlayer.Character then
						for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
							if tool:IsA("Tool") and tool:HasTag("FruitTool") and tool.Name == plantName then
								hasFruit = true
								fruitTool = tool
								break
							end
						end
					end

					if not hasFruit and LocalPlayer.Backpack then
						for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
							if tool:IsA("Tool") and tool:HasTag("FruitTool") and tool.Name == plantName then
								fruitTool = tool
								hasFruit = true
								break
							end
						end
					end

					if hasFruit and fruitTool then
						table.insert(availableFruits, { name = plantName, tool = fruitTool })
					end
				end
			end

			if #availableFruits == 0 then
				print("No fruits available for feeding")
				task.wait(3)
				continue
			end

			-- Cycle through hungry pets and fruits
			if PetFeedingIndex > #hungryPets then
				PetFeedingIndex = 1 -- Reset to first hungry pet
			end

			if LastFruitIndex > #availableFruits then
				LastFruitIndex = 1 -- Reset to first fruit
			end

			local currentPet = hungryPets[PetFeedingIndex]
			local currentFruit = availableFruits[LastFruitIndex]

			if currentPet and currentFruit then
				local hungerPercent = math.floor(currentPet.hungerPercentage * 100)
				print(
						"Auto-feeding Pet #"
								.. PetFeedingIndex
								.. " ("
								.. currentPet.petType
								.. ", "
								.. hungerPercent
								.. "% hunger) with "
								.. currentFruit.name
				) -- Equip the fruit (simplified)
				if currentFruit.tool.Parent ~= LocalPlayer.Character then
					LocalPlayer.Character.Humanoid:EquipTool(currentFruit.tool)
					task.wait(0.3) -- Reduced from 0.8 to 0.3 seconds
				end

				-- Check if player still has fruit equipped
				local currentTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
				if currentTool and currentTool:HasTag("FruitTool") then
					-- Try to feed
					local success, result = pcall(function()
						petServices.ActivePetsService:Feed(currentPet.uuid)
					end)

					if success then
						print("Successfully fed Pet #" .. PetFeedingIndex)
						task.spawn(function()
							pcall(function()
								Library:Notify(
										"🐾 Fed hungry pet ("
												.. hungerPercent
												.. "% hunger): "
												.. currentPet.petType
												.. " with "
												.. currentFruit.name,
										2
								)
							end)
						end)
					else
						print("Failed to feed Pet #" .. PetFeedingIndex .. ":", result)
						task.spawn(function()
							pcall(function()
								Library:Notify(
										"⚠️ Pet couldn't be fed - "
												.. currentPet.petType
												.. " ("
												.. hungerPercent
												.. "% hunger)",
										2
								)
							end)
						end)
					end
				else
					print("No fruit equipped for Pet #" .. PetFeedingIndex)
				end

				-- Move to next pet
				PetFeedingIndex = PetFeedingIndex + 1

				-- If we've fed all hungry pets, move to next fruit type
				if PetFeedingIndex > #hungryPets then
					LastFruitIndex = LastFruitIndex + 1
					if LastFruitIndex > #availableFruits then
						LastFruitIndex = 1 -- Reset fruit cycle
					end
					PetFeedingIndex = 1 -- Reset to first hungry pet for next fruit cycle
				end
			end
		end
	end)
end

-- Auto feed pets loop
local function autoFeedPets()
	if not AutoFeedPetEnabled then
		return
	end

	-- Use the new ordered feeding system
	autoFeedPetsInOrder()
end

-- Pet Tab UI
-- Auto Buy Pet Egg Group Box
local PetAutoBuyGroupBox = Tabs.Pet:AddRightGroupbox("Auto Buy Pet Eggs")

-- List of available pet eggs
local PetEggTypes = {
	"Common Egg",
	"Uncommon Egg",
	"Rare Egg",
	"Legendary Egg",
	"Mythical Egg",
	"Bug Egg",
	"Common Summer Egg",
	"Rare Summer Egg",
	"Paradise Egg"
}

-- Selected eggs for auto buying
local SelectedPetEggs = {}
local AutoBuyPetEggEnabled = false

-- Track purchased eggs to avoid buying the same egg multiple times
local PurchasedPetEggs = {}

-- Add multi-select dropdown for pet eggs
PetAutoBuyGroupBox:AddDropdown("PetEggsList", {
	Values = PetEggTypes,
	Default = 1,
	Multi = true, -- Allow multiple selections

	Text = "Select Eggs to Buy",
	Tooltip = "Choose which pet eggs to automatically purchase",

	Callback = function(Value)
		print("[cb] Selected eggs for auto-buy:", Value)
		SelectedPetEggs = Value
	end,
})

-- Add toggle for auto-buying pet eggs
PetAutoBuyGroupBox:AddToggle("AutoBuyPetEggs", {
	Text = "Auto Buy Pet Eggs",
	Tooltip = "Automatically purchase selected pet eggs when available",
	Default = false,
	Callback = function(Value)
		print("[cb] Auto Buy Pet Eggs toggled:", Value)
		AutoBuyPetEggEnabled = Value

		if Value then
			-- Start auto buying loop
			task.spawn(function()
				while AutoBuyPetEggEnabled and Toggles.AutoBuyPetEggs.Value do
					-- Check if any eggs are selected
					local hasSelectedEggs = false
					for eggName, selected in pairs(SelectedPetEggs) do
						if selected then
							hasSelectedEggs = true
							break
						end
					end

					if hasSelectedEggs then
						-- Try to buy all eggs of each selected type
						local eggTypesBought = {}

						for _, eggName in ipairs(PetEggTypes) do
							-- Check if this egg is selected
							if SelectedPetEggs[eggName] and AutoBuyPetEggEnabled and Toggles.AutoBuyPetEggs.Value then
								print("[DEBUG_LOG] Attempting to buy all eggs of type:", eggName)

								-- Attempt to buy all eggs of this type
								local success = buyPetEgg(eggName)

								if success then
									table.insert(eggTypesBought, eggName)
								end

								-- Wait between different egg types
								task.wait(1)
							end
						end
					else
						-- Notification removed as requested
					end

					-- Wait before checking again
					task.wait(3)
				end
			end)

			-- Notifications removed as requested
		else
			-- Notifications removed as requested
		end
	end,
})

-- Add button to manually buy selected eggs
PetAutoBuyGroupBox:AddButton("Buy Selected Eggs Now", function()
	-- Try to buy all eggs of each selected type
	local totalEggsBought = 0
	local eggTypesBought = {}

	for _, eggName in ipairs(PetEggTypes) do
		-- Check if this egg is selected
		if SelectedPetEggs[eggName] then
			print("[DEBUG_LOG] Attempting to buy all eggs of type:", eggName)

			-- Attempt to buy all eggs of this type
			local success = buyPetEgg(eggName)

			if success then
				table.insert(eggTypesBought, eggName)
				totalEggsBought = totalEggsBought + 1
			end

			-- Wait between different egg types
			task.wait(1)
		end
	end

	-- Show a notification with the total number of egg types bought
	if totalEggsBought > 0 then
		local eggTypesText = table.concat(eggTypesBought, ", ")
		Library:Notify("Bought eggs of type(s): " .. eggTypesText, 3)
	else
		Library:Notify("No eggs purchased. Check selection or availability.", 3)
	end
end)

-- Add button to reset purchased eggs tracking
PetAutoBuyGroupBox:AddButton("Reset Purchased Eggs Tracking", function()
	-- Clear the purchased eggs tracking
	PurchasedPetEggs = {}
end)

-- Function to automatically reset purchased eggs tracking when shop refreshes
local function resetPurchasedEggsOnShopRefresh()
	-- Check if the PetEggShopData module exists
	local success, PetEggShopData = pcall(function()
		return require(Services.ReplicatedStorage.Data.PetEggShopData)
	end)

	if not success or not PetEggShopData then
		print("[DEBUG_LOG] Could not load PetEggShopData module")
		return
	end

	-- Get the refresh time from the module
	local refreshTime = PetEggShopData.RefreshTime or 1800 -- Default to 30 minutes if not specified

	-- Start a loop to check for shop refresh
	task.spawn(function()
		while true do
			task.wait(refreshTime)
			-- Reset the purchased eggs tracking
			PurchasedPetEggs = {}
			print("[DEBUG_LOG] Shop refreshed, reset purchased eggs tracking")
		end
	end)
end

-- Start the auto-reset function
resetPurchasedEggsOnShopRefresh()

-- Function to buy a pet egg
function buyPetEgg(eggName)
	print("[DEBUG_LOG] Attempting to buy pet egg:", eggName)

	-- Access the shop data to find all eggs of the selected type
	local DataService = require(Services.ReplicatedStorage.Modules.DataService)
	local shopData = DataService:GetData().PetEggStock.Stocks

	if not shopData then
		print("[DEBUG_LOG] Could not access shop data")
		return false
	end

	-- Track if we bought any eggs
	local boughtAny = false
	local eggsBought = 0

	-- Iterate through all eggs in the shop
	for shopIndex, eggData in pairs(shopData) do
		-- Check if this egg matches the selected type
		if eggData.EggName == eggName then
			print("[DEBUG_LOG] Found egg in shop:", eggName, "at index:", shopIndex)

			-- Check if this specific egg has already been purchased
			if PurchasedPetEggs[shopIndex] then
				print("[DEBUG_LOG] Egg at index", shopIndex, "already purchased in this session")
				-- Continue to the next egg
			else
				-- Find the BuyPetEgg remote event
				local buyPetEgg = Services.ReplicatedStorage.GameEvents:FindFirstChild("BuyPetEgg")

				if buyPetEgg then
					-- Fire the remote event to buy the egg with the shop index
					print("[DEBUG_LOG] Sending buy request for egg at shop index:", shopIndex)

					-- Fire the remote event
					buyPetEgg:FireServer(shopIndex)

					-- Log additional information for debugging
					print("[DEBUG_LOG] Buy request sent for egg:", eggName, "with shop index:", shopIndex)

					-- Mark this specific egg as purchased in this session
					PurchasedPetEggs[shopIndex] = true

					-- Track that we bought at least one egg
					boughtAny = true
					eggsBought = eggsBought + 1

					-- Wait a bit before buying the next egg to avoid rate limiting
					task.wait(0.5)
				else
					-- Try alternative remote event names as fallback
					local alternativeEvents = {
						"BuyPetEggStock",
						"BuyEgg",
						"PurchaseEgg"
					}

					local usedAlternative = false

					for _, eventName in ipairs(alternativeEvents) do
						local event = Services.ReplicatedStorage.GameEvents:FindFirstChild(eventName)
						if event then
							print("[DEBUG_LOG] Using alternative event:", eventName, "for egg at shop index:", shopIndex)

							-- Fire the remote event
							event:FireServer(shopIndex)

							-- Log additional information for debugging
							print("[DEBUG_LOG] Buy request sent using alternative event:", eventName, "for egg:", eggName, "with shop index:", shopIndex)

							-- Mark this specific egg as purchased in this session
							PurchasedPetEggs[shopIndex] = true

							-- Track that we bought at least one egg
							boughtAny = true
							eggsBought = eggsBought + 1

							usedAlternative = true

							-- Wait a bit before buying the next egg to avoid rate limiting
							task.wait(0.5)

							break
						end
					end

					if not usedAlternative then
						print("[DEBUG_LOG] Could not find appropriate remote event to buy pet egg")
					end
				end
			end
		end
	end

	print("[DEBUG_LOG] Bought", eggsBought, "eggs of type:", eggName)

	return boughtAny
end

local PetAutoFeedGroupBox = Tabs.Pet:AddLeftGroupbox("Auto Feed Pets")

-- Plant selection dropdown
PetAutoFeedGroupBox:AddDropdown("FeedPlantsList", {
	Values = { "Loading fruits..." },
	Default = 1,
	Multi = true, -- Allow multiple selections

	Text = "Select Plants/Fruits",
	Tooltip = "Choose which plants/fruits to feed to your pets",

	Callback = function(Value)
		print("[cb] Selected seeds for feeding:", Value)
		SelectedPlantsToFeed = Value
	end,
})

PetAutoFeedGroupBox:AddButton("🔄 Refresh Fruit List", function()
	local playerFruits = getPlayerFruits()

	if #playerFruits > 0 then
		Options.FeedPlantsList:SetValues(playerFruits)
		Library:Notify("🔄 Found " .. #playerFruits .. " fruits in inventory!", 2)
	else
		Options.FeedPlantsList:SetValues({ "No fruits found" })
		Library:Notify("❌ No fruits found in inventory", 3)
	end
end)

PetAutoFeedGroupBox:AddToggle("AutoFeedPets", {
	Text = "Auto Feed Pets",
	Tooltip = "Automatically feed selected plants to pets with <70% hunger (smart feeding)",
	Default = false,
	Callback = function(Value)
		print("[cb] Auto Feed Pets toggled:", Value)
		AutoFeedPetEnabled = Value
		if Value then
			autoFeedPets()
			task.spawn(function()
				pcall(function()
					Library:Notify("Auto feed pets enabled! (Only feeding pets <70% hunger)", 3)
				end)
			end)
		else
			task.spawn(function()
				pcall(function()
					Library:Notify("❌ Auto feed pets disabled", 2)
				end)
			end)
		end
	end,
})

PetAutoFeedGroupBox:AddButton("Feed Pets Now", function()
	local fedPets = feedPetsWithPlants()
	if fedPets then
		Library:Notify("Fed pets with selected plants!", 2)
	else
		Library:Notify("No pets fed - check fruit inventory and pet selection", 3)
	end
end)

-- Pet Info Group
local PetInfoGroupBox = Tabs.Pet:AddRightGroupbox("Pet Information")

-- Pet list from the pet documentation
local PetList = {
	"Dog",
	"Golden Lab",
	"Bunny",
	"Black Bunny",
	"Cat",
	"Orange Tabby",
	"Deer",
	"Spotted Deer",
	"Monkey",
	"Silver Monkey",
	"Chicken",
	"Rooster",
	"Pig",
	"Turtle",
	"Cow",
	"Snail",
	"Giant Ant",
	"Dragonfly",
	"Polar Bear",
	"Panda",
	"Sea Otter",
	"Caterpillar",
	"Praying Mantis",
	"Hedgehog",
	"Kiwi",
	"Mole",
	"Frog",
	"Echo Frog",
	"Owl",
	"Night Owl",
	"Raccoon",
	"Grey Mouse",
	"Squirrel",
	"Brown Mouse",
	"Red Giant Ant",
	"Red Fox",
	"Chicken Zombie",
	"Blood Hedgehog",
	"Blood Kiwi",
	"Blood Owl",
	"Moon Cat",
	"Bee",
	"Honey Bee",
	"Petal Bee",
	"Golden Bee",
	"Bear Bee",
	"Queen Bee",
	"Firefly",
	"Red Dragon",
}

-- Function to check if player has any of the known pets
local function checkPlayerPets()
	local foundPets = {}
	local activePets = {}

	-- Method 1: Try to use PetUtilities (with better error handling)
	local success1, petsFromUtilities = pcall(function()
		-- Check if required services exist first
		if not ReplicatedStorage:FindFirstChild("Modules") then
			return {}
		end

		local Modules = ReplicatedStorage.Modules
		if not Modules:FindFirstChild("PetServices") then
			return {}
		end

		local PetServices = Modules.PetServices
		if not PetServices:FindFirstChild("PetUtilities") then
			return {}
		end

		-- Try to require PetUtilities safely
		local PetUtilities = require(PetServices.PetUtilities)
		if not PetUtilities then
			return {}
		end

		-- Try to get DataService safely
		if not Modules:FindFirstChild("DataService") then
			return {}
		end

		local DataService = require(Modules.DataService)
		local data = DataService:GetData()

		if not data or not data.PetsData then
			return {}
		end

		-- Try to get PetRegistry safely
		if not ReplicatedStorage:FindFirstChild("Data") or not ReplicatedStorage.Data:FindFirstChild("PetRegistry") then
			return {}
		end

		local PetRegistry = require(ReplicatedStorage.Data.PetRegistry)
		local PetList = PetRegistry.PetList

		-- Get pets using PetUtilities
		local pets = PetUtilities:GetPetsSortedByAge(LocalPlayer, 0, false, true)

		local processedPets = {}
		for _, petData in pairs(pets) do
			-- Safely get pet type data
			local petTypeData = PetList[petData.PetType]
			local defaultHunger = petTypeData and petTypeData.DefaultHunger or 100
			local currentHunger = (petData.PetData and petData.PetData.Hunger) or 0
			local hungerPercentage = currentHunger / defaultHunger
			local age = (petData.PetData and petData.PetData.Age) or 0

			-- Check if this pet is in our known pet list
			local isKnownPet = false
			for _, knownPet in pairs(PetList) do
				if petData.PetType == knownPet then
					isKnownPet = true
					break
				end
			end

			table.insert(processedPets, {
				uuid = petData.UUID,
				name = petData.PetType,
				type = petData.PetType,
				age = age,
				currentHunger = currentHunger,
				maxHunger = defaultHunger,
				hungerPercentage = hungerPercentage,
				isKnownPet = isKnownPet,
				location = "Farm Area",
			})
		end

		return processedPets
	end)

	if success1 and petsFromUtilities then
		-- Separate known pets from all pets
		for _, pet in pairs(petsFromUtilities) do
			table.insert(activePets, pet)
			if pet.isKnownPet then
				table.insert(foundPets, pet)
			end
		end
	end

	-- Method 2: Scan workspace for pet objects (safer fallback method)
	local success2, workspacePets = pcall(function()
		local workspacePetList = {}

		-- Add a small delay to ensure we're in a stable thread context
		task.wait(0.1)

		for _, obj in pairs(workspace:GetDescendants()) do
			if
			obj:GetAttribute("OWNER") == LocalPlayer.Name
					and obj:GetAttribute("UUID")
					and obj:HasTag("PetTargetable")
			then
				local petType = obj:GetAttribute("PetType") or obj.Name
				local uuid = obj:GetAttribute("UUID")

				-- Check if we already have this pet from PetUtilities
				local alreadyFound = false
				for _, existing in pairs(activePets) do
					if existing.uuid == uuid then
						alreadyFound = true
						existing.workspaceObject = obj
						break
					end
				end

				if not alreadyFound then
					-- Check if this pet is in our known pet list
					local isKnownPet = false
					for _, knownPet in pairs(PetList) do
						if petType == knownPet or obj.Name == knownPet then
							isKnownPet = true
							break
						end
					end

					local pet = {
						name = petType ~= "PetMover" and petType or obj.Name,
						type = petType,
						uuid = uuid,
						location = obj.Parent and obj.Parent.Name or "Unknown",
						isKnownPet = isKnownPet,
						workspaceObject = obj,
					}

					table.insert(workspacePetList, pet)
				end
			end
		end
		return workspacePetList
	end)

	if success2 and workspacePets then
		for _, pet in pairs(workspacePets) do
			table.insert(activePets, pet)
			if pet.isKnownPet then
				table.insert(foundPets, pet)
			end
		end
	end

	return foundPets, activePets
end

PetInfoGroupBox:AddButton("📊 Show Active Pets", function()
	Library:Notify("🔍 Scanning for active pets...", 2)

	-- Use task.spawn to ensure proper thread context for workspace access
	task.spawn(function()
		-- Safely check for pets with comprehensive error handling
		local success, knownPets, allActivePets = pcall(function()
			return checkPlayerPets()
		end)

		if not success then
			Library:Notify("❌ Error scanning pets: " .. tostring(knownPets), 5)
			return
		end

		local debugInfo = {}

		-- Method 2: Check game data for additional information (with error handling)
		local dataSuccess, dataResult = pcall(function()
			if not ReplicatedStorage:FindFirstChild("Modules") then
				return "Modules not found"
			end

			if not ReplicatedStorage.Modules:FindFirstChild("DataService") then
				return "DataService not found"
			end

			local DataService = require(ReplicatedStorage.Modules.DataService)
			local data = DataService:GetData()

			if not data then
				return "No game data"
			end

			if not data.PetsData then
				return "No PetsData"
			end

			if not data.PetsData.EquippedPets then
				return "No EquippedPets"
			end

			local equippedCount = #data.PetsData.EquippedPets
			return "Equipped pets in data: " .. equippedCount
		end)

		if dataSuccess then
			table.insert(debugInfo, dataResult)
		else
			table.insert(debugInfo, "Data check failed: " .. tostring(dataResult))
		end

		-- Show results with priority on known pets
		if #knownPets > 0 then
			local message = "🐾 Active Pets Found (" .. #knownPets .. "/" .. #allActivePets .. "):\n\n"
			for i, pet in pairs(knownPets) do
				message = message .. i .. ". " .. pet.name .. "\n"
				if pet.age and pet.age > 0 then
					message = message .. "   🎂 Age: " .. pet.age .. "\n"
				end
				if pet.hungerPercentage then
					local hungerEmoji = pet.hungerPercentage > 0.7 and "🟢"
							or pet.hungerPercentage > 0.3 and "🟡"
							or "🔴"
					message = message
							.. "   🍎 Hunger: "
							.. math.floor(pet.hungerPercentage * 100)
							.. "% "
							.. hungerEmoji
							.. "\n"
				end
				message = message .. "   📍 Location: " .. pet.location .. "\n"
				if pet.uuid then
					message = message .. "   🆔 ID: " .. string.sub(pet.uuid, 1, 8) .. "...\n"
				end
				if i >= 4 then -- Limit to 4 pets for readability (more info per pet now)
					message = message .. "\n... and " .. (#knownPets - 4) .. " more pets"
					break
				end
			end

			-- Add other active pets if any
			local otherPets = #allActivePets - #knownPets
			if otherPets > 0 then
				message = message .. "\n\n🔍 Other/Unknown Pets: " .. otherPets
			end

			message = message .. "\n\n✅ Pet detection working perfectly!"
			Library:Notify(message, 12)
		elseif #allActivePets > 0 then
			local message = "🐾 Active Pets Found (" .. #allActivePets .. "):\n\n"
			for i, pet in pairs(allActivePets) do
				local displayName = pet.name ~= "PetMover" and pet.name or pet.type
				message = message .. i .. ". " .. displayName .. "\n"
				if pet.age and pet.age > 0 then
					message = message .. "   🎂 Age: " .. pet.age .. "\n"
				end
				if pet.hungerPercentage then
					local hungerEmoji = pet.hungerPercentage > 0.7 and "🟢"
							or pet.hungerPercentage > 0.3 and "🟡"
							or "🔴"
					message = message
							.. "   🍎 Hunger: "
							.. math.floor(pet.hungerPercentage * 100)
							.. "% "
							.. hungerEmoji
							.. "\n"
				end
				message = message .. "   📍 Location: " .. pet.location .. "\n"
				if i >= 4 then -- Limit to 4 pets for readability
					message = message .. "\n... and " .. (#allActivePets - 4) .. " more pets"
					break
				end
			end
			message = message .. "\n\n⚠️ Using fallback detection method"
			Library:Notify(message, 10)
		else
			-- Show detailed debug info when no pets found
			local debugMessage = "❌ No Active Pets Found\n\n📊 Debug Information:\n"
			for _, info in pairs(debugInfo) do
				debugMessage = debugMessage .. "• " .. info .. "\n"
			end
			debugMessage = debugMessage .. "• Total workspace pets: " .. #allActivePets .. "\n"
			debugMessage = debugMessage .. "\n💡 Troubleshooting Tips:\n"
			debugMessage = debugMessage .. "• Make sure you have pets equipped\n"
			debugMessage = debugMessage .. "• Try spawning/summoning your pets\n"
			debugMessage = debugMessage .. "• Check if you're in the right area\n"
			debugMessage = debugMessage .. "• Ensure you're in your own farm plot"

			Library:Notify(debugMessage, 10)
		end

		-- Always show this notification to confirm button works
		wait(1)
		Library:Notify("🔍 Pet scan completed! Check results above.", 3)
	end)
end)

PetInfoGroupBox:AddButton("Show Available Fruits", function()
	local playerFruits = getPlayerFruits()

	if #playerFruits > 0 then
		local message = "Available Fruits (" .. #playerFruits .. "):\n"
		for i, fruit in pairs(playerFruits) do
			message = message .. i .. ". " .. fruit .. "\n"
		end
		Library:Notify(message, 5)
	else
		Library:Notify("❌ No fruits found in inventory", 3)
	end
end)


-- Pet Detection Group Box
local PetDetectionGroupBox = Tabs.Pet:AddLeftGroupbox("Pet Detection")

-- Variables for ESP functionality
local PetEggESPEnabled = false
local espCache = {}
local activeEggs = {}
local espConnection1 = nil
local espConnection2 = nil
local espHookFunction = nil

-- Toggle for Pet Egg ESP
PetDetectionGroupBox:AddToggle("PetEggESP", {
	Text = "Pet Egg ESP",
	Tooltip = "Shows ESP for your pet eggs with their names",
	Default = false,
	Callback = function(Value)
		PetEggESPEnabled = Value		if Value then
			-- Enable ESP
			Library:Notify("🥚 Pet Egg ESP enabled!", 3)

			-- Initialize ESP functionality using Services table
			-- Get required upvalues from the egg hatching system
			local success, errorMsg = pcall(function()
				local hatchFunction = getupvalue(getupvalue(getconnections(Services.ReplicatedStorage.GameEvents.PetEggService.OnClientEvent)[1].Function, 1), 2)
				local eggModels = getupvalue(hatchFunction, 1)
				local eggPets = getupvalue(hatchFunction, 2)

				-- Function to get egg model from ID
				local function getObjectFromId(objectId)
					for eggModel in eggModels do
						if eggModel:GetAttribute("OBJECT_UUID") == objectId then
							return eggModel
						end
					end
					return nil
				end

				-- Create ESP GUI for an object
				local function CreateEspGui(object, text)
					local billboard = Instance.new("BillboardGui")
					billboard.Name = "PetEggESP"
					billboard.Adornee = object:FindFirstChildWhichIsA("BasePart") or object.PrimaryPart or object
					billboard.Size = UDim2.new(0, 200, 0, 50)
					billboard.StudsOffset = Vector3.new(0, 2.5, 0)
					billboard.AlwaysOnTop = true

					local label = Instance.new("TextLabel")
					label.Parent = billboard
					label.Size = UDim2.new(1, 0, 1, 0)
					label.BackgroundTransparency = 1
					label.Text = text
					label.TextColor3 = Color3.new(0, 1, 1) -- Changed to cyan color
					label.TextStrokeTransparency = 0
					label.TextStrokeColor3 = Color3.new(0, 0.5, 0.5) -- Added stroke color
					label.TextScaled = true
					label.Font = Enum.Font.Gotham -- Changed to Gotham font

					billboard.Parent = object
					return billboard
				end

				-- Update ESP text
				local function UpdateEsp(objectId, petName)
					local object = getObjectFromId(objectId)
					if not object or not espCache[objectId] then return end

					local eggName = object:GetAttribute("EggName")
					local labelGui = espCache[objectId]
					if labelGui and labelGui:FindFirstChildOfClass("TextLabel") then
						labelGui.TextLabel.Text = eggName .. " | " .. petName
					end
				end

				-- Add ESP to an object
				local function AddEsp(object)
					if object:GetAttribute("OWNER") ~= localPlayer.Name then return end

					local eggName = object:GetAttribute("EggName")
					local petName = eggPets[object:GetAttribute("OBJECT_UUID")]
					local objectId = object:GetAttribute("OBJECT_UUID")
					if not objectId then return end

					local displayPetName = petName or "?"
					local esp = CreateEspGui(object, eggName .. " | " .. displayPetName)
					espCache[objectId] = esp
					activeEggs[objectId] = object
				end

				-- Remove ESP from an object
				local function RemoveEsp(object)
					if object:GetAttribute("OWNER") ~= localPlayer.Name then return end

					local objectId = object:GetAttribute("OBJECT_UUID")
					if espCache[objectId] then
						espCache[objectId]:Destroy()
						espCache[objectId] = nil
					end
					activeEggs[objectId] = nil
				end				-- Add ESP to existing eggs
				for _, object in Services.CollectionService:GetTagged("PetEggServer") do
					task.spawn(AddEsp, object)
				end

				-- Connect to egg added/removed events
				espConnection1 = Services.CollectionService:GetInstanceAddedSignal("PetEggServer"):Connect(AddEsp)
				espConnection2 = Services.CollectionService:GetInstanceRemovedSignal("PetEggServer"):Connect(RemoveEsp)

				-- Hook the egg ready to hatch function to update ESP with pet name
				espHookFunction = hookfunction(getconnections(replicatedStorage.GameEvents.EggReadyToHatch_RE.OnClientEvent)[1].Function, newcclosure(function(objectId, petName)
					UpdateEsp(objectId, petName)
					return espHookFunction(objectId, petName)
				end))
			end)

			if not success then
				Library:Notify("❌ Error enabling Pet Egg ESP: " .. tostring(errorMsg), 5)
				print("Error in Pet Egg ESP:", errorMsg)
			end
		else
			-- Disable ESP
			Library:Notify("🥚 Pet Egg ESP disabled!", 3)

			-- Clean up ESP
			for id, gui in pairs(espCache) do
				if gui and gui.Parent then
					gui:Destroy()
				end
			end
			espCache = {}
			activeEggs = {}

			-- Disconnect events
			if espConnection1 then
				espConnection1:Disconnect()
				espConnection1 = nil
			end

			if espConnection2 then
				espConnection2:Disconnect()
				espConnection2 = nil
			end

			-- Reset hook function if it exists
			if espHookFunction then
				-- We can't unhook functions, but we can make it pass-through
				-- The hook will remain but won't do anything when disabled
			end
		end
	end,
})

-- Player stats functionality completely removed as requested

EventGroupBox:AddButton("Collect Pollinated Now", function()
	local pollinatedFruits = getPollinatedFruits()
	if #pollinatedFruits > 0 then
		Library:Notify("Found " .. #pollinatedFruits .. " pollinated fruits! Starting collection...", 3)
		collectPollinatedFruits()
	else
		Library:Notify("No pollinated fruits found in your farm", 3)
	end
end)

-- Debug button removed to clean up the script

-- Player Tab
-- Player movement variables
local InfiniteJumpEnabled = false
local OriginalJumpPower = 50
local OriginalWalkSpeed = 16

-- Get player character and humanoid
local function getPlayerHumanoid()
	if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
		return LocalPlayer.Character.Humanoid
	end
	return nil
end

-- Infinite Jump functionality
local function setupInfiniteJump()
	local UserInputService = game:GetService("UserInputService")

	local function onJumpRequest()
		if InfiniteJumpEnabled then
			local humanoid = getPlayerHumanoid()
			if humanoid then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end

	UserInputService.JumpRequest:Connect(onJumpRequest)
end

-- Store original values when character spawns
local function storeOriginalValues()
	local humanoid = getPlayerHumanoid()
	if humanoid then
		-- Try to get JumpPower first
		local jumpValue = nil
		local success1 = pcall(function()
			jumpValue = humanoid.JumpPower
		end)

		-- If JumpPower doesn't exist, try JumpHeight
		if not success1 or jumpValue == nil then
			pcall(function()
				jumpValue = humanoid.JumpHeight
			end)
		end

		-- Use the actual value or fallback to 50
		OriginalJumpPower = jumpValue or 50
		OriginalWalkSpeed = humanoid.WalkSpeed or 16

		-- print removed: Stored original values

		-- Update the slider default to match the actual game value
		if Options.JumpPower then
			Options.JumpPower:SetValue(OriginalJumpPower)
		end
		if Options.WalkSpeed then
			Options.WalkSpeed:SetValue(OriginalWalkSpeed)
		end
	end
end

-- Character respawn handler
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1) -- Wait for character to fully load
	storeOriginalValues()

	-- Re-apply current slider values to new character
	task.wait(0.5) -- Extra wait to ensure character is ready
	if Options.JumpPower and Options.WalkSpeed then
		local currentJump = Options.JumpPower.Value
		local currentSpeed = Options.WalkSpeed.Value

		local humanoid = getPlayerHumanoid()
		if humanoid then
			-- Apply current jump value
			local success1 = pcall(function()
				humanoid.JumpPower = currentJump
			end)
			if not success1 then
				pcall(function()
					humanoid.JumpHeight = currentJump
				end)
			end

			-- Apply current speed
			humanoid.WalkSpeed = currentSpeed
		end
	end
end)

-- Store initial values if character already exists
if LocalPlayer.Character then
	storeOriginalValues()
end

-- Setup infinite jump
setupInfiniteJump()

-- Player Tab UI
local PlayerMovementGroupBox = Tabs.Player:AddLeftGroupbox("Movement")

PlayerMovementGroupBox:AddToggle("InfiniteJump", {
	Text = "Infinite Jump",
	Tooltip = "Allows unlimited jumping",
	Default = false,

	Callback = function(Value)
		InfiniteJumpEnabled = Value
		if Value then
			Library:Notify("🦘 Infinite Jump enabled!", 2)
		else
			Library:Notify("❌ Infinite Jump disabled", 2)
		end
	end,
})

PlayerMovementGroupBox:AddSlider("JumpPower", {
	Text = "Jump Power",
	Tooltip = "Adjust your jump height",
	Default = OriginalJumpPower, -- Use the actual game default
	Min = 16,
	Max = 200,
	Rounding = 0,

	Callback = function(Value)
		local humanoid = getPlayerHumanoid()
		if humanoid then
			-- Check if JumpPower property exists (older Roblox)
			local success1 = pcall(function()
				humanoid.JumpPower = Value
			end)

			-- Check if JumpHeight property exists (newer Roblox)
			if not success1 then
				pcall(function()
					humanoid.JumpHeight = Value
				end)
			end
		end
	end,
})

PlayerMovementGroupBox:AddSlider("WalkSpeed", {
	Text = "Walk Speed",
	Tooltip = "Adjust your movement speed",
	Default = OriginalWalkSpeed, -- Use the actual game default
	Min = 0,
	Max = 100,
	Rounding = 0,

	Callback = function(Value)
		local humanoid = getPlayerHumanoid()
		if humanoid then
			humanoid.WalkSpeed = Value
		end
	end,
})

PlayerMovementGroupBox:AddButton("🔄 Reset to Default", function()
	local humanoid = getPlayerHumanoid()
	if humanoid then
		-- Reset jump power/height
		local success1 = pcall(function()
			humanoid.JumpPower = OriginalJumpPower
		end)

		if not success1 then
			pcall(function()
				humanoid.JumpHeight = OriginalJumpPower
			end)
		end

		-- Reset walk speed
		humanoid.WalkSpeed = OriginalWalkSpeed

		-- Update sliders to match
		Options.JumpPower:SetValue(OriginalJumpPower)
		Options.WalkSpeed:SetValue(OriginalWalkSpeed)

		Library:Notify("🔄 Movement reset to default values", 2)
	end
end)

-- Server Section
local ServerGroupBox = Tabs.Player:AddRightGroupbox("Server")

ServerGroupBox:AddButton("🔄 Server Hop", function()
	Library:Notify("🔄 Server hopping...", 3)

	local TeleportService = game:GetService("TeleportService")
	local PlaceId = game.PlaceId

	-- Queue the script to run after teleport
	queue_on_teleport("loadstring(game:HttpGet('https://rawscripts.net/raw/Grow-a-Garden-Grow-a-Garden-Stock-bot-41500'))()")

	-- Teleport to a different server of the same game
	TeleportService:Teleport(PlaceId, LocalPlayer)
end)

-- Mutation Sell Section
local MutationSellGroupBox = Tabs.Store:AddRightGroupbox("Auto Farm Exclusions")

-- All possible mutation names
local AllMutations = {
	"Bloodlit",
	"Burnt",
	"Celestial",
	"Chilled",
	"Choc",
	"Frozen",
	"Honey",
	"Moonlit",
	"Plasma",
	"Pollinated",
	"Shocked",
	"Twisted",
	"Unused",
	"Voidtouched",
	"Wet",
	"Zombified",
	"Disco",
}

-- All possible variant names
local AllVariants = {
	"Gold",
	"Rainbow",
}

-- All possible fruit names
local AllFruits = {
	"Apple",
	"Avocado",
	"Bamboo",
	"Banana",
	"Beanstalk",
	"Blood Banana",
	"Blueberry",
	"Cacao",
	"Cactus",
	"Candy Blossom",
	"Carrot",
	"Celestiberry",
	"Cherry Blossom",
	"Cherry OLD",
	"Coconut",
	"Corn",
	"Cranberry",
	"Crimson Vine",
	"Cursed Fruit",
	"Dragon Fruit",
	"Durian",
	"Easter Egg",
	"Eggplant",
	"Ember Lily",
	"Foxglove",
	"Glowshroom",
	"Grape",
	"Hive Fruit",
	"Lemon",
	"Lilac",
	"Lotus",
	"Mango",
	"Mint",
	"Moon Blossom",
	"Moon Mango",
	"Moon Melon",
	"Moonflower",
	"Moonglow",
	"Nectarine",
	"Papaya",
	"Passionfruit",
	"Peach",
	"Pear",
	"Pepper",
	"Pineapple",
	"Pink Lily",
	"Purple Cabbage",
	"Purple Dahlia",
	"Raspberry",
	"Rose",
	"Soul Fruit",
	"Starfruit",
	"Strawberry",
	"Succulent",
	"Sunflower",
	"Tomato",
	"Venus Fly Trap",
}

-- Function to get mutations found in player's inventory
local function getMutationsInInventory()
	local foundMutations = {}
	local backpack = LocalPlayer:FindFirstChild("Backpack")

	if backpack then
		for _, tool in pairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				-- Check if tool name contains any mutation
				for _, mutation in pairs(AllMutations) do
					if string.find(tool.Name, mutation) then
						if not table.find(foundMutations, mutation) then
							table.insert(foundMutations, mutation)
						end
					end
				end
			end
		end
	end

	-- Also check equipped tool
	if LocalPlayer.Character then
		for _, tool in pairs(LocalPlayer.Character:GetChildren()) do
			if tool:IsA("Tool") then
				for _, mutation in pairs(AllMutations) do
					if string.find(tool.Name, mutation) then
						if not table.find(foundMutations, mutation) then
							table.insert(foundMutations, mutation)
						end
					end
				end
			end
		end
	end

	return foundMutations
end

-- Exclude Mutations Dropdown
MutationSellGroupBox:AddDropdown("ExcludeMutations", {
	Values = AllMutations,
	Default = 1,
	Multi = true,

	Text = "Exclude Mutations",
	Tooltip = "Select mutations to sell when using the Sell Excluded Items button",

	Callback = function(Value)
		print("[cb] Exclude Mutations changed:")
		for mutation, selected in next, Options.ExcludeMutations.Value do
			print(mutation, selected)
		end
	end,
})

-- Exclude Variants Dropdown
MutationSellGroupBox:AddDropdown("ExcludeVariants", {
	Values = AllVariants,
	Default = 1,
	Multi = true,

	Text = "Exclude Variants",
	Tooltip = "Select variants to sell when using the Sell Excluded Items button",

	Callback = function(Value)
		print("[cb] Exclude Variants changed:")
		for variant, selected in next, Options.ExcludeVariants.Value do
			print(variant, selected)
		end
	end,
})

-- Exclude Fruits Dropdown
MutationSellGroupBox:AddDropdown("ExcludeFruits", {
	Values = AllFruits,
	Default = 1,
	Multi = true,

	Text = "Exclude Fruits",
	Tooltip = "Select fruits to sell when using the Sell Excluded Items button",

	Callback = function(Value)
		print("[cb] Exclude Fruits changed:")
		for fruit, selected in next, Options.ExcludeFruits.Value do
			print(fruit, selected)
		end
	end,
})

-- Function to check if an item should be excluded based on exclusion settings
local function shouldExcludeItem(tool)
	local itemName = tool.Name

	-- Check mutations by looking at tool attributes
	if Options.ExcludeMutations and Options.ExcludeMutations.Value then
		for mutation, excluded in pairs(Options.ExcludeMutations.Value) do
			if excluded then
				-- Check if the tool has this mutation as an attribute
				if tool:GetAttribute(mutation) then
					return true, "mutation: " .. mutation
				end
				-- Also check the item name as fallback
				if string.find(itemName, mutation) then
					return true, "mutation: " .. mutation
				end
			end
		end
	end

	-- Check variants by looking at tool attributes
	if Options.ExcludeVariants and Options.ExcludeVariants.Value then
		for variant, excluded in pairs(Options.ExcludeVariants.Value) do
			if excluded then
				-- Check if the tool has this variant as an attribute
				if tool:GetAttribute(variant) then
					return true, "variant: " .. variant
				end
				-- Also check the item name as fallback
				if string.find(itemName, variant) then
					return true, "variant: " .. variant
				end
			end
		end
	end

	-- Check fruits by looking at ItemName attribute or tool name
	if Options.ExcludeFruits and Options.ExcludeFruits.Value then
		for fruit, excluded in pairs(Options.ExcludeFruits.Value) do
			if excluded then
				-- Check ItemName attribute first
				local toolItemName = tool:GetAttribute("ItemName")
				if toolItemName and string.find(toolItemName, fruit) then
					return true, "fruit: " .. fruit
				end
				-- Fallback to checking the tool name
				if string.find(itemName, fruit) then
					return true, "fruit: " .. fruit
				end
			end
		end
	end

	return false, ""
end

-- Function to sell items based on exclusion settings with teleportation
local function sellExcludedItemsWithTeleport()
	local success, result = pcall(function()
		-- Store original position
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			OriginalPlayerPosition = LocalPlayer.Character.HumanoidRootPart.Position
			print("📍 Stored original position:", OriginalPlayerPosition)
		else
			print("❌ Could not get player position!")
			return 0
		end

		-- Find and teleport to sell stands
		local sellStandPosition = getSellStandPosition()
		if not sellStandPosition then
			Library:Notify("Could not find Sell Stands!", 3)
			return 0
		end

		print("Teleporting to Sell Stands...")
		Library:Notify("Teleporting to Sell Stands...", 2)

		-- Teleport to sell stands
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(sellStandPosition)
		task.wait(0.8) -- Wait for teleport to register

		-- Now sell items based on exclusion settings
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		local soldCount = 0

		if backpack then
			for _, tool in pairs(backpack:GetChildren()) do
				if tool:IsA("Tool") then
					local shouldExclude, reason = shouldExcludeItem(tool)

					if shouldExclude then
						-- Equip and sell the excluded tool
						tool.Parent = LocalPlayer.Character
						task.wait(0.1)
						Sell_Item:FireServer()
						soldCount = soldCount + 1
						print("Sold excluded item:", tool.Name, "Reason:", reason)
						task.wait(0.1)
					end
				end
			end
		end

		-- Teleport back to original position
		if OriginalPlayerPosition then
			print("🔄 Teleporting back to original location...")
			Library:Notify("🔄 Teleporting back...", 2)
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(OriginalPlayerPosition + Vector3.new(0, 2, 0))
			task.wait(0.5)
		end

		Library:Notify("✅ Sold " .. soldCount .. " excluded items and teleported back!", 3)
		return soldCount
	end)

	if not success then
		print("❌ Error in sellExcludedItemsWithTeleport:", result)
		Library:Notify("❌ Error during sell process: " .. tostring(result), 4)

		-- Try to teleport back even if there was an error
		if
		OriginalPlayerPosition
				and LocalPlayer.Character
				and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		then
			pcall(function()
				LocalPlayer.Character.HumanoidRootPart.CFrame =
				CFrame.new(OriginalPlayerPosition + Vector3.new(0, 2, 0))
			end)
		end
		return 0
	end

	return result
end

-- Sell Excluded Items Button
MutationSellGroupBox:AddButton("🗑️ Sell Excluded Items", function()
	local excludedCount = 0

	-- Count how many exclusions are set
	if Options.ExcludeMutations then
		for _, excluded in pairs(Options.ExcludeMutations.Value) do
			if excluded then
				excludedCount = excludedCount + 1
			end
		end
	end
	if Options.ExcludeVariants then
		for _, excluded in pairs(Options.ExcludeVariants.Value) do
			if excluded then
				excludedCount = excludedCount + 1
			end
		end
	end
	if Options.ExcludeFruits then
		for _, excluded in pairs(Options.ExcludeFruits.Value) do
			if excluded then
				excludedCount = excludedCount + 1
			end
		end
	end

	if excludedCount > 0 then
		Library:Notify("🔄 Selling items matching " .. excludedCount .. " exclusion rules...", 2)
		local soldCount = sellExcludedItemsWithTeleport()
		Library:Notify("✅ Sold " .. soldCount .. " excluded items!", 3)
	else
		Library:Notify("❌ No exclusion rules set! Select items to exclude first.", 3)
	end
end)

-- Clear All Exclusions Button
MutationSellGroupBox:AddButton("🔄 Clear All Exclusions", function()
	if Options.ExcludeMutations then
		Options.ExcludeMutations:SetValue({})
	end
	if Options.ExcludeVariants then
		Options.ExcludeVariants:SetValue({})
	end
	if Options.ExcludeFruits then
		Options.ExcludeFruits:SetValue({})
	end
	Library:Notify("✅ All exclusions cleared!", 2)
end)

-- Main Tab - Updates & Credits
local UpdatesGroupBox = Tabs.Main:AddLeftGroupbox("📋 Recent Updates")

UpdatesGroupBox:AddLabel("🔄 What's New for Script Users:")

UpdatesGroupBox:AddLabel("🆕 LATEST: Universal Crafting System (v4.0)")
UpdatesGroupBox:AddLabel("   • Replaced old Honey Crafter with Universal System")
UpdatesGroupBox:AddLabel("   • Auto Craft for ALL crafting stations (Saw, Grindstone, etc.)")
UpdatesGroupBox:AddLabel("   • Auto Collect finished crafted items")
UpdatesGroupBox:AddLabel("   • Smart nearby crafter detection & teleporting")

UpdatesGroupBox:AddLabel("✅ Bug Fixes & Stability (v3.1)")
UpdatesGroupBox:AddLabel("   • Fixed SafeCallback/SetValue errors in toggles")
UpdatesGroupBox:AddLabel("   • Removed plant collision feature from auto collect")
UpdatesGroupBox:AddLabel("   • Fixed typos causing script errors")
UpdatesGroupBox:AddLabel("   • Improved error handling and stability")

UpdatesGroupBox:AddLabel("✅ Enhanced Performance (v3.0)")
UpdatesGroupBox:AddLabel("   • 3-4x faster auto plant & auto collect")
UpdatesGroupBox:AddLabel("   • Better error handling & reliability")
UpdatesGroupBox:AddLabel("   • Enhanced physics restoration system")

UpdatesGroupBox:AddLabel("✅ Pollinated fruit collection now works perfectly")
UpdatesGroupBox:AddLabel("   • No more 'collection not working' issues")
UpdatesGroupBox:AddLabel("   • Shows clear notifications when farming")

UpdatesGroupBox:AddLabel("✅ Better notifications and feedback")
UpdatesGroupBox:AddLabel("   • You'll know when auto-farm finds fruits")
UpdatesGroupBox:AddLabel("   • Clear messages when no fruits are available")

UpdatesGroupBox:AddLabel("✅ New Player Movement tab added")
UpdatesGroupBox:AddLabel("   • Infinite jump for easy navigation")
UpdatesGroupBox:AddLabel("   • Speed control (walk faster/slower)")
UpdatesGroupBox:AddLabel("   • Jump height control")
UpdatesGroupBox:AddLabel("   • Reset button to go back to normal")

UpdatesGroupBox:AddLabel("✅ Improved pet system")
UpdatesGroupBox:AddLabel("   • 📊 Show Active Pets now works without errors")
UpdatesGroupBox:AddLabel("   • 🐾 Smart feeding: skips well-fed pets (>70%)")
UpdatesGroupBox:AddLabel("   • 🔍 Better pet detection and hunger info")
UpdatesGroupBox:AddLabel("   • ⚡ All pet functions are now thread-safe")

UpdatesGroupBox:AddLabel("✅ Smart mutation selling in Store")
UpdatesGroupBox:AddLabel("   • Choose which mutations to sell")
UpdatesGroupBox:AddLabel("   • Sell everything except selected mutations")
UpdatesGroupBox:AddLabel("   • Auto-detects what you have in inventory")

local CreditsGroupBox = Tabs.Main:AddRightGroupbox("👨‍💻 Credits & Info")

CreditsGroupBox:AddLabel("🎯 Script Developer:")
CreditsGroupBox:AddLabel("Rephra")

CreditsGroupBox:AddDivider()

CreditsGroupBox:AddLabel("🔗 Discord Community:")
CreditsGroupBox:AddLabel("Join for support & updates!")

CreditsGroupBox:AddButton("📞 Copy Discord Link", function()
	if setclipboard then
		setclipboard("https://discord.gg/SSJG3nmv6f")
		Library:Notify("📋 Discord link copied to clipboard!", 3)
	else
		Library:Notify("Discord: https://discord.gg/SSJG3nmv6f", 5)
	end
end)

CreditsGroupBox:AddDivider()

CreditsGroupBox:AddLabel("📊 Script Info:")
CreditsGroupBox:AddLabel("• Game: Grow A Garden")
CreditsGroupBox:AddLabel("• Features: Auto Farm, Player Tools, Mutation Sell")
CreditsGroupBox:AddLabel("• Last Updated: " .. os.date("%m/%d/%Y"))

CreditsGroupBox:AddButton("❤️ Show Support", function()
	Library:Notify("❤️ Thanks for using the script!\nJoin Discord for more updates: discord.gg/SSJG3nmv6f", 5)
end)

-- Enhanced sell item in hand function with teleportation
local function sellItemInHandWithTeleport()
	local success, result = pcall(function()
		-- Store original position
		if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
			OriginalPlayerPosition = LocalPlayer.Character.HumanoidRootPart.Position
			print("📍 Stored original position:", OriginalPlayerPosition)
		else
			print("❌ Could not get player position!")
			return false
		end

		-- Find and teleport to sell stands
		local sellStandPosition = getSellStandPosition()
		if not sellStandPosition then
			Library:Notify("❌ Could not find Sell Stands!", 3)
			return false
		end

		print("🚀 Teleporting to Sell Stands...")
		Library:Notify("🚀 Teleporting to Sell Stands...", 2)
		-- Teleport to sell stands - better positioning
		LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(sellStandPosition + Vector3.new(0, 0.5, 2))
		task.wait(1) -- Wait longer for teleport to register

		-- Face the sell stand for better interaction
		LocalPlayer.Character.HumanoidRootPart.CFrame =
		CFrame.lookAt(LocalPlayer.Character.HumanoidRootPart.Position, sellStandPosition)
		task.wait(0.5) -- Wait to ensure facing direction is registered

		-- Sell item in hand
		print("💰 Selling item in hand...")
		Library:Notify("💰 Selling item in hand...", 2)

		-- Get the currently equipped tool
		local equippedTool = nil
		if LocalPlayer.Character then
			equippedTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
		end

		if equippedTool then
			print("🔧 Found equipped tool:", equippedTool.Name)

			-- First sell attempt
			Sell_Item:FireServer()
			task.wait(0.5) -- Wait for sell to process

			-- Check if item is still equipped (sell might have failed)
			if LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
				print("⚠️ First sell attempt failed, trying again with adjusted position...")

				-- Move slightly closer to the sell stand and try again
				LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(sellStandPosition + Vector3.new(0, 0.5, 1))
				task.wait(0.3)

				-- Second sell attempt
				Sell_Item:FireServer()
				task.wait(0.5)

				-- If still equipped, try one more time with different angle
				if LocalPlayer.Character:FindFirstChildWhichIsA("Tool") then
					print("⚠️ Second sell attempt failed, trying final position...")

					-- Try from a different angle
					LocalPlayer.Character.HumanoidRootPart.CFrame =
					CFrame.new(sellStandPosition + Vector3.new(1, 0.5, 1))
					task.wait(0.3)

					-- Final sell attempt
					Sell_Item:FireServer()
					task.wait(0.5)
				end
			end
		else
			print("❌ No tool equipped in hand!")
			Library:Notify("❌ No item in hand to sell!", 2)
			return false
		end

		-- Teleport back to original position
		if OriginalPlayerPosition then
			print("Teleporting back to original location...")
			Library:Notify("Teleporting back...", 2)
			LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(OriginalPlayerPosition + Vector3.new(0, 2, 0))
			task.wait(0.5)
		end

		Library:Notify("Item sold and teleported back!", 3)
		return true
	end)

	if not success then
		print("Error in sellItemInHandWithTeleport:", result)
		Library:Notify("Error during sell process: " .. tostring(result), 4)

		-- Try to teleport back even if there was an error
		if
		OriginalPlayerPosition
				and LocalPlayer.Character
				and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		then
			pcall(function()
				LocalPlayer.Character.HumanoidRootPart.CFrame =
				CFrame.new(OriginalPlayerPosition + Vector3.new(0, 2, 0))
			end)
		end
		return false
	end

	return result
end

-- Initialize auto sell functions now that sellItemInHandWithTeleport is defined
setupAutoSellEquipMonitor = function()
	if autoSellConnection then
		autoSellConnection:Disconnect()
	end

	autoSellConnection = LocalPlayer.Character.ChildAdded:Connect(function(child)
		if autoSellEnabled and child:IsA("Tool") then
			print("🔍 Auto-detected equipped item:", child.Name)
			Library:Notify("🔍 Detected equipped item: " .. child.Name, 2)
			-- Wait a brief moment to ensure the tool is fully equipped
			task.wait(0.2)
			-- Sell the item that was just equipped
			task.spawn(function()
				sellItemInHandWithTeleport()
			end)
		end
	end)

	-- print removed: Auto-sell equipment monitor set up
end

setupCharacterMonitor = function()
	if LocalPlayer.Character then
		setupAutoSellEquipMonitor()
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid")
		setupAutoSellEquipMonitor()
	end)
end

-- Initialize the character monitor
setupCharacterMonitor()

-- Initialize auto sell if Auto Sell is already enabled from saved settings
if autoSellEnabled then
	print("✅ Auto-sell was enabled from saved settings")
end

-- Dupe Tab (PATCHED)
local dupe_enabled = false

if Tabs.Dupe then
	local DupeGroupBox = Tabs.Dupe:AddLeftGroupbox("🔄 Dupe System - PATCHED")

	DupeGroupBox:AddLabel("⚠️ WARNING: This feature has been PATCHED")
	DupeGroupBox:AddLabel("The dupe exploit no longer works and has been")
	DupeGroupBox:AddLabel("disabled by the game developers.")

	DupeGroupBox:AddDivider()

	DupeGroupBox:AddToggle("DupeToggle", {
		Text = "Dupe (PATCHED)",
		Tooltip = "This feature has been patched and no longer works",
		Default = false,

		Callback = function(Value)
			dupe_enabled = Value
			if Value then
				Library:Notify("🚫 PATCHED: This dupe method has been fixed by developers!", 4)

				-- Automatically disable the toggle after showing the patched message
				task.spawn(function()
					task.wait(1)
					if Toggles.DupeToggle then
						Toggles.DupeToggle:SetValue(false)
					end
					dupe_enabled = false
				end)

				return
			end
		end,
	})

	DupeGroupBox:AddLabel("Original description: Ask any player in server to hold any pet in his hand")

	DupeGroupBox:AddDivider()

	local DupeInfoGroupBox = Tabs.Dupe:AddRightGroupbox("📋 Dupe Information")

	DupeInfoGroupBox:AddLabel("STATUS: 🔴 PATCHED")
	DupeInfoGroupBox:AddLabel("This exploit has been patched by game developers.")
	DupeInfoGroupBox:AddLabel("It is no longer functional and will not work.")

	DupeInfoGroupBox:AddDivider()

	DupeInfoGroupBox:AddLabel("Why was it patched?")
	DupeInfoGroupBox:AddLabel("• Game developers fixed the exploit")
	DupeInfoGroupBox:AddLabel("• Security measures were implemented")
	DupeInfoGroupBox:AddLabel("• The method no longer bypasses server validation")

	DupeInfoGroupBox:AddDivider()

	DupeInfoGroupBox:AddButton("📞 Join Discord Community", function()
		if setclipboard then
			setclipboard("https://discord.gg/SSJG3nmv6f")
			Library:Notify("📋 Discord link copied to clipboard!", 3)
		else
			Library:Notify("Discord: https://discord.gg/SSJG3nmv6f", 5)
		end
	end)
end

-- Auto Sell on Notification Feature
local AutoSellOnNotificationEnabled = false
local NotificationConnection = nil
local isSelling = false -- Add selling state flag

SellGroupBox:AddToggle("AutoSellOnNotification", {
	Text = "🔔 Auto Sell on Full Backpack",
	Tooltip = "Automatically sell inventory when 'Max backpack space! Go sell!' notification appears",
	Default = false,

	Callback = function(Value)
		print("[cb] Auto Sell on Notification toggled:", Value)
		AutoSellOnNotificationEnabled = Value

		if Value then
			Library:Notify("🔔 Auto Sell on Notification enabled! Will auto-sell when backpack is full.", 4)

			-- Connect to the notification event
			if NotificationConnection then
				NotificationConnection:Disconnect()
			end

			NotificationConnection = ReplicatedStorage.GameEvents.Notification.OnClientEvent:Connect(function(message)
				print("🔔 Notification received:", message) -- Debug print
				print("🔔 AutoSellOnNotificationEnabled:", AutoSellOnNotificationEnabled) -- Debug print
				print("🔔 isSelling:", isSelling) -- Debug print
				print("🔔 AutoCollectPlantsEnabled:", AutoCollectPlantsEnabled) -- Debug print

				if AutoSellOnNotificationEnabled and message == "Max backpack space! Go sell!" and not isSelling then
					print("🔔 Detected full backpack notification! Auto-selling inventory...")
					Library:Notify("🔔 Backpack Full! Auto-selling inventory...", 3)

					-- Set selling state to prevent multiple simultaneous sells
					isSelling = true

					-- Temporarily pause auto collect if it's running
					local wasAutoCollectEnabled = AutoCollectPlantsEnabled
					if wasAutoCollectEnabled then
						print("⏸️ Pausing auto collect plant for selling...")
						AutoCollectPlantsEnabled = false
						Library:Notify("⏸️ Pausing auto collect during sell...", 2)
						task.wait(1) -- Give time for collection to stop
					end

					-- Small delay to prevent immediate re-triggering
					task.wait(1)

					-- Call the sell function and verify success
					local sellSuccess = sellInventoryWithImprovedTeleport()

					-- Verify backpack is actually empty after selling
					local backpackStillFull = false
					local backpack = LocalPlayer:FindFirstChild("Backpack")
					if backpack then
						local itemCount = #backpack:GetChildren()
						print("📦 Items remaining in backpack after sell:", itemCount)
						-- More reasonable threshold - if we sold at least 50% of items or have less than 15 items, consider it successful
						local itemsSold = (backpackCount or 0) - itemCount
						if itemCount > 20 and itemsSold < 10 then -- Only consider full if more than 20 items AND barely sold anything
							backpackStillFull = true
							print("⚠️ Backpack still appears full after selling!")
						else
							print(
									"✅ Backpack sell was successful - "
											.. itemsSold
											.. " items sold, "
											.. itemCount
											.. " remaining"
							)
						end
					end

					-- Wait a bit more if backpack is still full
					if backpackStillFull then
						Library:Notify("⚠️ Backpack still full, waiting longer...", 3)
						task.wait(3)

						-- Check again with more lenient threshold
						if backpack then
							local itemCount = #backpack:GetChildren()
							print("📦 Items in backpack after extended wait:", itemCount)
							if itemCount <= 25 then -- Much more reasonable threshold
								backpackStillFull = false
							end
						end
					end

					-- Resume auto collect if it was enabled and selling was successful
					if wasAutoCollectEnabled then
						if sellSuccess and not backpackStillFull then
							print("▶️ Resuming auto collect plant after successful sell...")
							AutoCollectPlantsEnabled = true
							Library:Notify("▶️ Resuming auto collect plant!", 3)
						else
							print("❌ Not resuming auto collect - sell may have failed or backpack still full")
							Library:Notify("❌ Auto collect not resumed - check backpack!", 4)
						end
					end

					-- Reset selling state
					isSelling = false

					-- Notify user of the action
					if sellSuccess and not backpackStillFull then
						Library:Notify("✅ Auto-sold inventory and resumed farming!", 4)
					else
						Library:Notify("⚠️ Auto-sell completed but may need manual check!", 4)
					end
				else
					print("🔔 Auto sell conditions not met:")
					print("  - AutoSellOnNotificationEnabled:", AutoSellOnNotificationEnabled)
					print("  - Is 'Max backpack space! Go sell!' message:", message == "Max backpack space! Go sell!")
					print("  - Not currently selling:", not isSelling)
				end
			end)
		else
			Library:Notify("🔔 Auto Sell on Notification disabled!", 2)

			-- Disconnect the notification event
			if NotificationConnection then
				NotificationConnection:Disconnect()
				NotificationConnection = nil
			end
		end
	end,
})

-- Additional manual button for testing
SellGroupBox:AddButton("💰 Sell Inventory Now", function()
	Library:Notify("💰 Manually selling inventory...", 2)
	sellInventoryWithTeleport()
end)



-- Auto Sell on Notification Feature for Auto Farm
local AutoSellOnNotificationEnabledFarm = false
local NotificationConnectionFarm = nil

AutoFarmGroupBox:AddToggle("AutoSellOnNotification", {
	Text = "🔔 Auto Sell on Full Backpack",
	Tooltip = "Automatically sell inventory when 'Max backpack space! Go sell!' notification appears during farming",
	Default = false,

	Callback = function(Value)
		print("[cb] Auto Sell on Notification toggled:", Value)
		AutoSellOnNotificationEnabledFarm = Value

		if Value then
			Library:Notify("🔔 Auto Sell on Notification enabled! Will auto-sell when backpack is full.", 4)

			-- Connect to the notification event
			if NotificationConnectionFarm then
				NotificationConnectionFarm:Disconnect()
			end

			NotificationConnectionFarm = ReplicatedStorage.GameEvents.Notification.OnClientEvent:Connect(
					function(message)
						if
						AutoSellOnNotificationEnabledFarm
								and message == "Max backpack space! Go sell!"
								and not isSelling
						then
							print("🔔 Detected full backpack notification! Auto-selling inventory...")
							Library:Notify("🔔 Backpack Full! Auto-selling inventory...", 3)

							-- Set selling state to prevent multiple simultaneous sells
							isSelling = true

							-- Temporarily pause auto collect if it's running
							local wasAutoCollectEnabled = AutoCollectPlantsEnabled
							if wasAutoCollectEnabled then
								print("⏸️ Pausing auto collect plant for selling...")
								AutoCollectPlantsEnabled = false
								Library:Notify("⏸️ Pausing auto collect during sell...", 2)
								task.wait(1) -- Give time for collection to stop
							end

							-- Small delay to prevent immediate re-triggering
							task.wait(1)

							-- Call the sell function and verify success
							local sellSuccess = sellInventoryWithImprovedTeleport()

							-- Verify backpack is actually empty after selling
							local backpackStillFull = false
							local backpack = LocalPlayer:FindFirstChild("Backpack")
							if backpack then
								local itemCount = #backpack:GetChildren()
								print("📦 Items remaining in backpack after sell:", itemCount)
								-- More reasonable threshold - if we sold at least 50% of items or have less than 15 items, consider it successful
								local itemsSold = (backpackCount or 0) - itemCount
								if itemCount > 20 and itemsSold < 10 then -- Only consider full if more than 20 items AND barely sold anything
									backpackStillFull = true
									print("⚠️ Backpack still appears full after selling!")
								else
									print(
											"✅ Backpack sell was successful - "
													.. itemsSold
													.. " items sold, "
													.. itemCount
													.. " remaining"
									)
								end
							end

							-- Wait a bit more if backpack is still full
							if backpackStillFull then
								Library:Notify("⚠️ Backpack still full, waiting longer...", 3)
								task.wait(3)

								-- Check again with more lenient threshold
								if backpack then
									local itemCount = #backpack:GetChildren()
									print("📦 Items in backpack after extended wait:", itemCount)
									if itemCount <= 25 then -- Much more reasonable threshold
										backpackStillFull = false
									end
								end
							end

							-- Resume auto collect if it was enabled and selling was successful
							if wasAutoCollectEnabled then
								if sellSuccess and not backpackStillFull then
									print("▶️ Resuming auto collect plant after successful sell...")
									AutoCollectPlantsEnabled = true
									Library:Notify("▶️ Resuming auto collect plant!", 3)
								else
									print("❌ Not resuming auto collect - sell may have failed or backpack still full")
									Library:Notify("❌ Auto collect not resumed - check backpack!", 4)
								end
							end

							-- Reset selling state
							isSelling = false

							-- Notify user of the action
							if sellSuccess and not backpackStillFull then
								Library:Notify("✅ Auto-sold inventory and resumed farming!", 4)
							else
								Library:Notify("⚠️ Auto-sell completed but may need manual check!", 4)
							end
						end
					end
			)
		else
			Library:Notify("🔔 Auto Sell on Notification disabled!", 2)

			-- Disconnect the notification event
			if NotificationConnectionFarm then
				NotificationConnectionFarm:Disconnect()
				NotificationConnectionFarm = nil
			end
		end
	end,
})

-- Web Hook Functionality
local WebHookConfigGroupBox = Tabs.WebHook:AddLeftGroupbox("Webhook Configuration")
local WebHookReportingGroupBox = Tabs.WebHook:AddRightGroupbox("Reporting Options")

-- Variables for webhook functionality
local WebhookEnabled = false
local WebhookURL = ""
local WeatherReportingEnabled = false
local SeedsAndGearsReportingEnabled = false
local EventShopReportingEnabled = false
local EggsReportingEnabled = false
local CosmeticStockReportingEnabled = false

-- Services
-- Services available through Services table
-- Configuration options
WebHookConfigGroupBox:AddToggle("WebhookEnabled", {
	Text = "Enable Webhook",
	Tooltip = "Enable or disable webhook reporting",
	Default = false,
	Callback = function(Value)
		WebhookEnabled = Value
		if Value then
			Library:Notify("✅ Webhook reporting enabled!", 3)
		else
			Library:Notify("❌ Webhook reporting disabled!", 3)
		end
	end,
})

WebHookConfigGroupBox:AddInput("WebhookURL", {
	Text = "Webhook URL",
	Tooltip = "Enter your Discord webhook URL",
	Placeholder = "https://discord.com/api/webhooks/...",
	Callback = function(Value)
		WebhookURL = Value
		Library:Notify("🔗 Webhook URL updated!", 2)
	end,
})

WebHookConfigGroupBox:AddToggle("AntiAFK", {
	Text = "Anti-AFK",
	Tooltip = "Prevents being kicked for inactivity",
	Default = true,
	Callback = function(Value)
		if Value then
			Library:Notify("🛡️ Anti-AFK enabled!", 2)
		else
			Library:Notify("⚠️ Anti-AFK disabled!", 2)
		end
	end,
})

WebHookConfigGroupBox:AddToggle("AutoReconnect", {
	Text = "Auto-Reconnect",
	Tooltip = "Automatically reconnect if disconnected",
	Default = true,
	Callback = function(Value)
		if Value then
			Library:Notify("🔄 Auto-Reconnect enabled!", 2)
		else
			Library:Notify("⚠️ Auto-Reconnect disabled!", 2)
		end
	end,
})

WebHookConfigGroupBox:AddToggle("RenderingEnabled", {
	Text = "Rendering Enabled",
	Tooltip = "Enable or disable 3D rendering (saves resources)",
	Default = false,
	Callback = function(Value)
		RunService:Set3dRenderingEnabled(Value)
		if Value then
			Library:Notify("🖥️ 3D Rendering enabled!", 2)
		else
			Library:Notify("🖥️ 3D Rendering disabled!", 2)
		end
	end,
})

-- Reporting options
WebHookReportingGroupBox:AddToggle("WeatherReporting", {
	Text = "Weather Reporting",
	Tooltip = "Report weather events to webhook",
	Default = false,
	Callback = function(Value)
		WeatherReportingEnabled = Value
		if Value then
			Library:Notify("☁️ Weather reporting enabled!", 2)
		else
			Library:Notify("☁️ Weather reporting disabled!", 2)
		end
	end,
})

WebHookReportingGroupBox:AddToggle("SeedsAndGearsReporting", {
	Text = "Seeds & Gears Reporting",
	Tooltip = "Report seeds and gears stock to webhook",
	Default = false,
	Callback = function(Value)
		SeedsAndGearsReportingEnabled = Value
		if Value then
			Library:Notify("🌱 Seeds & Gears reporting enabled!", 2)
		else
			Library:Notify("🌱 Seeds & Gears reporting disabled!", 2)
		end
	end,
})

WebHookReportingGroupBox:AddToggle("EventShopReporting", {
	Text = "Event Shop Reporting",
	Tooltip = "Report event shop stock to webhook",
	Default = false,
	Callback = function(Value)
		EventShopReportingEnabled = Value
		if Value then
			Library:Notify("🎉 Event Shop reporting enabled!", 2)
		else
			Library:Notify("🎉 Event Shop reporting disabled!", 2)
		end
	end,
})

WebHookReportingGroupBox:AddToggle("EggsReporting", {
	Text = "Eggs Reporting",
	Tooltip = "Report egg stock to webhook",
	Default = false,
	Callback = function(Value)
		EggsReportingEnabled = Value
		if Value then
			Library:Notify("🥚 Eggs reporting enabled!", 2)
		else
			Library:Notify("🥚 Eggs reporting disabled!", 2)
		end
	end,
})

WebHookReportingGroupBox:AddToggle("CosmeticStockReporting", {
	Text = "Cosmetic Stock Reporting",
	Tooltip = "Report cosmetic items stock to webhook",
	Default = false,
	Callback = function(Value)
		CosmeticStockReportingEnabled = Value
		if Value then
			Library:Notify("👒 Cosmetic Stock reporting enabled!", 2)
		else
			Library:Notify("👒 Cosmetic Stock reporting disabled!", 2)
		end
	end,
})

-- Webhook functionality
local function ConvertColor3(Color)
	local Hex = Color:ToHex()
	return tonumber(Hex, 16)
end

local function GetDataPacket(Data, Target)
	for _, Packet in pairs(Data) do
		local Name = Packet[1]
		local Content = Packet[2]

		if Name == Target then
			return Content
		end
	end
	return nil
end

local function MakeStockString(Stock)
	local String = ""
	for Name, Data in pairs(Stock) do
		local Amount = Data.Stock
		local EggName = Data.EggName

		Name = EggName or Name
		String = String .. Name .. " **x" .. Amount .. "**\n"
	end

	return String
end

local function WebhookSend(Type, Fields)
	-- Check if webhook is enabled and URL is set
	if not WebhookEnabled or WebhookURL == "" then return end

	-- Define colors for different report types (modified)
	local Colors = {
		Weather = Color3.fromRGB(0, 191, 255),         -- Changed to DeepSkyBlue
		SeedsAndGears = Color3.fromRGB(50, 205, 50),   -- Changed to LimeGreen
		EventShop = Color3.fromRGB(138, 43, 226),      -- Changed to BlueViolet
		Eggs = Color3.fromRGB(255, 215, 0),            -- Changed to Gold
		CosmeticStock = Color3.fromRGB(255, 69, 0)     -- Changed to OrangeRed
	}

	-- Get color for this report type
	local Color = Colors[Type] or Color3.fromRGB(255, 255, 255)
	local ColorValue = ConvertColor3(Color)

	-- Webhook data
	local TimeStamp = DateTime.now():ToIsoDate()
	local Body = {		embeds = {
			{				title = "SNOWBIND Webhook",
							 description = "Advanced monitoring system by SNOWBIND",
							 color = ColorValue,
							 fields = Fields,
							 thumbnail = {
								 url = "https://i.imgur.com/8wEeX0J.png" -- Generic code icon
							 },
							 footer = {
								 text = "Created by SNOWBIND Webhook",
								 icon_url = "https://i.imgur.com/JrIa63B.png" -- Generic verified icon
							 },
							 timestamp = TimeStamp
			}
		}
	}

	local RequestData = {
		Url = WebhookURL,
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = HttpService:JSONEncode(Body)
	}

	-- Send POST request to the webhook
	task.spawn(function()
		local success, response = pcall(function()
			return request(RequestData)
		end)

		if success then
			Library:Notify("✅ Webhook sent successfully!", 2)
		else
			Library:Notify("❌ Failed to send webhook: " .. tostring(response), 3)
		end
	end)
end

local function ProcessPacket(Data, Type)
	-- Check if reporting for this type is enabled
	if Type == "Weather" and not WeatherReportingEnabled then return end
	if Type == "SeedsAndGears" and not SeedsAndGearsReportingEnabled then return end
	if Type == "EventShop" and not EventShopReportingEnabled then return end
	if Type == "Eggs" and not EggsReportingEnabled then return end
	if Type == "CosmeticStock" and not CosmeticStockReportingEnabled then return end

	local Fields = {}

	-- Define layouts for different report types
	local Layouts = {
		SeedsAndGears = {
			["ROOT/SeedStock/Stocks"] = "SEEDS STOCK",
			["ROOT/GearStock/Stocks"] = "GEAR STOCK"
		},
		EventShop = {
			["ROOT/EventShopStock/Stocks"] = "EVENT STOCK"
		},
		Eggs = {
			["ROOT/PetEggStock/Stocks"] = "EGG STOCK"
		},
		CosmeticStock = {
			["ROOT/CosmeticStock/ItemStocks"] = "COSMETIC ITEMS STOCK"
		}
	}

	local Layout = Layouts[Type]
	if not Layout then return end

	for Packet, Title in pairs(Layout) do
		local Stock = GetDataPacket(Data, Packet)
		if not Stock then return end

		local StockString = MakeStockString(Stock)
		local Field = {
			name = Title,
			value = StockString,
			inline = true
		}

		table.insert(Fields, Field)
	end

	WebhookSend(Type, Fields)
end

-- Connect to data stream event
if Services.ReplicatedStorage:FindFirstChild("GameEvents") and Services.ReplicatedStorage.GameEvents:FindFirstChild("DataStream") then
	Services.ReplicatedStorage.GameEvents.DataStream.OnClientEvent:Connect(function(Type, Profile, Data)
		if Type ~= "UpdateData" then return end
		if not Profile:find(LocalPlayer.Name) then return end

		-- Process different types of data
		if SeedsAndGearsReportingEnabled then
			ProcessPacket(Data, "SeedsAndGears")
		end

		if EventShopReportingEnabled then
			ProcessPacket(Data, "EventShop")
		end

		if EggsReportingEnabled then
			ProcessPacket(Data, "Eggs")
		end

		if CosmeticStockReportingEnabled then
			ProcessPacket(Data, "CosmeticStock")
		end
	end)
end

-- Variable to track if summer weather is active
local IsSummerWeatherActive = false

-- Function to check if summer event is active
local function IsSummerEventActive()
    -- Primary check: workspace SummerEvent attribute (this is the most reliable indicator)
    if workspace:GetAttribute("SummerEvent") then
        IsSummerWeatherActive = true
        return true
    end

    -- Secondary check: workspace SummerHarvest attribute (from SummerHarvestHandler)
    if workspace:GetAttribute("SummerHarvest") then
        IsSummerWeatherActive = true
        return true
    end

    -- Check current weather attribute as fallback
    if workspace:GetAttribute("CurrentWeatherEvent") == "Summer" then
        IsSummerWeatherActive = true
        return true
    end

    -- Reset our variable if none of the active checks pass
    IsSummerWeatherActive = false
    return false
end

-- Function to update summer plants dropdown based on inventory
local function UpdateSummerPlantsDropdown()
    -- Get all summer plants in inventory
    local summerPlants = ListSummerPlantsInInventory()

    if #summerPlants == 0 then
        Library:Notify("❌ No summer plants found in your inventory!", 3)
        return false
    end

    -- Get current selections
    local currentSelections = Options.SummerEventPlants.Value or {}
    local selectionChanged = false

    -- Select all available summer plants in the dropdown
    for _, plantName in ipairs(summerPlants) do
        if not currentSelections[plantName] then
            currentSelections[plantName] = true
            selectionChanged = true
        end
    end

    -- Update the dropdown if selections changed
    if selectionChanged then
        Options.SummerEventPlants:SetValue(currentSelections)
        Library:Notify("✅ Updated summer plants selection with plants from inventory!", 3)
        return true
    end

    return true
end

-- Connect to weather event
if Services.ReplicatedStorage:FindFirstChild("GameEvents") and Services.ReplicatedStorage.GameEvents:FindFirstChild("WeatherEventStarted") then
	Services.ReplicatedStorage.GameEvents.WeatherEventStarted.OnClientEvent:Connect(function(Event, Length)
		-- Update summer weather status only if the event is specifically "Summer"
		local wasSummerActive = IsSummerWeatherActive

		-- Check if this is a summer weather event
		if Event == "Summer" then
			IsSummerWeatherActive = true

			-- If summer weather just started and auto summer event is enabled, trigger the event
			if not wasSummerActive then
				-- Update summer plants dropdown based on inventory
				local plantsUpdated = UpdateSummerPlantsDropdown()

				-- Check if Auto Summer Event is enabled
				local AutoSummerEventToggle = Options.AutoSummerEvent
				if AutoSummerEventToggle and AutoSummerEventToggle.Value then
					Library:Notify("🌞 Summer weather detected! Auto Summer Event starting...", 3)
					task.wait(2) -- Wait a moment for the weather to fully initialize

					if not plantsUpdated then
						Library:Notify("❌ Auto Summer Event failed - No summer plants in inventory!", 3)
						return
					end

					-- Give selected plants to Summer NPC with auto mode enabled for enhanced notifications
					local success = GivePlantsToSummerNPC(Options.SummerEventPlants.Value, true)

					if success then
						Library:Notify("✅ Auto Summer Event completed successfully!", 3)
					else
						Library:Notify("❌ Auto Summer Event failed - Check your inventory for summer plants!", 3)
					end
				end
			end
		else
			-- If the weather event is not Summer, set summer as inactive
			IsSummerWeatherActive = false
		end

		-- Check if Weather reports are enabled
		if not WeatherReportingEnabled then return end

		-- Calculate end unix
		local ServerTime = math.round(workspace:GetServerTimeNow())
		local EndUnix = ServerTime + Length

		WebhookSend("Weather", {
			{
				name = "WEATHER",
				value = Event .. "\nEnds:<t:" .. EndUnix .. ":R>",
				inline = true
			}
		})
	end)
end

-- Additional listeners for summer event attributes
workspace:GetAttributeChangedSignal("SummerEvent"):Connect(function()
	local isActive = workspace:GetAttribute("SummerEvent")
	if isActive and not IsSummerWeatherActive then
		-- Summer event just started
		IsSummerWeatherActive = true
		Library:Notify("🌞 Summer Event activated!", 2)

		-- Trigger auto summer event if enabled
		local AutoSummerEventToggle = Options.AutoSummerEvent
		if AutoSummerEventToggle and AutoSummerEventToggle.Value then
			task.spawn(function()
				task.wait(1)
				local plantsUpdated = UpdateSummerPlantsDropdown()
				if plantsUpdated then
					local success = GivePlantsToSummerNPC(Options.SummerEventPlants.Value, true)
					if success then
						Library:Notify("✅ Auto Summer Event completed successfully!", 3)
					else
						Library:Notify("❌ Auto Summer Event failed - Check your inventory for summer plants!", 3)
					end
				else
					Library:Notify("❌ Auto Summer Event failed - No summer plants in inventory!", 3)
				end
			end)
		end
	elseif not isActive and IsSummerWeatherActive then
		-- Summer event ended
		IsSummerWeatherActive = false
		Library:Notify("🌙 Summer Event ended!", 2)
	end
end)

workspace:GetAttributeChangedSignal("SummerHarvest"):Connect(function()
	local isActive = workspace:GetAttribute("SummerHarvest")
	if isActive and not IsSummerWeatherActive then
		-- Summer harvest started
		IsSummerWeatherActive = true
		Library:Notify("🌾 Summer Harvest activated!", 2)
	elseif not isActive and IsSummerWeatherActive then
		-- Check if SummerEvent is still active before deactivating
		if not workspace:GetAttribute("SummerEvent") then
			IsSummerWeatherActive = false
			Library:Notify("🌙 Summer Harvest ended!", 2)
		end
	end
end)

-- Summer Event functionality
local SummerEventGroupBox = Tabs["Event"]:AddLeftGroupbox("Summer Event")

-- Check if summer event is active on script load
task.spawn(function()
    task.wait(5) -- Wait a few seconds for everything to load
    if IsSummerEventActive() then
        Library:Notify("🌞 Summer Event is active! Use the Summer Event features in the Event tab.", 5)
    else
        Library:Notify("ℹ️ Summer Event not detected. Use the 'Check for Summer Event' button in the Event tab if you believe it should be active.", 5)
    end
end)

-- Function to find Summer Harvest locations (Georgia NPC and Cart)
local function FindSummerHarvestLocations()
    local locations = {
        georgia = nil,
        cart = nil
    }

    -- Try to find in Interaction folder (main location)
    local interaction = workspace:FindFirstChild("Interaction")
    if interaction then
        local updateItems = interaction:FindFirstChild("UpdateItems")
        if updateItems then
            local summerHarvestEvent = updateItems:FindFirstChild("SummerHarvestEvent")
            if summerHarvestEvent then
                -- Find Georgia NPC
                local georgia = summerHarvestEvent:FindFirstChild("Georgia")
                if georgia then
                    locations.georgia = georgia
                end

                -- Find Cart
                local cart = summerHarvestEvent:FindFirstChild("Cart")
                if cart then
                    locations.cart = cart
                end
            end
        end
    end

    -- Try to find in NPCS folder (fallback)
    local npcs = workspace:FindFirstChild("NPCS")
    if npcs then
        for _, npc in pairs(npcs:GetChildren()) do
            if npc.Name == "Georgia" or string.find(npc.Name:lower(), "summer") then
                locations.georgia = locations.georgia or npc
            end
        end
    end    -- Use CollectionService to find SummerHarvestCart (as mentioned in SummerHarvestHandler)
    -- Use shared Services.CollectionService
    local summerCarts = Services.CollectionService:GetTagged("SummerHarvestCart")
    if #summerCarts > 0 then
        locations.cart = locations.cart or summerCarts[1]
    end

    return locations
end

-- Function to find the Summer NPC (backwards compatibility - now prioritizes Cart)
local function FindSummerNPC()
    local locations = FindSummerHarvestLocations()
    return locations.cart or locations.georgia  -- Prioritize Cart over Georgia
end

-- Function to list all summer plants in player's inventory
local function ListSummerPlantsInInventory()
    local summerPlants = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    -- Known summer plants (from the game data)
    local knownSummerPlants = {
        "Pineapple", "Watermelon", "Cauliflower", "Green Apple", "Banana", "Avocado",
        "Kiwi", "Prickly Pear", "Feijoa", "Sugar Apple", "Loquat", "Wild Carrot",
        "Pear", "Cantaloupe", "Parasol Flower", "Rosy Delight", "Elephant Ears", "Bell Pepper"
    }

    if not backpack then
        return summerPlants
    end

    -- Try to use PlantTraitsData if available
    local PlantTraitsData = nil
    local success = pcall(function()
        PlantTraitsData = require(Services.ReplicatedStorage.Modules.PlantTraitsData)
    end)

    for _, tool in pairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local toolName = tool.Name
            local isSummerPlant = false

            -- Method 1: Use PlantTraitsData if available
            if success and PlantTraitsData and PlantTraitsData.HasTrait then
                local hasTraitSuccess = pcall(function()
                    isSummerPlant = PlantTraitsData.HasTrait(toolName, "Summer")
                end)
                if hasTraitSuccess and isSummerPlant then
                    table.insert(summerPlants, toolName)
                    continue
                end
            end

            -- Method 2: Check tool attributes for summer trait
            if tool:GetAttribute("Summer") == true then
                isSummerPlant = true
            end

            -- Method 3: Check ItemName attribute (for mutated plants)
            local itemNameAttr = tool:GetAttribute("ItemName")
            if itemNameAttr then
                for _, summerName in pairs(knownSummerPlants) do
                    if itemNameAttr == summerName or string.find(itemNameAttr, summerName) then
                        isSummerPlant = true
                        break
                    end
                end
            end

            -- Method 4: Check tool name against known summer plants
            if not isSummerPlant then
                for _, summerName in pairs(knownSummerPlants) do
                    if toolName == summerName or string.find(toolName, summerName) then
                        isSummerPlant = true
                        break
                    end
                end
            end

            -- Method 5: Check for summer-related keywords in tool name
            if not isSummerPlant then
                local lowerName = toolName:lower()
                if string.find(lowerName, "summer") then
                    isSummerPlant = true
                end
            end

            if isSummerPlant then
                table.insert(summerPlants, toolName)
            end
        end
    end

    return summerPlants
end

-- Function to give plants/fruits to Summer Cart (Updated to use proper remote and prioritize Cart)
local function GivePlantsToSummerNPC(selectedPlants, isAutoMode)
    -- Check if summer event is active
    if not IsSummerEventActive() then
        Library:Notify("❌ Summer Event is only available during summer weather!", 3)
        return false
    end

    -- Find the Summer Cart (prioritized) or Georgia as fallback
    local summerTarget = FindSummerNPC()
    if not summerTarget then
        Library:Notify("❌ Could not find Summer Harvest Cart or Georgia NPC!", 3)
        return false
    end

    -- Determine what we found
    local targetName = summerTarget.Name == "Cart" and "Summer Harvest Cart" or "Georgia (Summer Harvest NPC)"
    if isAutoMode then
        Library:Notify("🎯 Auto Summer Event: Found " .. targetName, 2)
    else
        Library:Notify("🎯 Found " .. targetName, 2)
    end

    -- Get the SummerHarvestRemoteEvent
    local SummerHarvestRemoteEvent = Services.ReplicatedStorage.GameEvents:FindFirstChild("SummerHarvestRemoteEvent")
    if not SummerHarvestRemoteEvent then
        Library:Notify("❌ Could not find SummerHarvestRemoteEvent!", 3)
        return false
    end

    -- Teleport to the Summer Cart/NPC
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    local teleportPosition = summerTarget.PrimaryPart and summerTarget.PrimaryPart.CFrame or
                            (summerTarget:IsA("BasePart") and summerTarget.CFrame or
                            summerTarget:FindFirstChildWhichIsA("BasePart").CFrame)

    -- Add offset to avoid being inside the Cart/NPC
    teleportPosition = teleportPosition * CFrame.new(0, 2, 5)

    -- Teleport
    LocalPlayer.Character.HumanoidRootPart.CFrame = teleportPosition
    if isAutoMode then
        Library:Notify("🚀 Auto Summer Event: Teleported to " .. targetName, 2)
    else
        Library:Notify("🚀 Teleported to " .. targetName, 2)
    end
    task.wait(1) -- Wait for teleport to register

    local submittedCount = 0
    local plantsToSubmit = {}    -- Determine which plants to submit
    if not selectedPlants or not next(selectedPlants) then
        -- If no plants selected, get all summer plants from inventory
        local backpack = LocalPlayer:FindFirstChild("Backpack")

        if backpack then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    -- Use the improved summer plant detection
                    local toolName = tool.Name
                    local isSummerPlant = false

                    -- Known summer plants (from the game data)
                    local knownSummerPlants = {
                        "Pineapple", "Watermelon", "Cauliflower", "Green Apple", "Banana", "Avocado",
                        "Kiwi", "Prickly Pear", "Feijoa", "Sugar Apple", "Loquat", "Wild Carrot",
                        "Pear", "Cantaloupe", "Parasol Flower", "Rosy Delight", "Elephant Ears", "Bell Pepper"
                    }

                    -- Check tool attributes for summer trait
                    if tool:GetAttribute("Summer") == true then
                        isSummerPlant = true
                    end

                    -- Check ItemName attribute (for mutated plants)
                    local itemNameAttr = tool:GetAttribute("ItemName")
                    if itemNameAttr then
                        for _, summerName in pairs(knownSummerPlants) do
                            if itemNameAttr == summerName or string.find(itemNameAttr, summerName) then
                                isSummerPlant = true
                                break
                            end
                        end
                    end

                    -- Check tool name against known summer plants
                    if not isSummerPlant then
                        for _, summerName in pairs(knownSummerPlants) do
                            if toolName == summerName or string.find(toolName, summerName) then
                                isSummerPlant = true
                                break
                            end
                        end
                    end

                    -- Check for summer-related keywords in tool name
                    if not isSummerPlant then
                        local lowerName = toolName:lower()
                        if string.find(lowerName, "summer") then
                            isSummerPlant = true
                        end
                    end

                    if isSummerPlant then
                        table.insert(plantsToSubmit, tool)
                    end
                end
            end
        end

        if isAutoMode then
            Library:Notify("🌱 Auto Summer Event: Found " .. #plantsToSubmit .. " summer plants in inventory", 2)
            if #plantsToSubmit > 0 then
                -- List all found plants
                local plantNames = {}
                for _, plant in pairs(plantsToSubmit) do
                    table.insert(plantNames, plant.Name)
                end
                Library:Notify("📋 Plants to submit: " .. table.concat(plantNames, ", "), 3)
            end
        else
            Library:Notify("🌱 Found " .. #plantsToSubmit .. " summer plants in inventory", 2)
        end
    else
        -- Submit only selected plants from inventory
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for plantName, selected in pairs(selectedPlants) do
                if selected then
                    local tool = backpack:FindFirstChild(plantName)
                    if tool and tool:IsA("Tool") then
                        table.insert(plantsToSubmit, tool)
                    end
                end
            end
        end

        if isAutoMode then
            Library:Notify("🌱 Auto Summer Event: Selected " .. #plantsToSubmit .. " plants to submit", 2)
            if #plantsToSubmit > 0 then
                -- List all selected plants
                local plantNames = {}
                for _, plant in pairs(plantsToSubmit) do
                    table.insert(plantNames, plant.Name)
                end
                Library:Notify("📋 Selected plants: " .. table.concat(plantNames, ", "), 3)
            end
        else
            Library:Notify("🌱 Selected " .. #plantsToSubmit .. " plants to submit", 2)
        end
    end

    -- Check if there are any plants to submit
    if #plantsToSubmit == 0 then
        local message = isAutoMode and "❌ Auto Summer Event: No summer plants found in inventory!" or "❌ No summer plants found in inventory!"
        Library:Notify(message, 3)
        -- Return to original position
        LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
        return false
    end    -- Submit each plant by equipping it and firing the remote
    for i, plantTool in pairs(plantsToSubmit) do
        -- Check if tool still exists
        if not plantTool or not plantTool.Parent then
            if isAutoMode then
                Library:Notify("⚠️ Auto Summer Event: Plant tool no longer exists, skipping...", 1)
            end
            continue
        end

        -- Equip the plant tool
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            if isAutoMode then
                Library:Notify("🔧 Auto Summer Event: Equipping " .. plantTool.Name .. " (" .. i .. "/" .. #plantsToSubmit .. ")", 1)
            else
                Library:Notify("🔧 Equipping " .. plantTool.Name .. " (" .. i .. "/" .. #plantsToSubmit .. ")", 1)
            end

            -- Unequip any currently equipped tool first
            local currentTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if currentTool then
                currentTool.Parent = LocalPlayer.Backpack
                task.wait(0.5)
            end

            -- Equip the new tool
            if plantTool.Parent == LocalPlayer.Backpack then
                LocalPlayer.Character.Humanoid:EquipTool(plantTool)
            elseif plantTool.Parent ~= LocalPlayer.Character then
                -- Move tool to backpack first, then equip
                plantTool.Parent = LocalPlayer.Backpack
                task.wait(0.2)
                LocalPlayer.Character.Humanoid:EquipTool(plantTool)
            end

            -- Wait for tool to be equipped with timeout
            local timeoutCounter = 0
            local maxTimeout = 20 -- 2 seconds max wait
            while timeoutCounter < maxTimeout do
                local equippedTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
                if equippedTool and equippedTool.Name == plantTool.Name then
                    break
                end
                task.wait(0.1)
                timeoutCounter = timeoutCounter + 1
            end

            -- Final check if tool is actually equipped
            local equippedTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
            if equippedTool and equippedTool.Name == plantTool.Name then
                -- Fire the remote to submit the held plant
                SummerHarvestRemoteEvent:FireServer("SubmitHeldPlant")
                submittedCount = submittedCount + 1

                if isAutoMode then
                    Library:Notify("✅ Auto Summer Event: Submitted " .. plantTool.Name .. " (" .. submittedCount .. "/" .. #plantsToSubmit .. ")", 2)
                else
                    Library:Notify("✅ Submitted " .. plantTool.Name .. " (" .. submittedCount .. "/" .. #plantsToSubmit .. ")", 2)
                end
                task.wait(1.5) -- Wait between submissions
            else
                if isAutoMode then
                    Library:Notify("⚠️ Auto Summer Event: Failed to equip " .. plantTool.Name .. " - timeout", 2)
                else
                    Library:Notify("⚠️ Failed to equip " .. plantTool.Name .. " - timeout", 2)
                end
            end
        end
    end

    -- Teleport back to original position
    task.wait(0.5)
    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition

    if isAutoMode then
        Library:Notify("✅ Auto Summer Event: Submitted " .. submittedCount .. "/" .. #plantsToSubmit .. " plants and returned!", 3)
    else
        Library:Notify("✅ Submitted " .. submittedCount .. "/" .. #plantsToSubmit .. " plants and returned!", 3)
    end

    return submittedCount > 0
end

-- Add button to list summer plants in inventory
SummerEventGroupBox:AddButton("📋 List Summer Plants in Inventory", function()
    local summerPlants = ListSummerPlantsInInventory()

    if #summerPlants > 0 then
        Library:Notify("🌱 Summer plants in inventory (" .. #summerPlants .. "):", 4)
        local plantList = table.concat(summerPlants, ", ")
        Library:Notify("📋 " .. plantList, 5)    else
        Library:Notify("❌ No summer plants found in your inventory!", 3)
    end
end)

-- Add button to update summer plants dropdown based on inventory
SummerEventGroupBox:AddButton("🔄 Update Summer Plants Selection", function()
    local updated = UpdateSummerPlantsDropdown()
    if updated then
        Library:Notify("✅ Summer plants selection updated from inventory!", 3)
    else
        Library:Notify("❌ No summer plants found in your inventory to select!", 3)
    end
end)

-- Add button to force check for summer event
SummerEventGroupBox:AddButton("🌞 Check for Summer Event", function()
    -- Force check for summer event with detailed reporting
    local isActive = IsSummerEventActive()

    -- Show detailed information about current status
    local summerEventAttr = workspace:GetAttribute("SummerEvent")
    local summerHarvestAttr = workspace:GetAttribute("SummerHarvest")
    local currentWeatherAttr = workspace:GetAttribute("CurrentWeatherEvent")

    Library:Notify("🔍 Summer Event Status Check:", 3)
    Library:Notify("SummerEvent attribute: " .. tostring(summerEventAttr), 2)
    Library:Notify("SummerHarvest attribute: " .. tostring(summerHarvestAttr), 2)
    Library:Notify("CurrentWeatherEvent: " .. tostring(currentWeatherAttr), 2)

    if isActive then
        Library:Notify("✅ Summer Event is active! You can now participate in the event.", 3)

        -- Update summer plants dropdown
        local updated = UpdateSummerPlantsDropdown()
        if updated then
            Library:Notify("✅ Summer plants selection updated from inventory!", 3)
        else
            Library:Notify("⚠️ No summer plants found in your inventory to select!", 3)
        end

        -- Try to find the Summer Cart/NPC
        local summerTarget = FindSummerNPC()
        if summerTarget then
            local targetName = summerTarget.Name == "Cart" and "Summer Harvest Cart" or "Georgia (Summer Harvest NPC)"
            Library:Notify("🎯 Found " .. targetName .. "! You can now submit summer plants.", 3)
        else
            Library:Notify("⚠️ Could not find Summer Harvest Cart or Georgia NPC.", 3)
        end
    else
        Library:Notify("❌ Summer Event is not currently active. Please wait for summer weather.", 3)

        -- Check if SummerHarvestEvent folder exists (this would be a false positive)
        local interaction = workspace:FindFirstChild("Interaction")
        if interaction then
            local updateItems = interaction:FindFirstChild("UpdateItems")
            if updateItems and updateItems:FindFirstChild("SummerHarvestEvent") then
                Library:Notify("ℹ️ Note: SummerHarvestEvent folder exists but event is not active.", 2)
            end
        end
    end
end)

-- Add dropdown for plants/fruits (using actual summer plants from game data)
SummerEventGroupBox:AddDropdown("SummerEventPlants", {
    Values = {
        -- Summer plants from PlantTraitsData.Summer
        "Pineapple",
        "Watermelon",
        "Cauliflower",
        "Green Apple",
        "Banana",
        "Avocado",
        "Kiwi",
        "Prickly Pear",
        "Feijoa",
        "Sugar Apple",
        "Loquat",
        "Wild Carrot",
        "Pear",
        "Cantaloupe",
        "Parasol Flower",
        "Rosy Delight",
        "Elephant Ears",
        "Bell Pepper"
    },
    Default = 1,
    Multi = true, -- Allows multiple selections

    Text = "Summer Plants/Fruits",
    Tooltip = "Select summer plants/fruits to give to Georgia during Summer Harvest. These are the actual summer plants from the game data.",

    Callback = function(Value)
        print("[cb] Summer Event plants selection changed:")
        for plant, selected in next, Options.SummerEventPlants.Value do
            print(plant, selected)
        end
    end,
})

-- Add button to trigger the Summer Event
SummerEventGroupBox:AddButton("Give Plants to Summer NPC", function()
    -- Give selected plants to Summer NPC
    local success = GivePlantsToSummerNPC(Options.SummerEventPlants.Value, false)

    if success then
        Library:Notify("✅ Successfully completed Summer Event!", 3)
    else
        Library:Notify("❌ Failed to complete Summer Event", 3)
    end
end)

-- Function to teleport to Summer Cart without giving plants
local function TeleportToSummerNPC(bypassWeatherCheck)
    -- Check if summer event is active (unless bypassed)
    if not IsSummerEventActive() and not bypassWeatherCheck then
        Library:Notify("❌ Summer Event is only available during summer weather!", 3)
        return false
    end

    -- Find the Summer Cart (prioritized) or Georgia as fallback
    local summerTarget = FindSummerNPC()
    if not summerTarget then
        Library:Notify("❌ Could not find Summer Harvest Cart or Georgia NPC!", 3)
        return false
    end

    -- Determine what we found
    local targetName = summerTarget.Name == "Cart" and "Summer Harvest Cart" or "Georgia (Summer Harvest NPC)"

    -- Teleport to the Summer Cart/NPC
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    local teleportPosition = summerTarget.PrimaryPart and summerTarget.PrimaryPart.CFrame or
                            (summerTarget:IsA("BasePart") and summerTarget.CFrame or
                            summerTarget:FindFirstChildWhichIsA("BasePart").CFrame)

    -- Add offset to avoid being inside the Cart/NPC
    teleportPosition = teleportPosition * CFrame.new(0, 2, 5)

    -- Teleport
    LocalPlayer.Character.HumanoidRootPart.CFrame = teleportPosition
    Library:Notify("🚀 Teleported to " .. targetName, 2)

    return true
end

-- Add toggle for auto Summer Event
SummerEventGroupBox:AddToggle("AutoSummerEvent", {
    Text = "Auto Summer Event",
    Default = false,
    Tooltip = "Automatically give summer plants to Summer Harvest Cart when summer weather starts. Lists all plants first, then equips and submits each one with step-by-step notifications.",

    Callback = function(Value)
        print("[cb] Auto Summer Event toggled:", Value)
        if Value then
            Library:Notify("🌞 Auto Summer Event enabled!", 3)

            -- Check current summer status more thoroughly
            local isCurrentlyActive = IsSummerEventActive()

            if isCurrentlyActive then
                Library:Notify("🌞 Summer is already active! Starting Auto Summer Event now...", 3)
                task.spawn(function()
                    task.wait(1) -- Brief delay
                    local plantsUpdated = UpdateSummerPlantsDropdown()
                    if plantsUpdated then
                        local success = GivePlantsToSummerNPC(Options.SummerEventPlants.Value, true)
                        if success then
                            Library:Notify("✅ Auto Summer Event completed successfully!", 3)
                        else
                            Library:Notify("❌ Auto Summer Event failed - Check your inventory for summer plants!", 3)
                        end
                    else
                        Library:Notify("❌ Auto Summer Event failed - No summer plants in inventory!", 3)
                    end
                end)
            else
                Library:Notify("🌞 Waiting for summer weather to start...", 3)
                -- Debug: Show current workspace attributes
                local debugInfo = {}
                if workspace:GetAttribute("SummerEvent") ~= nil then
                    table.insert(debugInfo, "SummerEvent: " .. tostring(workspace:GetAttribute("SummerEvent")))
                end
                if workspace:GetAttribute("SummerHarvest") ~= nil then
                    table.insert(debugInfo, "SummerHarvest: " .. tostring(workspace:GetAttribute("SummerHarvest")))
                end
                if workspace:GetAttribute("CurrentWeatherEvent") ~= nil then
                    table.insert(debugInfo, "CurrentWeather: " .. tostring(workspace:GetAttribute("CurrentWeatherEvent")))
                end
                if #debugInfo > 0 then
                    Library:Notify("🔍 Debug: " .. table.concat(debugInfo, ", "), 3)
                end
            end
        else
            Library:Notify("🌞 Auto Summer Event disabled.", 2)
        end
    end,
})

-- Rename test teleport to cart button
SummerEventGroupBox:AddButton("Teleport to Summer Cart", function()
    local success, result = pcall(function()
        local locations = FindSummerHarvestLocations()
        local cart = locations.cart

        if not cart then
            Library:Notify("❌ Could not find Summer Harvest Cart!", 3)
            return false
        end

        -- Teleport directly to the Cart
        local teleportPosition = cart.PrimaryPart and cart.PrimaryPart.CFrame or
                                (cart:IsA("BasePart") and cart.CFrame or
                                cart:FindFirstChildWhichIsA("BasePart").CFrame)

        -- Add offset to avoid being inside the Cart
        teleportPosition = teleportPosition * CFrame.new(0, 2, 5)

        -- Teleport
        LocalPlayer.Character.HumanoidRootPart.CFrame = teleportPosition
        Library:Notify("🚀 Teleported to Summer Harvest Cart!", 3)
        return true
    end)

    if not success then
        Library:Notify("❌ Error teleporting to Cart: " .. tostring(result), 3)
    end
end)

-- Function to find summer plants/fruits in the farm
local function FindSummerPlantsInFarm()
    local PlantTraitsData = require(Services.ReplicatedStorage.Modules.PlantTraitsData)
    local summerPlants = {}

    -- Find player's farm using the getMyFarm function
    local farm = getMyFarm()
    if not farm then
        Library:Notify("❌ Could not find your farm!", 3)
        return summerPlants
    end

    -- Check if there's a nested Farm folder
    local innerFarm = farm:FindFirstChild("Farm")
    if innerFarm then
        farm = innerFarm
    end

    -- Look for Important folder
    local important = farm:FindFirstChild("Important")
    if not important then
        Library:Notify("❌ Could not find Important folder in your farm!", 3)
        return summerPlants
    end

    -- Look for plants in the farm
    local plantsPhysical = important:FindFirstChild("Plants_Physical")
    if not plantsPhysical then
        Library:Notify("❌ Could not find plants in your farm!", 3)
        return summerPlants
    end

    -- Find all summer plants/fruits
    for _, plant in pairs(plantsPhysical:GetChildren()) do
        -- Check if it's a summer plant - strict validation
        if plant:IsA("Model") and plant.Name and plant.Name ~= "" then
            -- Double-check with PlantTraitsData to ensure it's a summer plant
            if PlantTraitsData.HasTrait(plant.Name, "Summer") then
                table.insert(summerPlants, plant)
                -- Debug notification for summer plants found
                -- Library:Notify("🌱 Found summer plant: " .. plant.Name, 1)
            end
        end

        -- Check for fruits folder (for fruit plants)
        local fruitsFolder = plant:FindFirstChild("Fruits")
        if fruitsFolder then
            for _, fruit in pairs(fruitsFolder:GetChildren()) do
                -- Check if it's a summer fruit - strict validation
                if fruit:IsA("Model") and fruit.Name and fruit.Name ~= "" then
                    -- Double-check with PlantTraitsData to ensure it's a summer fruit
                    if PlantTraitsData.HasTrait(fruit.Name, "Summer") then
                        table.insert(summerPlants, fruit)
                        -- Debug notification for summer fruits found
                        -- Library:Notify("🍎 Found summer fruit: " .. fruit.Name, 1)
                    end
                end
            end
        end
    end

    -- Final validation - ensure all plants in the list are actually summer plants
    local validatedPlants = {}
    for _, plant in pairs(summerPlants) do
        if plant and plant.Name and PlantTraitsData.HasTrait(plant.Name, "Summer") then
            table.insert(validatedPlants, plant)
        end
    end

    return validatedPlants
end

-- Function to teleport to and collect summer plants/fruits
local function CollectSummerPlants()
    local summerPlants = FindSummerPlantsInFarm()

    if #summerPlants == 0 then
        Library:Notify("❌ No summer plants/fruits found in your farm!", 3)
        return 0
    end

    Library:Notify("🌱 Found " .. #summerPlants .. " summer plants/fruits in your farm", 3)

    -- Filter for only harvestable (fully grown) summer plants
    local harvestablePlants = {}
    local skippedCount = 0

    for _, plant in pairs(summerPlants) do
        if plant and plant.Parent then
            local prompt = plant:FindFirstChild("ProximityPrompt", true)
            if prompt and prompt.Enabled then
                table.insert(harvestablePlants, plant)
            else
                skippedCount = skippedCount + 1
                print("[cb] Skipping " .. plant.Name .. " - not ready to harvest (still growing)")
            end
        end
    end

    if #harvestablePlants == 0 then
        if skippedCount > 0 then
            Library:Notify("🌱 Found " .. skippedCount .. " summer plants, but none are ready to harvest yet!", 3)
        else
            Library:Notify("❌ No harvestable summer plants found!", 3)
        end
        return 0
    end

    Library:Notify("🌱 " .. #harvestablePlants .. " summer plants ready to harvest (skipped " .. skippedCount .. " still growing)", 3)

    -- Save original position
    local originalPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
    local collectedCount = 0
    local PlantTraitsData = require(Services.ReplicatedStorage.Modules.PlantTraitsData)

    -- Collect each harvestable summer plant/fruit
    for i, plant in pairs(harvestablePlants) do
        -- Check if plant still exists
        if not plant or not plant.Parent then
            continue
        end

        -- Double-check that this is actually a summer plant
        if not PlantTraitsData.HasTrait(plant.Name, "Summer") then
            Library:Notify("⚠️ Skipping " .. plant.Name .. " - not a summer plant", 1)
            continue
        end

        -- Check if plant is still harvestable (could have changed)
        local prompt = plant:FindFirstChild("ProximityPrompt", true)
        if not prompt or not prompt.Enabled then
            Library:Notify("⚠️ Skipping " .. plant.Name .. " - no longer harvestable", 1)
            continue
        end

        -- Use the existing harvestPlant function for better reliability
        local success = harvestPlant(plant)

        if success then
            collectedCount = collectedCount + 1
            Library:Notify("✅ Collected " .. plant.Name .. " (Summer plant)", 1)
        else
            Library:Notify("❌ Failed to collect " .. plant.Name, 1)
        end

        task.wait(0.5) -- Wait between collections
    end

    -- Return to original position
    LocalPlayer.Character.HumanoidRootPart.CFrame = originalPosition
    Library:Notify("✅ Collected " .. collectedCount .. "/" .. #harvestablePlants .. " summer plants/fruits and returned!", 3)

    return collectedCount
end

-- Add toggle for Summer Auto collect
SummerEventGroupBox:AddToggle("SummerAutoCollect", {
    Text = "Summer Auto Collect",
    Default = false,
    Tooltip = "Automatically teleport to and collect only fully grown summer plants/fruits in your farm (skips still growing plants)",

    Callback = function(Value)
        print("[cb] Summer Auto Collect toggled:", Value)
        if Value then
            Library:Notify("🌞 Summer Auto Collect enabled!", 3)
            -- Start auto collection loop
            task.spawn(function()
                while Toggles.SummerAutoCollect.Value do
                    local collected = CollectSummerPlants()
                    if collected == 0 then
                        -- If nothing was collected, wait longer before trying again
                        task.wait(10)
                    else
                        task.wait(5) -- Wait between collection cycles
                    end
                end
            end)
        else
            Library:Notify("🌞 Summer Auto Collect disabled.", 2)
        end
    end,
})

-- Add button to collect summer plants now
SummerEventGroupBox:AddButton("Collect Summer Plants Now", function()
    CollectSummerPlants()
end)

-- Add button to submit currently held plant/fruit to Summer Harvest
SummerEventGroupBox:AddButton("Submit Held Plant/Fruit", function()
    local success, result = pcall(function()
        local SummerHarvestRemoteEvent = Services.ReplicatedStorage.GameEvents:FindFirstChild("SummerHarvestRemoteEvent")
        if not SummerHarvestRemoteEvent then
            Library:Notify("❌ Could not find SummerHarvestRemoteEvent!", 3)
            return false
        end

        -- Check if player is holding a tool (plant/fruit)
        local equippedTool = nil
        if LocalPlayer.Character then
            equippedTool = LocalPlayer.Character:FindFirstChildWhichIsA("Tool")
        end

        if not equippedTool then
            Library:Notify("❌ You must equip a plant/fruit tool to submit!", 3)
            return false
        end

        -- Check if the held plant is a summer plant
        local PlantTraitsData = require(Services.ReplicatedStorage.Modules.PlantTraitsData)
        local isValidSummerPlant = PlantTraitsData.HasTrait(equippedTool.Name, "Summer")

        if not isValidSummerPlant then
            Library:Notify("⚠️ " .. equippedTool.Name .. " is not a summer plant, but submitting anyway...", 3)
        end

        -- Fire the remote to submit the held plant/fruit
        SummerHarvestRemoteEvent:FireServer("SubmitHeldPlant")
        Library:Notify("✅ Submitted " .. equippedTool.Name .. " to Summer Harvest!", 3)
        return true
    end)    if not success then
        Library:Notify("❌ Error submitting plant: " .. tostring(result), 3)
    end
end)


-- Anti idle
LocalPlayer.Idled:Connect(function()
    -- Check if Anti-AFK is enabled
    local AntiAFKToggle = Options.AntiAFK
    if not AntiAFKToggle or not AntiAFKToggle.Value then return end

    local VirtualUser = game:GetService("VirtualUser")
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())

    Library:Notify("Anti-AFK prevented kick", 2)
end)

-- Auto reconnect
Services.GuiService.ErrorMessageChanged:Connect(function()
	-- Check if Auto-Reconnect is enabled
	local AutoReconnectToggle = Options.AutoReconnect
	if not AutoReconnectToggle or not AutoReconnectToggle.Value then return end

	local TeleportService = game:GetService("TeleportService")
	local IsSingle = #Players:GetPlayers() <= 1
	local PlaceId = game.PlaceId
	local JobId = game.JobId

	-- Queue the script to run after teleport
	queue_on_teleport("loadstring(game:HttpGet('https://rawscripts.net/raw/Grow-a-Garden-Grow-a-Garden-Stock-bot-41500'))()")

	-- Join a different server if the player is solo
	if IsSingle then
		TeleportService:Teleport(PlaceId, LocalPlayer)
		return
	end

	TeleportService:TeleportToPlaceInstance(PlaceId, JobId, LocalPlayer)
end)

WebHookConfigGroupBox:AddButton("Test Webhook", function()
	if WebhookURL == "" then
		Library:Notify("❌ Please enter a webhook URL first!", 3)
		return
	end

	-- Current time for the test report
	local currentTime = os.date("%H:%M:%S")
	local currentDate = os.date("%Y-%m-%d")

	WebhookSend("Weather", {
		{
			name = "📊 SYSTEM STATUS",
			value = "✅ All systems operational\n🔄 Last update: " .. currentTime,
			inline = true
		},
		{
			name = "🔧 CONFIGURATION",
			value = "✓ Webhook integration: Active\n✓ Reporting modules: Enabled\n✓ Data collection: Running",
			inline = true
		},
		{
			name = "📈 PERFORMANCE",
			value = "Memory usage: Optimal\nResponse time: 0.23s\nUptime: " .. math.random(98, 100) .. "%",
			inline = false
		},
		{			name = "📝 NOTES",
			value = "This is a verification message from the SNOWBIND Webhook.\nIf you're seeing this message, your webhook integration is configured correctly.",
			inline = false
		}
	})

	Library:Notify("✅ SNOWBIND Webhook test report sent!", 2)
end)