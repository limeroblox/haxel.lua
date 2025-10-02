-- Using WindUi Cuz I like it :p
-- Also as they said, do not edit the main src from there, you will probably fuck it up.
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Localization:
local Localization = WindUI:Localization({
    Enabled = true,
    Prefix = "loc:",
    DefaultLanguage = "en",
    Translations = {
        ["en/es"] = {
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
        }
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
