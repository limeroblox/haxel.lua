--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

local Sections = {
    Main = Window:Section({ Title = "loc:FEATURES", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
    Utilities = Window:Section({ Title = "loc:UTILITIES", Opened = true }),
}


local Tabs = {
    Elements = Sections.Main:Tab({ Title = "loc:UI_ELEMENTS", Icon = "layout-grid", Desc = "UI Elements Example" }),
    Appearance = Sections.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Sections.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" }),
    LockedTab1 = Window:Tab({ Title = "loc:LOCKED_TAB", Icon = "bird", Locked = true, }),
    LockedTab2 = Window:Tab({ Title = "loc:LOCKED_TAB", Icon = "bird", Locked = true, }),
    LockedTab3 = Window:Tab({ Title = "loc:LOCKED_TAB", Icon = "bird", Locked = true, }),
    LockedTab4 = Window:Tab({ Title = "loc:LOCKED_TAB", Icon = "bird", Locked = true, }),
    LockedTab5 = Window:Tab({ Title = "loc:LOCKED_TAB", Icon = "bird", Locked = true, }),
}



ThemeManager:SetFolder("Haxel/Themes")
ConfigManager:SetFolder("Haxel/Configs")

ConfigManager:Load()
