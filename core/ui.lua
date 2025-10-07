--[[

This is UI-related content only.
It does not include any game-specific elements.

]]
-- Using WindUi Cuz I like it :p
-- Also as they said, do not edit the main src from there.

local HaxelUI                   = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Localization = HaxelUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en", -- Change if you want
    Translations = {
        ["en"] = {
            ["TITLE"]           = "Haxel.lua",
            ["ICON"]            = 'https://m.gjcdn.net/fireside-post-image/500/30447234-mpufxi8n-v4.webp',
            ["AUTHOR"]          = "@haxel.py",
            ["DESC"]            = "Multi-Game Script :D",
            ["SETTINGS"]        = "Settings",
            ["APPEARANCE"]      = "Appearance",
            ["FEATURES"]        = "Features",
            ["UTILITIES"]       = "Utilities",
            ["UI_ELEMENTS"]     = "UI Elements",
            ["CONFIGURATION"]   = "Configuration",
            ["SAVE_CONFIG"]     = "Save Configuration",
            ["LOAD_CONFIG"]     = "Load Configuration",
            ["THEME_SELECT"]    = "Select Theme",
            ["TRANSPARENCY"]    = "Window Transparency",
            ["LOCKED_TAB"]      = "In Development"
        },
        ["ru"] = {
            ["TITLE"]           = "Haxel.lua",
            ["ICON"]            = 'https://m.gjcdn.net/fireside-post-image/500/30447234-mpufxi8n-v4.webp',
            ["AUTHOR"]          = "@haxel.py",
            ["DESC"]            = "Мультигеймовый скрипт :D",
            ["SETTINGS"]        = "Настройки",
            ["APPEARANCE"]      = "Внешний вид",
            ["FEATURES"]        = "Функции",
            ["UTILITIES"]       = "Утилиты",
            ["UI_ELEMENTS"]     = "Элементы интерфейса",
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
    Title = "loc:TITLE",
    Icon = "loc:ICON",
    Author = "loc:AUTHOR",
    Description = "loc:DESC",
    Folder = "Haxel.lua",
    User = {
        Enabled = true
    },
})

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local tag = Window:Tag({
    Title = "DEV - v0.1",
    Color = HaxelUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#007BFF"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#30FF6A"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
})

local colorSequence = {
    "#007BFF", -- blue
    "#30FF6A", -- green
    "#E7FF2F", -- yellow
    "#FF0F7B", -- pink
    "#F89B29", -- orange
    "#8A2BE2", -- purple
    "#00FFFF", -- cyan
    "#007BFF", -- loop back to blue
}

-- get interpolated colors
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
    -- both stops move forward for smooth vibe
    return startColor:Lerp(endColor, t), startColor:Lerp(endColor, t)
end

-- animate gradient & rotation continuously
local function AnimateGradient()
    local progress = 0
    local rotation = 0
    local cycleDuration = 16 -- seconds per full color cycle
    local rotationDuration = 14 -- seconds per full rotation

    RunService.RenderStepped:Connect(function(dt)
        progress = (progress + dt / cycleDuration) % 1
        rotation = (rotation + dt / rotationDuration * 360) % 360

        local c0, c1 = GetInterpolatedColors(progress)
        tag:SetColor(HaxelUI:Gradient({
            ["0"]   = { Color = c0, Transparency = 0 },
            ["100"] = { Color = c1, Transparency = 0 },
        }, {
            Rotation = rotation,
        }))
    end)
end

AnimateGradient()

-- Game stuff would go here I guess :P
