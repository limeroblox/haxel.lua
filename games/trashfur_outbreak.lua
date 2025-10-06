--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

local Sections = {
  FeaturesSection   = Window:Section({ Title = "Features", Opened = true })
  SettingsSection   = Window:Section({ Title = "Settings", Opened = true })
  UtilitiesSection  = Window:Section({ Title = "Utilities", Opened = true })
}


local Tabs = {
  CombatTab     = Sections.FeaturesSection:Tab({ Title = "Combat" })
  VisualsTab    = Sections.FeaturesSection:Tab({ Title = "Visuals" })
  MiscTab       = Sections.FeaturesSection:Tab({ Title = "Misc" })
  
  AppearanceTab = SettingsSection:Tab({ Title = "Appearance" })
  ConfigTab     = UtilitiesSection:Tab({ Title = "Configuration" })
}

-- === Managers===
local ThemeManager = WindUI:CreateThemeManager(Window)
local ConfigManager = WindUI:CreateConfigManager(Window)
ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
