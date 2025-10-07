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
        ["100"] = { Color = Color3.fromHex("#FFFFFF"), Transparency = 0 },
    }, {
        Rotation = 45,
    }),
})

-- define gradient color cycles
local colorCycles = {
    { "#007BFF", "#FFFFFF" }, -- blue to white
    { "#30FF6A", "#E7FF2F" }, -- green to yellow
    { "#FF0F7B", "#F89B29" }, -- pink to orange
    { "#8A2BE2", "#00FFFF" }, -- purple to cyan
}

-- dynamic gradient + rotation tween
local function AnimateGradient(startHex, endHex, duration)
    local startColor = Color3.fromHex(startHex)
    local endColor = Color3.fromHex(endHex)
    local fade = Instance.new("NumberValue")
    fade.Value = 0

    local tween = TweenService:Create(
        fade,
        TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        { Value = 1 }
    )

    tween:Play()

    -- pick a random rotation for some motion
    local rotation = math.random(0, 360)

    fade:GetPropertyChangedSignal("Value"):Connect(function()
        local mixed0 = startColor:Lerp(endColor, fade.Value)
        local mixed1 = endColor:Lerp(startColor, fade.Value)

        tag:SetColor(HaxelUI:Gradient({
            ["0"]   = { Color = mixed0, Transparency = 0 },
            ["100"] = { Color = mixed1, Transparency = 0 },
        }, {
            Rotation = rotation,
        }))
    end)

    tween.Completed:Connect(function()
        fade:Destroy()
    end)
end

-- continuous cycle
task.spawn(function()
    while true do
        for _, pair in ipairs(colorCycles) do
            AnimateGradient(pair[1], pair[2], 3 + math.random())
            task.wait(3.5)
        end
    end
end)


-- Game stuff would go here I guess :P
