local repo 			= "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/" 
local Library 		= loadstring(game:HttpGet(repo .. "Library.lua"))() 
local ThemeManager 	= loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))() 
local SaveManager 	= loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options 		= Library.Options
local Toggles 		= Library.Toggles
local Ver 			= loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/meowware.lua/refs/heads/main/core/version.txt"))()
local Version 		= "MeowWare.lua | " .. Ver
Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true 

-- [[ Ui Based ]] --

-- [START OF FUNCTIONS] --

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function grace()
  
end

local function grace2()
  
end

local hbGrace1, hbGrace2

-- [END OF FUNCTIONS] --

local Window = Library:CreateWindow({
  AutoShow = true,
  MobileButtonsSide = "Left",
  Center = true,
	Title = "Grace",
	Footer = Version,
	Icon = 84903466827078,
	NotifySide = "Right",
	ShowCustomCursor = false,
})
