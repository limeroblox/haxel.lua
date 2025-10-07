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

-- dynamic gradient + rotation tween
local function AnimateGradient(startHex, endHex, duration)
    local startColor = Color3.fromHex(startHex)
    local endColor = Color3.fromHex(endHex)
    local fade = Instance.new("NumberValue")
    fade.Value = 0

    -- create a smooth tween for color fading
    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Quad, -- smoother easing for color transitions
        Enum.EasingDirection.InOut,
        0, -- no repeat
        true -- reverse for a back-and-forth effect
    )
    local tween = TweenService:Create(fade, tweenInfo, { Value = 1 })

    -- create a continuous rotation tween
    local rotationValue = Instance.new("NumberValue")
    rotationValue.Value = math.random(0, 360)
    local rotationTween = TweenService:Create(
        rotationValue,
        TweenInfo.new(duration * 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
        { Value = rotationValue.Value + 360 }
    )

    -- update gradient on value change
    fade:GetPropertyChangedSignal("Value"):Connect(function()
        local mixed0 = startColor:Lerp(endColor, fade.Value)
        local mixed1 = endColor:Lerp(startColor, fade.Value)

        tag:SetColor(HaxelUI:Gradient({
            ["0"]   = { Color = mixed0, Transparency = 0 },
            ["100"] = { Color = mixed1, Transparency = 0 },
        }, {
            Rotation = rotationValue.Value,
        }))
    end)

    -- start both tweens
    tween:Play()
    rotationTween:Play()

    -- cleanup
    tween.Completed:Connect(function()
        fade:Destroy()
        rotationValue:Destroy()
    end)
end

-- continuous cycle with varied timing
task.spawn(function()
    while true do
        for _, pair in ipairs(colorCycles) do
            local duration = 2 + math.random() * 2 -- random duration between 2 and 4 seconds
            AnimateGradient(pair[1], pair[2], duration)
            task.wait(duration + 0.5) -- slight pause between cycles
        end
    end
end)

-- Game stuff would go here I guess :P
