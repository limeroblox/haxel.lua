--[[

MAIN UI

]]

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

-- Place Holders to see if this method works

local Sections = {
    Main = Window:Section({ Title = "Main", Opened = true }),
    Visuals = Window:Section({ Title = "Visuals", Opened = true }),
    Movement = Window:Section({ Title = "Movement", Opened = true }),
    Misc = Window:Section({ Title = "Misc", Opened = true }),
    Settings = Window:Section({ Title = "Settings", Opened = true }), -- MADE BY DEFAULT
}


local Tabs = {
    Elements = Sections.Main:Tab({ Title = "loc:UI_ELEMENTS", Icon = "layout-grid", Desc = "UI Elements Example" }),
    Appearance = Sections.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Sections.Utilities:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" }),
}
