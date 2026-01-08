--// IDs
local PlaceId = game.PlaceId
local GameId = game.GameId

-- Ensure GameId is valid
if GameId == 0 then
    game:GetPropertyChangedSignal("GameId"):Wait()
    GameId = game.GameId
end

--// Blacklist (supports BOTH GameId & PlaceId)
local BlacklistedIds = {
    [97038201049360] = true, -- GameId
    [888888888]      = true, -- PlaceId or GameId
}

--// Supported games (still PlaceId-based)
local SupportedGames = {
    [123456789]  = "blackout_revival.lua",
    [5987922834] = "trashfur_outbreak.lua",
    [111222333]  = "pressure.lua",
}

--// Services
local MarketplaceService = game:GetService("MarketplaceService")
local NotificationLibrary = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/lobox920/Notification-Library/Main/Library.lua"
))()

local BaseURL = "https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/"

--// Game info
local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)

local GameName = Success and GameInfo.Name or "Unknown Game"

--// Localization
local Localization = {
    analyzing     = "Analyzing...",
    gameFound     = "Game Found: %s",
    noScript      = "No supported script found for: %s",
    blacklisted   = "Game is blacklisted: %s",
    loadingScript = "Script Path:\n%s"
}

--// Notify
NotificationLibrary:SendNotification("Info", Localization.analyzing, 3)
task.wait(1)
NotificationLibrary:SendNotification(
    "Info",
    string.format(Localization.gameFound, GameName),
    3
)

--// FIXED BLACKLIST CHECK
if BlacklistedGames[GameId] or BlacklistedGames[PlaceId] then
    NotificationLibrary:SendNotification(
        "Error",
        string.format(Localization.blacklisted, GameName),
        5
    )
    return
end

--// Script loader
local ScriptName = SupportedGames[PlaceId]

if ScriptName then
    local ScriptPath = BaseURL .. ScriptName

    NotificationLibrary:SendNotification(
        "Info",
        string.format(Localization.loadingScript, ScriptPath),
        5
    )

    loadstring(game:HttpGet(ScriptPath))()
else
    NotificationLibrary:SendNotification(
        "Error",
        string.format(Localization.noScript, GameName),
        5
    )
end
