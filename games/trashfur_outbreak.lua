--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

-- Tabs
local CombatTab = Window:CreateTab(Localization:Translate("loc:COMBAT"))
local VisualsTab = Window:CreateTab(Localization:Translate("loc:VISUALS"))
local MiscTab = Window:CreateTab(Localization:Translate("loc:MISC"))
local AppearanceTab = Window:CreateTab(Localization:Translate("loc:APPEARANCE"))
local ConfigTab = Window:CreateTab(Localization:Translate("loc:CONFIG"))


-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
