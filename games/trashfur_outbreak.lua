--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works


local MainSection = Window:Section({ Title = "Features", Opened = true })

local CombatTab     = MainSection:Tab({ Title = "Combat" })
local VisualsTab    = MainSection:Tab({ Title = "Visuals" })
local MiscTab       = MainSection:Tab({ Title = "Misc" })
local AppearanceTab = MainSection:Tab({ Title = "Appearance" })
local ConfigTab     = MainSection:Tab({ Title = "Configuration" })



-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
