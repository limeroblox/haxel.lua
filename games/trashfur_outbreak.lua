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
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }), -- MADE BY DEFAULT
}


local Tabs = {
    Aimbot = Sections.Main:Tab({ Title = "Aimbot", Icon = "crosshair" }), 
    Appearance = Sections.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Sections.Settings:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" }),
}

local AimbotElements = {
    Tabs.Aimbot:Section({
    Title = "Aimbot with seperate body targeting (head & torso)",
    TextSize = 20,
    }),
    Tabs.Aimbot:Toggle({
        Title = "Enable",
        Desc  = "Enable Aimbot :P",
        Value = false,
        Callback = function(state)
            print("not done yet :P")
        end
    })
}
