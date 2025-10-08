--[[

This is UI-related content only.
It does not include any game-specific elements.

]]
-- Using WindUi Cuz I like it :p
-- Also as they said, do not edit the main src from there.

local HaxelUI                   = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local defLang = "en"

local Localization = HaxelUI:Localization({
    Enabled = true, -- if true, it will enable loclization, very helpful for non-english users.
    Prefix = "loc:",
    DefaultLanguage = defLang, -- Changes with the localization setting in settings (In all game based scripts)
    Translations = {
        ["en"] = {
            ["TITLE"]           = "Haxel.lua",
            ["AUTHOR"]          = "@haxel.py",
            ["DESC"]            = "Multi-Game Script",
            ["SETTINGS"]        = "Settings",
            ["APPEARANCE"]      = "Appearance",
            ["CONFIGURATION"]   = "Configuration",
            ["SAVE_CONFIG"]     = "Save Configuration",
            ["LOAD_CONFIG"]     = "Load Configuration",
            ["THEME_SELECT"]    = "Select Theme",
            ["TRANSPARENCY"]    = "Window Transparency",
            ["LOCKED_TAB"]      = "In Development"
        },
        ["ru"] = {
            ["TITLE"]           = "Haxel.lua",
            ["AUTHOR"]          = "@haxel.py",
            ["DESC"]            = "Мультигеймовый скрипт",
            ["SETTINGS"]        = "Настройки",
            ["APPEARANCE"]      = "Внешний вид",
            ["CONFIGURATION"]   = "Конфигурация",
            ["SAVE_CONFIG"]     = "Сохранить конфиг",
            ["LOAD_CONFIG"]     = "Загрузить конфиг",
            ["THEME_SELECT"]    = "Выбрать тему",
            ["TRANSPARENCY"]    = "Прозрачность окна",
            ["LOCKED_TAB"]      = "В разработке"
        }
    }
})


-- Window setup
local Window = HaxelUI:CreateWindow({
    Title                       = "loc:TITLE",
    Icon                        = "https://itaku.ee/api/media/gallery_imgs/nikoty_FG55uER/xl.jpg", -- Icon localization not needed, I guess :P, also why is some nsfw, like wth man :(
    Author                      = "loc:AUTHOR",
    Description                 = "loc:DESC",
    Folder                      = "Haxel.lua",
    User = {
        Enabled                 = true
    },
})

Window:Tag({
    Title = "DEV",
    Color = Color3.fromHex("#0004ffff")
})

-- Game stuff would go here I guess :P
