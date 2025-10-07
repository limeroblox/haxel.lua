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

local tag = Window:Tag({
    Title = "DEV - v0.1",
    Color = HaxelUI:Gradient({
        ["0"]   = { Color = Color3.fromHex("#007BFF"), Transparency = 0 },
        ["100"] = { Color = Color3.fromHex("#30FF6A"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
})

-- define gradient color cycles with visually appealing pairs
local colorCycles = {
    { "#007BFF", "#30FF6A" }, -- blue to green
    { "#30FF6A", "#E7FF2F" }, -- green to yellow
    { "#E7FF2F", "#FF0F7B" }, -- yellow to pink
    { "#FF0F7B", "#F89B29" }, -- pink to orange
    { "#F89B29", "#8A2BE2" }, -- orange to purple
    { "#8A2BE2", "#00FFFF" }, -- purple to cyan
    { "#00FFFF", "#007BFF" }, -- cyan to blue (loop back)
}

-- function to get interpolated color pair based on progress
local function GetInterpolatedColors(progress)
    local totalPairs = #colorCycles
    local pairIndex = math.floor(progress * totalPairs) + 1
    local pairProgress = (progress * totalPairs) % 1

    -- handle wrap-around for seamless looping
    if pairIndex > totalPairs then
        pairIndex = 1
    end

    local startHex = colorCycles[pairIndex][1]
    local endHex = colorCycles[pairIndex][2]
    local startColor = Color3.fromHex(startHex)
    local endColor = Color3.fromHex(endHex)

    -- interpolate between the start and end colors of the current pair
    local mixed0 = startColor:Lerp(endColor, pairProgress)
    local mixed1 = endColor:Lerp(startColor, pairProgress)

    return mixed0, mixed1
end

-- dynamic gradient + rotation tween
local function AnimateGradient()
    local progress = Instance.new("NumberValue")
    progress.Value = 0

    -- create a smooth tween for color fading
    local tweenInfo = TweenInfo.new(
        20, -- total duration for one full cycle through all colors
        Enum.EasingStyle.Quad, -- smooth easing
        Enum.EasingDirection.InOut,
        -1, -- infinite repeat
        true -- reverse for back-and-forth effect
    )
    local tween = TweenService:Create(progress, tweenInfo, { Value = 1 })

    -- create a continuous rotation tween
    local rotationValue = Instance.new("NumberValue")
    rotationValue.Value = 0
    local rotationTween = TweenService:Create(
        rotationValue,
        TweenInfo.new(10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Value = 360 }
    )

    -- update gradient on progress change
    progress:GetPropertyChangedSignal("Value"):Connect(function()
        local color0, color1 = GetInterpolatedColors(progress.Value)
        tag:SetColor(HaxelUI:Gradient({
            ["0"]   = { Color = color0, Transparency = 0 },
            ["100"] = { Color = color1, Transparency = 0 },
        }, {
            Rotation = rotationValue.Value,
        }))
    end)

    -- start both tweens
    tween:Play()
    rotationTween:Play()

    -- cleanup (optional, since tweens are infinite)
    return function()
        tween:Cancel()
        rotationTween:Cancel()
        progress:Destroy()
        rotationValue:Destroy()
    end
end

-- start the continuous animation
task.spawn(function()
    local cleanup = AnimateGradient()
    -- keep the task running indefinitely
    while true do
        task.wait(1)
    end
end)

-- Game stuff would go here I guess :P
