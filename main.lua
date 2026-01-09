local MarketplaceService = game:GetService("MarketplaceService")
local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/lobox920/Notification-Library/Main/Library.lua"))()
local BASE_SCRIPT_URL = "https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/"
local Localization = {
    Analyzing        = "Checking for supported script for: %s",
    ScriptFound      = "Supported script found for: %s",
    NoScript         = "No supported script found for: %s",
    Blacklisted      = "Game is blacklisted: %s",
    LoadingScript    = "Loading script from:\n%s"
}

local success, gameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)

local gameName = (success and gameInfo and gameInfo.Name) or "Unknown Game"


if BlacklistedGames[GameId] or BlacklistedGames[PlaceId] then
    NotificationLibrary:SendNotification(
        "Error",
        string.format(Localization.Blacklisted, gameName),
        5
    )
    return
end


NotificationLibrary:SendNotification(
    "Info",
    string.format(Localization.Analyzing, gameName),
    3
)


local scriptName = SupportedGames[PlaceId]

if scriptName then
    NotificationLibrary:SendNotification(
        "Success",
        string.format(Localization.ScriptFound, gameName),
        3
    )

    local scriptPath = BASE_SCRIPT_URL .. scriptName

    NotificationLibrary:SendNotification(
        "Info",
        string.format(Localization.LoadingScript, scriptPath),
        5
    )

    loadstring(game:HttpGet(scriptPath))()
else
    NotificationLibrary:SendNotification(
        "Error",
        string.format(Localization.NoScript, gameName),
        5
    )
end
