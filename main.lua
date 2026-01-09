local MarketplaceService = game:GetService("MarketplaceService")
local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/lobox920/Notification-Library/Main/Library.lua"))()
local BASE_SCRIPT_URL = "https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/"

local SupportedGames = {
    [123456789]  = "blackout_revival.lua",
    [6508759464] = "grace.lua",
    [5987922834] = "trashfur_outbreak.lua",
    [111222333]  = "pressure.lua",
}

local BlacklistedGames = {
    [123456789] = true
}

local Localization = {
    Analyzing        = "Checking for supported script: %s",
    ScriptFound      = "Supported script found for: %s",
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


local scriptName = SupportedGames[PlaceId] or SupportedGames[GameId]

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
    NotificationLibrary:SendNotification("Error", "No Script Found For:" .. gameName .. \n\"Loading Universal Script", 3)
    loadstring(game:HttpGet(BASE_SCRIPT_URL .. "Universal.lua"))()
end
