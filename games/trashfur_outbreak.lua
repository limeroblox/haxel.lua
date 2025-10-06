--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

-- Tabs
local CombatTab     = Window:CreateTab(Localization.Translations[lang]["COMBAT"])
local VisualsTab    = Window:CreateTab(Localization.Translations[lang]["VISUALS"])
local MiscTab       = Window:CreateTab(Localization.Translations[lang]["MISC"])
local AppearanceTab = Window:CreateTab(Localization.Translations[lang]["APPEARANCE"])
local ConfigTab     = Window:CreateTab(Localization.Translations[lang]["CONFIG"])


-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
