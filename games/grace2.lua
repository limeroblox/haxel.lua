local repo = "https://raw.githubusercontent.com/limeroblox/meowware.lua/core/uilib_stuff/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options 		= Library.Options
local Toggles 		= Library.Toggles
local Ver 			= loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/meowware.lua/refs/heads/main/core/version.txt"))()
local Version 		= "MeowWare.lua | " .. Ver
Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true 

-- [[ Ui Based ]] --

-- [START OF FUNCTIONS] --

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function grace()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    for _, obj in ipairs(LocalPlayer:GetDescendants()) do
        if obj.Name == "NOW" then
            obj:Destroy()
        end
    end

    local beacons = workspace:WaitForChild("Beacons", 10)
    if beacons then
        for _, child in ipairs(beacons:GetChildren()) do
            if child.Name == "Part" then
                local scriptObj = workspace:WaitForChild("Script", 5)
                if scriptObj then
                    local beaconPickup = scriptObj:WaitForChild("BeaconPickup", 5)
                    if beaconPickup then
                        beaconPickup:FireServer(child)
                    end
                end
            end
        end
    end

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:sub(1, 4) == "Send" or obj.Name:sub(1, 4) == "Kill" then
                obj:Destroy()
            end
        end
    end

    for _, item in ipairs(workspace:GetChildren()) do
        if item.Name ~= "Beacons" and not item:IsA("BaseScript") then
            if item.Name == "Rooms" then
                for _, child in ipairs(item:GetChildren()) do
                    child:Destroy()
                end
            else
                item:Destroy()
            end
        end
    end
end

local function grace2()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character or not character.Parent then
        local startTime = tick()
        repeat
            task.wait(0.1)
            character = player.Character
        until character and character.Parent or (tick() - startTime) > 10
    end
    if not character then return end  -- Exit if character not found after timeout

    local root = character:WaitForChild("HumanoidRootPart", 5)
    if not root then return end  -- Exit if root not found

    local roomsFolder = workspace:WaitForChild("Rooms", 10)
    if not roomsFolder then return end  -- Exit if rooms not found

    local roomModels = {}
    for _, model in ipairs(roomsFolder:GetChildren()) do
        if model:IsA("Model") then
            local num = tonumber(model.Name)
            if num then
                table.insert(roomModels, { model = model, number = num })
            end
        end
    end
    for _, room in ipairs(roomModels) do
        local roomModel = room.model
        local vault = roomModel:FindFirstChild("VaultEntrance")
        if vault then
            ReplicatedStorage.TriggerPrompt:FireServer(vault:FindFirstChild("Hinged"):FindFirstChild("Cylinder"):FindFirstChild("ProximityPrompt"))
            ReplicatedStorage.Events.EnteredSaferoom:FireServer()
        else
            local toDestroy = {}
            for _, descendant in ipairs(roomModel:GetDescendants()) do
                if descendant:IsA("BaseScript") then
                    local target = descendant
                    while target.Parent ~= roomModel do
                        target = target.Parent
                    end
                    toDestroy[target] = true
                end
            end
            for target in pairs(toDestroy) do
                target:Destroy()
            end
        end
    end
    local safeRoom = roomsFolder:FindFirstChild("SafeRoom", true)
    local deathTimer = workspace:FindFirstChild("DEATHTIMER")
    table.sort(roomModels, function(a, b)
        return a.number < b.number
    end)
    if safeRoom and safeRoom:IsA("Model") and not safeRoom:IsDescendantOf(roomModels[#roomModels].model) and not safeRoom:IsDescendantOf(roomModels[1].model) and deathTimer and deathTimer.Value <= 0 then
        local vaultDoor = safeRoom:FindFirstChild("VaultDoor")
        local scale = safeRoom:FindFirstChild("Scale")
        local hitbox = scale and scale:FindFirstChild("hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            root.CFrame = hitbox.CFrame * CFrame.Angles(0, math.rad(225), 0)
            workspace.CurrentCamera.CFrame = root.CFrame
        end
    else
        local index = #roomModels
        if safeRoom and safeRoom:IsA("Model") and deathTimer and not deathTimer:GetAttribute("AUTOGO") then
            index = math.min(11, #roomModels)
        end
        local highestModel = roomModels[index] and roomModels[index].model
        local exit = highestModel and highestModel:FindFirstChild("Exit")
        if exit and exit:IsA("BasePart") then
            root.CFrame = exit.CFrame * CFrame.Angles(0, math.rad(45), 0)
            workspace.CurrentCamera.CFrame = root.CFrame
        end
    end
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:sub(1,4) == "Send" or obj.Name:sub(1,4) == "Kill" then
                obj:Destroy()
            end
        end
    end
end

local hbGrace1, hbGrace2

-- [END OF FUNCTIONS] --

local Window = Library:CreateWindow({
  AutoShow = true,
  MobileButtonsSide = "Left",
  Center = true,
	Title = "Grace",
	Footer = Version,
	Icon = 84903466827078,
	NotifySide = "Right",
	ShowCustomCursor = false,
})


