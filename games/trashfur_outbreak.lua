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
    Enabled     = false,
    Intensity   = 50,
    TargetPart  = "Head",
    FOV         = 90,
    Radius      = 100,
}

--// Persistent state (to handle multiple toggles without leaks)
local Highlights   = {}          -- plr -> Highlight
local Connections  = {}          -- RBXScriptConnections
local RayParams    = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Blacklist
RayParams.IgnoreWater = true

--// UI elements (unchanged)
local AimbotElements = {
    Tabs.Aimbot:Section({Title = "Aimbot with wall check + gradient highlight", TextSize = 10}),

    Tabs.Aimbot:Toggle({
        Title    = "Enable",
        Desc     = "Toggle aimbot on/off",
        Value    = false,
        Callback = function(state)
            AimbotState.Enabled = state

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
                    h.FillTransparency  = 0.8
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

            local OFFSETS = {
                Vector3.new(0,0,0),
                Vector3.new(0.2,0,0), Vector3.new(-0.2,0,0),
                Vector3.new(0,0.2,0), Vector3.new(0,-0.2,0),
            }

            local function visibilityScore(part)
                if not (part and part.Parent) then return 0 end
                local origin = Workspace.CurrentCamera.CFrame.Position
                local pos    = part.Position
                local visible = 0

                for _, off in ipairs(OFFSETS) do
                    local worldPos = pos + part.CFrame:VectorToWorldSpace(off)
                    local dir      = worldPos - origin
                    local result   = Workspace:Raycast(origin, dir.Unit * dir.Magnitude, RayParams)
                    if not result or result.Instance:IsDescendantOf(part.Parent) then
                        visible += 1
                    end
                end
                return visible / #OFFSETS
            end

            local RED    = Color3.fromRGB(200,0,0)
            local YELLOW = Color3.fromRGB(220,180,0)
            local GREEN  = Color3.fromRGB(0,200,0)

            local function colorFromVis(v)
                if v <= 0.5 then
                    return RED:Lerp(YELLOW, v / 0.5)
                else
                    return YELLOW:Lerp(GREEN, (v-0.5)/0.5)
                end
            end

            local function chooseTargetPart()
                return AimbotState.TargetPart
            end

            local function isPlayerAlive(plr)
                local char = plr.Character
                if not char then return false end
                local humanoid = char:FindFirstChild("Humanoid")
                return humanoid and humanoid.Health > 0
            end

            local function findNearestTarget()
                local bestDist, bestPlr, bestPart = math.huge, nil, nil
                local camPos = Workspace.CurrentCamera.CFrame.Position
                local look   = Workspace.CurrentCamera.CFrame.LookVector

                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl == LocalPlayer or not isPlayerAlive(pl) then continue end
                    local char = pl.Character
                    if not (char and char:FindFirstChild("HumanoidRootPart")) then continue end

                    local hrp = char.HumanoidRootPart
                    local dir = hrp.Position - camPos
                    local dist = dir.Magnitude
                    if dist > AimbotState.Radius then continue end

                    local dot   = math.clamp(look:Dot(dir.Unit), -1, 1)
                    local angle = math.deg(math.acos(dot))
                    if angle > AimbotState.FOV/2 then continue end

                    local part = char:FindFirstChild(chooseTargetPart()) or hrp
                    if not part then continue end

                    if visibilityScore(part) > 0.3 and dist < bestDist then
                        bestDist, bestPlr, bestPart = dist, pl, part
                    end
                end
                return bestPlr, bestPart, bestDist
            end

            local function intensityToSmoothing(i)
                local t = i/100
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

            local function updateHighlights()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl == LocalPlayer then continue end
                    if not isPlayerAlive(pl) then
                        removeHighlight(pl)
                        continue
                    end
                    
                    local char = pl.Character
                    if not (char and char:FindFirstChild("HumanoidRootPart")) then
                        removeHighlight(pl)
                        continue
                    end

                    local part = char:FindFirstChild(AimbotState.TargetPart) or char:FindFirstChild("Head")
                    if not part then
                        removeHighlight(pl)
                        continue
                    end

                    local vis = visibilityScore(part)
                    local h   = getHighlight(pl)
                    h.Adornee = char
                    h.FillColor = colorFromVis(vis)
                    h.OutlineColor = h.FillColor
                    h.FillTransparency = 0.9 - (vis*0.75)
                    h.OutlineTransparency = 0.6 - (vis*0.5)
                end
            end

            local function renderStep()
                if not AimbotState.Enabled then return end
                updateHighlights()
                local targetPlr, targetPart, dist = findNearestTarget()
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

            if state then
                disable()
                updateRayFilter(LocalPlayer.Character)
                updateHighlights()

                if not Connections.charAdded or not Connections.charAdded.Connected then
                    Connections.charAdded = LocalPlayer.CharacterAdded:Connect(function(char)
                        updateRayFilter(char)
                        updateHighlights()
                    end)
                end

                if not Connections.playerRemoving or not Connections.playerRemoving.Connected then
                    Connections.playerRemoving = Players.PlayerRemoving:Connect(removeHighlight)
                end

                RunService:BindToRenderStep("AimbotUpdate",
                    Enum.RenderPriority.Camera.Value + 1,
                    renderStep)
            else
                disable()
            end
        end,
    }),

    Tabs.Aimbot:Toggle({
        Title    = "Autofire",
        Desc     = "Auto-shoot at targets",
        Value    = false,
        Callback = function(state)
            AimbotState.AutofireEnabled = state
            if state then
                spawn(function()
                    while AimbotState.AutofireEnabled do
                        local weapon = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
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
                            local rayOrigin = LocalPlayer.Character.Torso.Position
                            local rayDirection = (targetPart.Position - rayOrigin).Unit * settings.RANGE
                            local result = Workspace:Raycast(rayOrigin, rayDirection, RayParams)
                            
                            if result and result.Instance:IsDescendantOf(targetPlr.Character) then
                                local replacement = {
                                    [3] = settings.FIRERATE,
                                    [4] = targetPart,
                                    [5] = CFrame.new(weapon.Barrel.Position, targetPart.Position).LookVector,
                                    [7] = targetPart.Position
                                }

                                game:GetService("ReplicatedStorage").PEW:FireServer(
                                    weapon, settings.COUNT, replacement[3], replacement[4], 
                                    replacement[5], false, replacement[7], settings.RANGE
                                )
                            end
                        end
                        
                        task.wait(AimbotState.AutofireRPM)
                    end
                end)
            end
        end,
    }),

    Tabs.Aimbot:Dropdown({
        Title   = "Target Part",
        Desc    = "Which body part to target",
        Values  = {"Head", "Torso"},
        Value   = "Head",
        Callback = function(v) AimbotState.TargetPart = v end,
    }),

    Tabs.Aimbot:Slider({
        Title   = "Effect Intensity",
        Desc    = "0-50 = smooth, 90-100 = snappy",
        Value   = {Min = 0, Max = 100, Default = 50},
        Callback = function(v) AimbotState.Intensity = v end,
    }),

    Tabs.Aimbot:Slider({
        Title   = "FOV (degrees)",
        Desc    = "Field of view used to pick targets",
        Value   = {Min = 10, Max = 180, Default = 90},
        Callback = function(v) AimbotState.FOV = math.max(10, math.min(180, v)) end,
    }),

    Tabs.Aimbot:Slider({
        Title   = "Radius (studs)",
        Desc    = "Max search distance",
        Value   = {Min = 10, Max = 1000, Default = 100},
        Callback = function(v) AimbotState.Radius = math.max(10, math.min(1000, v)) end,
    }),

    Tabs.Aimbot:Slider({
        Title   = "Autofire RPM",
        Desc    = "Fire rate (0.05-1 seconds)",
        Value   = {Min = 0.05, Max = 1, Default = 0.1},
        Callback = function(v) AimbotState.AutofireRPM = v end,
    }),
}

local AppearanceElements = {}
