--[[

This is UI-related content only.
It does not include any game-specific elements.

]]

local repo 			= "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/" 
local Library 		= loadstring(game:HttpGet(repo .. "Library.lua"))() 
local ThemeManager 	= loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))() 
local SaveManager 	= loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options 		= Library.Options
local Toggles 		= Library.Toggles
Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true -- Make toggle keybinds work inside the keybinds UI (aka adds a toggle to the UI). Good for mobile users (Default value = true)
local Window = Library:CreateWindow({
  AutoShow = true,
  MobileButtonsSide = "Left",
  Center = true,
	Title = "MeowWare.lua",
	Footer = "VER: 0.0.1 [DEV]",
	Icon = 95816097006870, 
	NotifySide = "Right",
	ShowCustomCursor = false,
})
