--[[ MAIN UI ]]--

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

local Sections = {
    Main = Window:Section({ Title = "Main", Opened = true }),
    Visuals = Window:Section({ Title = "Visuals", Opened = true }),
    Movement = Window:Section({ Title = "Movement", Opened = true }),
    Misc = Window:Section({ Title = "Misc", Opened = true }),
    Settings = Window:Section({ Title = "loc:SETTINGS", Opened = true }),
}

local Tabs = {
    Aimbot = Sections.Main:Tab({ Title = "Aimbot", Icon = "crosshair" }),
    Appearance = Sections.Settings:Tab({ Title = "loc:APPEARANCE", Icon = "brush" }),
    Config = Sections.Settings:Tab({ Title = "loc:CONFIGURATION", Icon = "settings" }),
}

--// Services
local RunService   = game:GetService("RunService")
local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local LocalPlayer  = Players.LocalPlayer
local Mouse        = LocalPlayer:GetMouse()

--// Aimbot state
local AimbotState = {
    Enabled         = false,
    AutofireEnabled = false,
    AutofireDelay   = 100,
    Intensity       = 50,
    TargetPart      = "Head",
    FOV             = 90,
    Radius          = 100,
    IgnoreTeammates = true,
}

--// Persistent state
local Highlights   = {}  -- plr -> Highlight
local Connections  = {}  -- RBXScriptConnections
local RayParams    = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist
RayParams.IgnoreWater = true

--// Utility functions
local function updateRayFilter(char)
    RayParams.FilterDescendantsInstances = char and {char} or {}
end

local function safeDestroy(obj)
    if obj and typeof(obj) == "Instance" then
        pcall(obj.Destroy, obj)
    end
end

local function removeHighlight(plr)
    local h = Highlights[plr]
    if h then
        safeDestroy(h)
        Highlights[plr] = nil
    end
end

local function getHighlight(plr)
    if not Highlights[plr] then
        local h = Instance.new("Highlight")
        h.FillTransparency = 0.8
        h.OutlineTransparency = 0.6
        h.Parent = Workspace
        Highlights[plr] = h
    end
    return Highlights[plr]
end

local function cleanupAllHighlights()
    for plr, h in pairs(Highlights) do
        safeDestroy(h)
        Highlights[plr] = nil
    end
end

--// Visibility offsets
local OFFSETS = {
    Vector3.new(0, 0, 0),
    Vector3.new(0.2, 0, 0),
    Vector3.new(-0.2, 0, 0),
    Vector3.new(0, 0.2, 0),
    Vector3.new(0, -0.2, 0),
}

--// Visibility scoring
local function getVisibilityScore(origin, targetPart, filterChar)
    local visible = 0
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.IgnoreWater = true
    params.FilterDescendantsInstances = {filterChar}

    local pos = targetPart.Position

    for _, off in ipairs(OFFSETS) do
        local worldPos = pos + targetPart.CFrame:VectorToWorldSpace(off)
        local dir = worldPos - origin
        local magnitude = dir.Magnitude
        if magnitude > 0 then
            local result = Workspace:Raycast(origin, dir.Unit * magnitude, params)
            if not result or result.Instance:IsDescendantOf(targetPart.Parent) then
                visible += 1
            end
        end
    end

    return visible / #OFFSETS
end

--// Colors
local RED    = Color3.fromRGB(200, 0, 0)
local ORANGE = Color3.fromRGB(255, 165, 0)
local GREEN  = Color3.fromRGB(0, 255, 0)

--// Target helpers
local function chooseTargetPart()
    return AimbotState.TargetPart
end

local function isPlayerAlive(plr)
    local char = plr.Character
    if not char then return false end
    local humanoid = char:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

--// Targeting logic
local function findNearestTarget()
    local bestDist, bestPlr, bestPart = math.huge, nil, nil
    local camPos = Workspace.CurrentCamera.CFrame.Position
    local look = Workspace.CurrentCamera.CFrame.LookVector
    local myChar = LocalPlayer.Character

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LocalPlayer or not isPlayerAlive(pl) then continue end
        if AimbotState.IgnoreTeammates and LocalPlayer.Team and pl.Team and pl.Team == LocalPlayer.Team then continue end

        local char = pl.Character
        if not (char and char:FindFirstChild("HumanoidRootPart")) then continue end

        local hrp = char.HumanoidRootPart
        local dir = hrp.Position - camPos
        local dist = dir.Magnitude
        if dist > AimbotState.Radius then continue end

        local dot = math.clamp(look:Dot(dir.Unit), -1, 1)
        local angle = math.deg(math.acos(dot))
        if angle > AimbotState.FOV / 2 then continue end

        local part = char:FindFirstChild(chooseTargetPart()) or hrp
        if not part then continue end

        local vis = getVisibilityScore(camPos, part, myChar)
        if vis > 0.3 and dist < bestDist then
            bestDist, bestPlr, bestPart = dist, pl, part
        end
    end

    return bestPlr, bestPart, bestDist
end

--// Smoothing and aim
local function intensityToSmoothing(i)
    local t = i / 100
    return 0.15 + (0.83 * (t ^ 1.6))
end

local function aimAt(part, smoothing, dist)
    if not part or not part.Parent then return end

    if dist < 50 then
        local desired = CFrame.lookAt(Workspace.CurrentCamera.CFrame.Position, part.Position)
        Workspace.CurrentCamera.CFrame = Workspace.CurrentCamera.CFrame:Lerp(desired, smoothing)
    else
        local screen, onScreen = Workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        if onScreen then
            local dx = screen.X - Mouse.X
            local dy = screen.Y - Mouse.Y
            pcall(function()
                mousemoverel(dx * smoothing * 0.05, dy * smoothing * 0.05)
            end)
        end
    end
end

--// Highlight updates (reworked for optimization and bug fixes)
local function updateHighlights(targetPlr)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    local myHrp = myChar.HumanoidRootPart
    local myPart = myChar:FindFirstChild("Head") or myHrp

    local camPos = Workspace.CurrentCamera.CFrame.Position
    local look = Workspace.CurrentCamera.CFrame.LookVector

    -- Clean up highlights for disconnected or dead players first
    for plr, _ in pairs(Highlights) do
        if not Players:FindFirstChild(plr.Name) or not isPlayerAlive(plr) then
            removeHighlight(plr)
        end
    end

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl == LocalPlayer then continue end
        if not isPlayerAlive(pl) then
            removeHighlight(pl)
            continue
        end
        if AimbotState.IgnoreTeammates and LocalPlayer.Team and pl.Team and pl.Team == LocalPlayer.Team then
            removeHighlight(pl)
            continue
        end

        local char = pl.Character
        if not (char and char:FindFirstChild("HumanoidRootPart")) then
            removeHighlight(pl)
            continue
        end

        local hrp = char.HumanoidRootPart
        local dir = hrp.Position - camPos
        local dist = dir.Magnitude
        local dot = math.clamp(look:Dot(dir.Unit), -1, 1)
        local angle = math.deg(math.acos(dot))
        if dist > AimbotState.Radius or angle > AimbotState.FOV / 2 then
            removeHighlight(pl)
            continue
        end

        local part = char:FindFirstChild(AimbotState.TargetPart) or char:FindFirstChild("Head")
        if not part then
            removeHighlight(pl)
            continue
        end

        local vis = getVisibilityScore(camPos, part, myChar)

        local h = getHighlight(pl)
        h.Adornee = char

        local color = RED
        local fillTrans = 0.9 - (vis * 0.4)
        local outlineTrans = 0.6 - (vis * 0.3)

        if vis > 0.3 then
            color = ORANGE
        end

        if pl == targetPlr then
            color = GREEN
        end

        h.FillColor = color
        h.OutlineColor = color
        h.FillTransparency = fillTrans
        h.OutlineTransparency = outlineTrans
    end
end

--// Main loop
local function renderStep()
    if not AimbotState.Enabled then return end
    local targetPlr, targetPart, dist = findNearestTarget()
    updateHighlights(targetPlr)
    if targetPlr and targetPart and isPlayerAlive(targetPlr) then
        aimAt(targetPart, intensityToSmoothing(AimbotState.Intensity), dist)
    end
end

local function disable()
    RunService:UnbindFromRenderStep("AimbotUpdate")
    cleanupAllHighlights()
    for _, conn in pairs(Connections) do
        if conn.Connected then conn:Disconnect() end
    end
    table.clear(Connections)
end

--// UI Elements
local AimbotElements = {
    Tabs.Aimbot:Section({
        Title = "Aimbot with wall check + gradient highlight",
        TextSize = 10,
    }),

    Tabs.Aimbot:Toggle({
        Title = "Enable",
        Desc = "Toggle aimbot on/off",
        Value = false,
        Callback = function(state)
            AimbotState.Enabled = state

            if state then
                disable()  -- Clean up previous state
                local char = LocalPlayer.Character
                if char then
                    updateRayFilter(char)
                end
                updateHighlights(nil)

                if not Connections.charAdded or not Connections.charAdded.Connected then
                    Connections.charAdded = LocalPlayer.CharacterAdded:Connect(function(newChar)
                        updateRayFilter(newChar)
                        updateHighlights(nil)
                    end)
                end

                if not Connections.playerRemoving or not Connections.playerRemoving.Connected then
                    Connections.playerRemoving = Players.PlayerRemoving:Connect(removeHighlight)
                end

                RunService:BindToRenderStep(
                    "AimbotUpdate",
                    Enum.RenderPriority.Camera.Value + 1,
                    renderStep
                )
            else
                disable()
            end
        end,
    }),

    Tabs.Aimbot:Toggle({
        Title = "Autofire",
        Desc = "Auto-shoot at targets",
        Value = false,
        Callback = function(state)
            AimbotState.AutofireEnabled = state
            if state then
                spawn(function()
                    while AimbotState.AutofireEnabled and AimbotState.Enabled do  -- Added Enabled check to prevent orphan loops
                        local myChar = LocalPlayer.Character
                        if not myChar then
                            task.wait(0.1)
                            continue
                        end
                        local weapon = myChar:FindFirstChildOfClass("Tool")
                        if not weapon then
                            task.wait(0.1)
                            continue
                        end

                        local settingsModule = weapon:FindFirstChild("SETTINGS")
                        if not settingsModule then
                            task.wait(0.1)
                            continue
                        end

                        local settings = require(settingsModule)
                        local targetPlr, targetPart, dist = findNearestTarget()

                        if targetPlr and targetPart and isPlayerAlive(targetPlr) then
                            local rayOrigin = myChar:FindFirstChild("Torso") or myChar:FindFirstChild("UpperTorso")  -- Fallback for R15
                            if not rayOrigin then
                                task.wait(0.1)
                                continue
                            end
                            rayOrigin = rayOrigin.Position
                            local rayDirection = (targetPart.Position - rayOrigin).Unit * settings.RANGE
                            local result = Workspace:Raycast(rayOrigin, rayDirection, RayParams)

                            if result and result.Instance:IsDescendantOf(targetPlr.Character) then
                                local replacement = {
                                    [3] = settings.FIRERATE,
                                    [4] = targetPart,
                                    [5] = CFrame.new(weapon.Barrel.Position, targetPart.Position).LookVector,
                                    [7] = targetPart.Position,
                                }

                                game:GetService("ReplicatedStorage").PEW:FireServer(
                                    weapon,
                                    settings.COUNT,
                                    replacement[3],
                                    replacement[4],
                                    replacement[5],
                                    false,
                                    replacement[7],
                                    settings.RANGE
                                )
                            end
                        end

                        task.wait(AimbotState.AutofireDelay / 1000)
                    end
                end)
            end
        end,
    }),

    Tabs.Aimbot:Toggle({
        Title = "Ignore Teammates",
        Desc = "Don't target players on your team",
        Value = true,
        Callback = function(state)
            AimbotState.IgnoreTeammates = state
        end,
    }),

    Tabs.Aimbot:Dropdown({
        Title = "Target Part",
        Desc = "Which body part to target",
        Values = { "Head", "Torso" },
        Value = "Head",
        Callback = function(v)
            AimbotState.TargetPart = v
        end,
    }),

    Tabs.Aimbot:Slider({
        Title = "Effect Intensity",
        Desc = "0-50 = smooth, 90-100 = snappy",
        Value = { Min = 0, Max = 100, Default = 50 },
        Callback = function(v)
            AimbotState.Intensity = v
        end,
    }),

    Tabs.Aimbot:Slider({
        Title = "FOV (degrees)",
        Desc = "Field of view used to pick targets",
        Value = { Min = 10, Max = 180, Default = 90 },
        Callback = function(v)
            AimbotState.FOV = math.max(10, math.min(180, v))
        end,
    }),

    Tabs.Aimbot:Slider({
        Title = "Radius (studs)",
        Desc = "Max search distance",
        Value = { Min = 10, Max = 1000, Default = 100 },
        Callback = function(v)
            AimbotState.Radius = math.max(10, math.min(1000, v))
        end,
    }),

    Tabs.Aimbot:Slider({
        Title = "Autofire Delay (ms)",
        Desc = "(Delay in milliseconds; 20 ms = 50 bullets per sec)",
        Value = { Min = 20, Max = 1000, Default = 100 },
        Callback = function(v)
            AimbotState.AutofireDelay = v
        end,
    }),
}



local AppearanceElements = {}
