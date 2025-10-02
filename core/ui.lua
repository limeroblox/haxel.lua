--[[

This is UI-related content only.
It does not include any game-specific elements.

]]
-- Using WindUi Cuz I like it :p
-- Also as they said, do not edit the main src from there, you will probably fuck it up.
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Localization:
local Localization = WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = ({["en-us"]="en",["en-gb"]="en",["es-es"]="es",["es-mx"]="es",["ru-ru"]="ru"})[(game:GetService("Players").LocalPlayer.LocaleId:lower())] or "en",
    Translations = {
        ["en"] = {
            ["HAXEL_TITLE"] = "Haxel.lua",
            ["WELCOME"] = "Hallo :}",
            ["LIB_DESC"] = "Game Based Script (uhh IFRIHFROUBF)",
            ["COMBAT"] = "Combat",
            ["VISUALS"] = "Visuals",
            ["MISC"] = "Misc",
            ["APPEARANCE"] = "Appearance",
            ["CONFIG"] = "Configuration",
            ["LOCKED"] = "Locked Tabs",
            ["SETTINGS"] = "Settings",
            ["UTILITIES"] = "Utilities",
            ["THEME_MANAGE"] = "Theme Manager",
            ["SAVE_CONFIG"] = "Save Configuration",
            ["LOAD_CONFIG"] = "Load Configuration",
            ["TRANSPARENCY"] = "Window Transparency"
        },
        ["es"] = {
            ["HAXEL_TITLE"] = "Haxel.lua",
            ["WELCOME"] = "Hola :}",
            ["LIB_DESC"] = "Script basado en juegos (uhh IFRIHFROUBF)",
            ["COMBAT"] = "Combate",
            ["VISUALS"] = "Visuales",
            ["MISC"] = "Misceláneo",
            ["APPEARANCE"] = "Apariencia",
            ["CONFIG"] = "Configuración",
            ["LOCKED"] = "Pestañas bloqueadas",
            ["SETTINGS"] = "Ajustes",
            ["UTILITIES"] = "Utilidades",
            ["THEME_MANAGE"] = "Gestor de temas",
            ["SAVE_CONFIG"] = "Guardar configuración",
            ["LOAD_CONFIG"] = "Cargar configuración",
            ["TRANSPARENCY"] = "Transparencia de ventana"
        },
        ["ru"] = {
            ["HAXEL_TITLE"] = "Haxel.lua",
            ["WELCOME"] = "Привет :}",
            ["LIB_DESC"] = "Игровой скрипт (ну типа IFRIHFROUBF)",
            ["COMBAT"] = "Бой",
            ["VISUALS"] = "Визуал",
            ["MISC"] = "Разное",
            ["APPEARANCE"] = "Внешний вид",
            ["CONFIG"] = "Конфигурация",
            ["LOCKED"] = "Закрытые вкладки",
            ["SETTINGS"] = "Настройки",
            ["UTILITIES"] = "Утилиты",
            ["THEME_MANAGE"] = "Менеджер тем",
            ["SAVE_CONFIG"] = "Сохранить конфигурацию",
            ["LOAD_CONFIG"] = "Загрузить конфигурацию",
            ["TRANSPARENCY"] = "Прозрачность окна"
        }
    }
})

-- Game stuff would go here I guess :P
