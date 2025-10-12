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

Window:SetIconSize(24)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local tag = Window:Tag({
    Title = "DEV",
    Color = HaxelUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#000000ff"), Transparency = 0 }, 
        ["100"] = { Color = Color3.fromHex("#000000ff"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
})

local colorSequence = {
    "#000000FF",
    "#111111FF",
    "#222222FF",
    "#333333FF",
    "#444444FF",
    "#555555FF",
    "#666666FF",
    "#777777FF",
    "#888888FF",
    "#999999FF",
    "#AAAAAAFF",
    "#BBBBBBFF",
    "#CCCCCCFF",
    "#DDDDDDFF",
    "#EEEEEEFF",
    "#FFFFFFFF", 
    "#EEEEEEFF",
    "#DDDDDDFF",
    "#CCCCCCFF",
    "#BBBBBBFF",
    "#AAAAAAFF",
    "#999999FF",
    "#888888FF",
    "#777777FF",
    "#666666FF",
    "#555555FF",
    "#444444FF",
    "#333333FF",
    "#222222FF",
    "#111111FF",
    "#000000FF", 
}



local function GetInterpolatedColors(progress)
    local totalSegments = #colorSequence - 1
    local scaledProgress = progress * totalSegments
    local index = math.floor(scaledProgress) + 1
    local t = scaledProgress % 1

    if index >= #colorSequence then
        index = #colorSequence - 1
        t = 1
    end

    local startColor = Color3.fromHex(colorSequence[index])
    local endColor = Color3.fromHex(colorSequence[index + 1])
    return startColor:Lerp(endColor, t), startColor:Lerp(endColor, t)
end

local function AnimateGradient()
    local progress = 0
    local rotation = 0
    local cycleDuration = 16
    local rotationDuration = 14

    RunService.RenderStepped:Connect(function(dt)
        progress = (progress + dt / cycleDuration) % 1
        rotation = (rotation + dt / rotationDuration * 360) % 360

        local c0, c1 = GetInterpolatedColors(progress)
        tag:SetColor(HaxelUI:Gradient({
            ["0"]   = { Color = c0, Transparency = 0 },
            ["100"] = { Color = c1, Transparency = 0 },
        }, { Rotation = rotation }))
    end)
end

AnimateGradient()
-- Game stuff would go here I guess :P
