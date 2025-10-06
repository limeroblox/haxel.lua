--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works



local FeaturesSection = Window:Section({ Title = "Features", Opened = true })
local SettingsSection = Window:Section({ Title = "Settings", Opened = true })
local UtilitiesSection = Window:Section({ Title = "Utilities", Opened = true })


local CombatTab     = FeaturesSection:Tab({ Title = "Combat" })
local VisualsTab    = FeaturesSection:Tab({ Title = "Visuals" })
local MiscTab       = FeaturesSection:Tab({ Title = "Misc" })

local AppearanceTab = SettingsSection:Tab({ Title = "Appearance" })
local ConfigTab     = UtilitiesSection:Tab({ Title = "Configuration" })



-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
