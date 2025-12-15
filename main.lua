local Localization = {
    analyzing      = "Analyzing...",
    gameFound      = "Game Found: %s",
    noScript       = "No supported script found for: %s",
    blacklisted    = "Game is blacklisted: %s",
    loadingScript  = "Script Path:\n%s"
}
local BlacklistedGames = {
    [999999999] = true, 
    [888888888] = true, 
}
local SupportedGames = {
    [123456789] = "Blackout Revival.lua",
    [5987922834] = "Transfur Outbreak.lua",
    [111222333] = "Pressure.lua",
}
local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/lobox920/Notification-Library/Main/Library.lua"))()
local BaseURL = "https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/"
local MarketplaceService = game:GetService("MarketplaceService")
local PlaceId = game.PlaceId
local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)
local GameName = Success and GameInfo.Name or "Unknown Game"

--// Notify
NotificationLibrary:SendNotification("Info", Localization.analyzing, 3)
task.wait(1)
NotificationLibrary:SendNotification("Info", string.format(Localization.gameFound, GameName), 3)

if BlacklistedGames[PlaceId] then
    NotificationLibrary:SendNotification(
        "Error",
        string.format(Localization.blacklisted, GameName),
        5
    )
    return
end

local ScriptName = SupportedGames[PlaceId]

if ScriptName then
    local ScriptPath = BaseURL .. ScriptName

    NotificationLibrary:SendNotification(
        "Info",
        string.format(Localization.loadingScript, "\\" .. ScriptPath),
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
