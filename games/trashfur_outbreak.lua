--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

-- Tabs
local CombatTab     = Window:CreateTab("Combat")
local VisualsTab    = Window:CreateTab("Visuals")
local MiscTab       = Window:CreateTab("Misc")
local AppearanceTab = Window:CreateTab("Appearance")
local ConfigTab     = Window:CreateTab("Configuration")


-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
