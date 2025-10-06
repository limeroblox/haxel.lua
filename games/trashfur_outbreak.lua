--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

-- Translation helper
local function Translate(key)
    key = key:gsub("^loc:", "") -- remove prefix if present
    return Localization.Translations[lang][key] or key
end

-- Tabs
local CombatTab     = Window:CreateTab(Translate("loc:COMBAT"))
local VisualsTab    = Window:CreateTab(Translate("loc:VISUALS"))
local MiscTab       = Window:CreateTab(Translate("loc:MISC"))
local AppearanceTab = Window:CreateTab(Translate("loc:APPEARANCE"))
local ConfigTab     = Window:CreateTab(Translate("loc:CONFIG"))


-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
