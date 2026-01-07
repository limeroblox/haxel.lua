--// SETTINGS
local LOOP_DELAY = 0.01
local TIMEOUT = 5
local SPOOF_RANGE = 3

--// SERVICES
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RS = game:GetService("ReplicatedStorage")

--// REMOTES
local MeleeStorage = RS:WaitForChild("MeleeStorage")
local Events = MeleeStorage:WaitForChild("Events")
local SwingRemote = Events:WaitForChild("Swing")
local HitRemote = Events:WaitForChild("Hit")

--// ALERTS
local function alert(msg, dur)
    dur = dur or 3
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "KillAll",
            Text = msg,
            Duration = dur
        })
    end)
end

alert("KillAll started (Range Spoof Mode)…")

--// HRP UPDATER
local hrp
task.spawn(function()
    while true do
        local char = LocalPlayer.Character
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        task.wait()
    end
end)

--// METAMETHOD SPOOFING
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldIndex = mt.__index
local oldNamecall = mt.__namecall

mt.__index = function(t, k)
    if k == "Magnitude" and typeof(t) == "Vector3" then
        return SPOOF_RANGE
    end
    return oldIndex(t, k)
end

mt.__namecall = function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "Raycast" then
        return {
            Instance = workspace.Terrain,
            Position = hrp and hrp.Position or Vector3.zero,
            Normal = Vector3.new(0,1,0),
            Material = Enum.Material.Grass
        }
    end

    if (method == "FireServer" or method == "InvokeServer") then
        for i, v in ipairs(args) do
            if typeof(v) == "Vector3" then
                args[i] = hrp and (hrp.Position + Vector3.new(math.random(), math.random(), math.random()) * SPOOF_RANGE) or Vector3.zero
            end
        end
        return oldNamecall(self, unpack(args))
    end

    return oldNamecall(self, ...)
end

setreadonly(mt, true)

--// CHARACTER VALIDATION
local function isValidCharacter(char)
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function isDead(char)
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return not hum or hum.Health <= 0
end

--// ATTACK FUNCTION
local function attack(char)
    if not isValidCharacter(char) then return end

    local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not part then return end

    pcall(function()
        SwingRemote:InvokeServer()
        HitRemote:FireServer(part, part.Position)
    end)
end

--// ATTACK HANDLER PER PLAYER
local function attackPlayer(target)
    if not target or target == LocalPlayer then return end

    local startTime = tick()
    while tick() - startTime < TIMEOUT do
        local char = target.Character
        if not char or not isValidCharacter(char) then break end

        attack(char)

        if isDead(char) then
            break
        end

        task.wait(LOOP_DELAY)
    end
end

--// INITIALIZE FOR EXISTING PLAYERS
local initial_count = 0

local function processInitialPlayer(target)
    attackPlayer(target)
    initial_count = initial_count - 1
    if initial_count <= 0 then
        alert("KillAll finished!", 5)
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        initial_count = initial_count + 1
        task.spawn(processInitialPlayer, plr)
    end
end

if initial_count == 0 then
    alert("KillAll finished!", 5)
end

--// HANDLE NEW PLAYERS
Players.PlayerAdded:Connect(function(plr)
    if plr ~= LocalPlayer then
        task.spawn(attackPlayer, plr)
    end
end)
