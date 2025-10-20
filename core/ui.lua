--[[

This is UI-related content only.
It does not include any game-specific elements.

]]

-- Using WindUi Cuz I like it :p

-- Also as they said, do not edit the main src from there.

local HaxelUI                   = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local defLang = "en"

local Localization = HaxelUI:Localization({
    Enabled = true,            -- Enable localization for non-English users
    Prefix = "loc:",
    DefaultLanguage = defLang, -- Default language setting
    Translations = {
        ["en"] = { -- English
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
        ["es"] = { -- Spanish
            ["DESC"]            = "Script multijuego",
            ["SETTINGS"]        = "Configuración",
            ["APPEARANCE"]      = "Apariencia",
            ["CONFIGURATION"]   = "Ajustes",
            ["SAVE_CONFIG"]     = "Guardar configuración",
            ["LOAD_CONFIG"]     = "Cargar configuración",
            ["THEME_SELECT"]    = "Seleccionar tema",
            ["TRANSPARENCY"]    = "Transparencia de ventana",
            ["LOCKED_TAB"]      = "En desarrollo"
        },
        ["ru"] = { -- Russian
            ["DESC"]            = "Мультигеймовый скрипт",
            ["SETTINGS"]        = "Настройки",
            ["APPEARANCE"]      = "Внешний вид",
            ["CONFIGURATION"]   = "Конфигурация",
            ["SAVE_CONFIG"]     = "Сохранить конфиг",
            ["LOAD_CONFIG"]     = "Загрузить конфиг",
            ["THEME_SELECT"]    = "Выбрать тему",
            ["TRANSPARENCY"]    = "Прозрачность окна",
            ["LOCKED_TAB"]      = "В разработке"
        },
        ["fr"] = { -- French
            ["DESC"]            = "Script multi-jeux",
            ["SETTINGS"]        = "Paramètres",
            ["APPEARANCE"]      = "Apparence",
            ["CONFIGURATION"]   = "Configuration",
            ["SAVE_CONFIG"]     = "Enregistrer la configuration",
            ["LOAD_CONFIG"]     = "Charger la configuration",
            ["THEME_SELECT"]    = "Sélectionner le thème",
            ["TRANSPARENCY"]    = "Transparence de la fenêtre",
            ["LOCKED_TAB"]      = "En développement"
        },
        ["de"] = { -- German
            ["DESC"]            = "Mehrspiel-Skript",
            ["SETTINGS"]        = "Einstellungen",
            ["APPEARANCE"]      = "Aussehen",
            ["CONFIGURATION"]   = "Konfiguration",
            ["SAVE_CONFIG"]     = "Konfiguration speichern",
            ["LOAD_CONFIG"]     = "Konfiguration laden",
            ["THEME_SELECT"]    = "Thema auswählen",
            ["TRANSPARENCY"]    = "Fenstertransparenz",
            ["LOCKED_TAB"]      = "In Entwicklung"
        },
        ["pt"] = { -- Portuguese (Brazil)
            ["DESC"]            = "Script multijogo",
            ["SETTINGS"]        = "Configurações",
            ["APPEARANCE"]      = "Aparência",
            ["CONFIGURATION"]   = "Configuração",
            ["SAVE_CONFIG"]     = "Salvar configuração",
            ["LOAD_CONFIG"]     = "Carregar configuração",
            ["THEME_SELECT"]    = "Selecionar tema",
            ["TRANSPARENCY"]    = "Transparência da janela",
            ["LOCKED_TAB"]      = "Em desenvolvimento"
        },
        ["it"] = { -- Italian
            ["DESC"]            = "Script multigioco",
            ["SETTINGS"]        = "Impostazioni",
            ["APPEARANCE"]      = "Aspetto",
            ["CONFIGURATION"]   = "Configurazione",
            ["SAVE_CONFIG"]     = "Salva configurazione",
            ["LOAD_CONFIG"]     = "Carica configurazione",
            ["THEME_SELECT"]    = "Seleziona tema",
            ["TRANSPARENCY"]    = "Trasparenza finestra",
            ["LOCKED_TAB"]      = "In sviluppo"
        },
        ["ja"] = { -- Japanese
            ["DESC"]            = "マルチゲームスクリプト",
            ["SETTINGS"]        = "設定",
            ["APPEARANCE"]      = "外観",
            ["CONFIGURATION"]   = "構成",
            ["SAVE_CONFIG"]     = "設定を保存",
            ["LOAD_CONFIG"]     = "設定を読み込む",
            ["THEME_SELECT"]    = "テーマを選択",
            ["TRANSPARENCY"]    = "ウィンドウの透明度",
            ["LOCKED_TAB"]      = "開発中"
        },
        ["ko"] = { -- Korean
            ["DESC"]            = "멀티 게임 스크립트",
            ["SETTINGS"]        = "설정",
            ["APPEARANCE"]      = "모양",
            ["CONFIGURATION"]   = "구성",
            ["SAVE_CONFIG"]     = "설정 저장",
            ["LOAD_CONFIG"]     = "설정 불러오기",
            ["THEME_SELECT"]    = "테마 선택",
            ["TRANSPARENCY"]    = "창 투명도",
            ["LOCKED_TAB"]      = "개발 중"
        },
        ["zh-cn"] = { -- Chinese (Simplified)
            ["DESC"]            = "多游戏脚本",
            ["SETTINGS"]        = "设置",
            ["APPEARANCE"]      = "外观",
            ["CONFIGURATION"]   = "配置",
            ["SAVE_CONFIG"]     = "保存配置",
            ["LOAD_CONFIG"]     = "加载配置",
            ["THEME_SELECT"]    = "选择主题",
            ["TRANSPARENCY"]    = "窗口透明度",
            ["LOCKED_TAB"]      = "开发中"
        },
        ["zh-tw"] = { -- Chinese (Traditional)
            ["DESC"]            = "多遊戲腳本",
            ["SETTINGS"]        = "設定",
            ["APPEARANCE"]      = "外觀",
            ["CONFIGURATION"]   = "配置",
            ["SAVE_CONFIG"]     = "儲存配置",
            ["LOAD_CONFIG"]     = "載入配置",
            ["THEME_SELECT"]    = "選擇主題",
            ["TRANSPARENCY"]    = "視窗透明度",
            ["LOCKED_TAB"]      = "開發中"
        },
        ["ar"] = { -- Arabic
            ["DESC"]            = "سكريبت متعدد الألعاب",
            ["SETTINGS"]        = "الإعدادات",
            ["APPEARANCE"]      = "المظهر",
            ["CONFIGURATION"]   = "التهيئة",
            ["SAVE_CONFIG"]     = "حفظ الإعدادات",
            ["LOAD_CONFIG"]     = "تحميل الإعدادات",
            ["THEME_SELECT"]    = "اختيار السمة",
            ["TRANSPARENCY"]    = "شفافية النافذة",
            ["LOCKED_TAB"]      = "قيد التطوير"
        },
        ["tr"] = { -- Turkish
            ["DESC"]            = "Çoklu Oyun Scripti",
            ["SETTINGS"]        = "Ayarlar",
            ["APPEARANCE"]      = "Görünüm",
            ["CONFIGURATION"]   = "Yapılandırma",
            ["SAVE_CONFIG"]     = "Yapılandırmayı Kaydet",
            ["LOAD_CONFIG"]     = "Yapılandırmayı Yükle",
            ["THEME_SELECT"]    = "Tema Seç",
            ["TRANSPARENCY"]    = "Pencere Saydamlığı",
            ["LOCKED_TAB"]      = "Geliştirme Aşamasında"
        },
        ["pl"] = { -- Polish
            ["DESC"]            = "Skrypt wielogrowy",
            ["SETTINGS"]        = "Ustawienia",
            ["APPEARANCE"]      = "Wygląd",
            ["CONFIGURATION"]   = "Konfiguracja",
            ["SAVE_CONFIG"]     = "Zapisz konfigurację",
            ["LOAD_CONFIG"]     = "Wczytaj konfigurację",
            ["THEME_SELECT"]    = "Wybierz motyw",
            ["TRANSPARENCY"]    = "Przezroczystość okna",
            ["LOCKED_TAB"]      = "W trakcie rozwoju"
        },
        ["id"] = { -- Indonesian
            ["DESC"]            = "Skrip Multi-Game",
            ["SETTINGS"]        = "Pengaturan",
            ["APPEARANCE"]      = "Tampilan",
            ["CONFIGURATION"]   = "Konfigurasi",
            ["SAVE_CONFIG"]     = "Simpan Konfigurasi",
            ["LOAD_CONFIG"]     = "Muat Konfigurasi",
            ["THEME_SELECT"]    = "Pilih Tema",
            ["TRANSPARENCY"]    = "Transparansi Jendela",
            ["LOCKED_TAB"]      = "Dalam Pengembangan"
        },
        ["hi"] = { -- Hindi
            ["DESC"]            = "मल्टी-गेम स्क्रिप्ट",
            ["SETTINGS"]        = "सेटिंग्स",
            ["APPEARANCE"]      = "दिखावट",
            ["CONFIGURATION"]   = "कॉन्फ़िगरेशन",
            ["SAVE_CONFIG"]     = "कॉन्फ़िगरेशन सहेजें",
            ["LOAD_CONFIG"]     = "कॉन्फ़िगरेशन लोड करें",
            ["THEME_SELECT"]    = "थीम चुनें",
            ["TRANSPARENCY"]    = "विंडो पारदर्शिता",
            ["LOCKED_TAB"]      = "विकासाधीन"
        },
        ["bn"] = { -- Bengali
            ["DESC"]            = "মাল্টি-গেম স্ক্রিপ্ট",
            ["SETTINGS"]        = "সেটিংস",
            ["APPEARANCE"]      = "দেখা",
            ["CONFIGURATION"]   = "কনফিগারেশন",
            ["SAVE_CONFIG"]     = "কনফিগারেশন সংরক্ষণ করুন",
            ["LOAD_CONFIG"]     = "কনফিগারেশন লোড করুন",
            ["THEME_SELECT"]    = "থিম নির্বাচন করুন",
            ["TRANSPARENCY"]    = "উইন্ডোর স্বচ্ছতা",
            ["LOCKED_TAB"]      = "উন্নয়নাধীন"
        },
        ["vi"] = { -- Vietnamese
            ["DESC"]            = "Script đa trò chơi",
            ["SETTINGS"]        = "Cài đặt",
            ["APPEARANCE"]      = "Giao diện",
            ["CONFIGURATION"]   = "Cấu hình",
            ["SAVE_CONFIG"]     = "Lưu cấu hình",
            ["LOAD_CONFIG"]     = "Tải cấu hình",
            ["THEME_SELECT"]    = "Chọn giao diện",
            ["TRANSPARENCY"]    = "Độ trong suốt cửa sổ",
            ["LOCKED_TAB"]      = "Đang phát triển"
        },
        ["th"] = { -- Thai
            ["DESC"]            = "สคริปต์หลายเกม",
            ["SETTINGS"]        = "การตั้งค่า",
            ["APPEARANCE"]      = "ลักษณะ",
            ["CONFIGURATION"]   = "การกำหนดค่า",
            ["SAVE_CONFIG"]     = "บันทึกการตั้งค่า",
            ["LOAD_CONFIG"]     = "โหลดการตั้งค่า",
            ["THEME_SELECT"]    = "เลือกธีม",
            ["TRANSPARENCY"]    = "ความโปร่งใสของหน้าต่าง",
            ["LOCKED_TAB"]      = "อยู่ระหว่างการพัฒนา"
        }
    }
})

local Window = HaxelUI:CreateWindow({
    Title = "Bat.lua", 
    Icon = "https://itaku.ee/api/media/gallery_imgs/nikoty_FG55uER/xl.jpg",
    Author = "@animal.bat",
    Description = "loc:DESC",
    Folder = "Bat.lua",
    User = {
        Enabled = true
    },
})

Window:SetIconSize(24)

local TweenService              = game:GetService("TweenService")
local RunService                = game:GetService("RunService")

local tag = Window:Tag({
    Title = "DEV",
    Color = HaxelUI:Gradient({
        ["0"]   = { Color = Color3.fromRGB(0, 0, 0), Transparency = 0 }, -- black
        ["100"] = { Color = Color3.fromRGB(0, 0, 0), Transparency = 0 }, -- black
    }, {
        Rotation = 45,
    }),
})

-- define color sequence in RGB (converted from hex)
local colorSequence = {
    Color3.fromRGB(0, 0, 0),        -- #000000FF (black)
    Color3.fromRGB(17, 17, 17),     -- #111111FF
    Color3.fromRGB(34, 34, 34),     -- #222222FF
    Color3.fromRGB(51, 51, 51),     -- #333333FF
    Color3.fromRGB(68, 68, 68),     -- #444444FF
    Color3.fromRGB(85, 85, 85),     -- #555555FF
    Color3.fromRGB(102, 102, 102),  -- #666666FF
    Color3.fromRGB(119, 119, 119),  -- #777777FF
    Color3.fromRGB(136, 136, 136),  -- #888888FF
    Color3.fromRGB(153, 153, 153),  -- #999999FF
    Color3.fromRGB(170, 170, 170),  -- #AAAAAAFF
    Color3.fromRGB(187, 187, 187),  -- #BBBBBBFF
    Color3.fromRGB(204, 204, 204),  -- #CCCCCCFF
    Color3.fromRGB(221, 221, 221),  -- #DDDDDDFF
    Color3.fromRGB(238, 238, 238),  -- #EEEEEEFF
    Color3.fromRGB(255, 255, 255),  -- #FFFFFFFF (white)
    Color3.fromRGB(238, 238, 238),  -- #EEEEEEFF
    Color3.fromRGB(221, 221, 221),  -- #DDDDDDFF
    Color3.fromRGB(204, 204, 204),  -- #CCCCCCFF
    Color3.fromRGB(187, 187, 187),  -- #BBBBBBFF
    Color3.fromRGB(170, 170, 170),  -- #AAAAAAFF
    Color3.fromRGB(153, 153, 153),  -- #999999FF
    Color3.fromRGB(136, 136, 136),  -- #888888FF
    Color3.fromRGB(119, 119, 119),  -- #777777FF
    Color3.fromRGB(102, 102, 102),  -- #666666FF
    Color3.fromRGB(85, 85, 85),     -- #555555FF
    Color3.fromRGB(68, 68, 68),     -- #444444FF
    Color3.fromRGB(51, 51, 51),     -- #333333FF
    Color3.fromRGB(34, 34, 34),     -- #222222FF
    Color3.fromRGB(17, 17, 17),     -- #111111FF
    Color3.fromRGB(0, 0, 0),        -- #000000FF (black)
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

    local startColor = colorSequence[index]
    local endColor = colorSequence[index + 1]
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
