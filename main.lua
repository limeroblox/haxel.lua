--[[ 
Planned Features:
Implements automatic game support and UI notifications based on GameID or PlaceID.
]]

local NotificationLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/lobox920/Notification-Library/Main/Library.lua"))()
local MarketplaceService = game:GetService("MarketplaceService")
local PlaceId = game.PlaceId

local Success, GameInfo = pcall(function()
    return MarketplaceService:GetProductInfo(PlaceId)
end)

local GameName = Success and GameInfo.Name or "Unknown Game"

-- Notifications
NotificationLibrary:SendNotification("Info", "Analyzing...", 3)
NotificationLibrary:SendNotification("Info", "Game Found: " .. GameName, 3)

-- Match PlaceId -> Script
if PlaceId == 123456789 then
    NotificationLibrary:SendNotification("Info", "Script Path:\n\\haxel.lua/refs/heads/main/games/blackout_revival.lua", 5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/blackout_revival.lua"))()
elseif PlaceId == 5987922834 then
    NotificationLibrary:SendNotification("Info", "Script Path:\n\\haxel.lua/refs/heads/main/games/trashfur_outbreak.lua", 5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/trashfur_outbreak.lua"))()
elseif PlaceId == 111222333 then
    NotificationLibrary:SendNotification("Info", "Script Path:\n\\haxel.lua/refs/heads/main/games/pressure.lua", 5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/games/pressure.lua"))()
else
    NotificationLibrary:SendNotification("Error", "No supported script found for: " .. GameName, 5)
end
