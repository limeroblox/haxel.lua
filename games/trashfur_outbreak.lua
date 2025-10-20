--[[ MAIN UI ]]--

loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/haxel.lua/refs/heads/main/core/ui.lua"))()

title = "Bat.lua | Transfur Outbreak"
local cursor = "_()"
local isActive = true -- Flag to control the loop

spawn(function()
    -- Typewriter effect
    local index = 0
    while index <= #title and isActive do
        title = string.sub(title, 1, index) .. cursor
        index = index + 1
        task.wait(0.05)
    end

    -- Blinking cursor effect
    local baseTitle = title -- Store original title
    while isActive do
        title = baseTitle .. cursor
        task.wait(0.5)
        title = baseTitle .. "   "
        task.wait(0.5)
    end
end)

-- Example function to stop the effect
local function stopEffect()
    isActive = false
end

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

-- Aimbot configuration
local AimbotState = {
    Enabled = false,
    Intensity = 50,
    TargetPart = "Head",
    FOV = 90,
    Radius = 100,
}

local AimbotElements = {
    Tabs.Aimbot:Section({
        Title = "Aimbot with wall check + gradient highlight",
        TextSize = 10,
    }),

    Tabs.Aimbot:Toggle({
        Title = "Enable",
        Desc  = "Toggle aimbot on/off",
        Value = false,
        Callback = function(state)
            AimbotState.Enabled = state
            print("Aimbot enabled:", state)

            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local Camera = Workspace.CurrentCamera
            local Player = Players.LocalPlayer
            local Mouse = Player:GetMouse()

            local Highlights = {}
            local connections = {}

            local function safeDestroy(obj)
                if obj and obj.Destroy then
                    pcall(function() obj:Destroy() end)
                end
            end

            local function removeHighlight(plr)
                if Highlights[plr] then
                    safeDestroy(Highlights[plr])
                    Highlights[plr] = nil
                end
            end

            local function cleanupAllHighlights()
                for pl, h in pairs(Highlights) do
                    safeDestroy(h)
                    Highlights[pl] = nil
                end
            end

            local function getHighlight(plr)
                if not Highlights[plr] then
                    local h = Instance.new("Highlight")
                    h.Adornee = (plr.Character and plr.Character:IsA("Model")) and plr.Character or nil
                    h.FillTransparency = 0.8
                    h.OutlineTransparency = 0.6
                    h.Parent = Workspace
                    Highlights[plr] = h
                end
                return Highlights[plr]
            end

            local function chooseTargetPart()
                if AimbotState.TargetPart == "Random" then
                    return (math.random() < 0.5) and "Head" or "Torso"
                end
                return AimbotState.TargetPart
            end

            local function intensityToSmoothing(intensity)
                local t = intensity / 100
                return 0.15 + (0.83 * (t ^ 1.6))
            end

            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.IgnoreWater = true
            rayParams.FilterDescendantsInstances = { Player.Character }

            local function visibilityScore(part)
                if not (part and part.Parent) then return 0 end
                local origin = Camera.CFrame.Position
                local pos = part.Position
                local offsets = {
                    Vector3.new(0, 0, 0),
                    Vector3.new(0.2, 0, 0),
                    Vector3.new(-0.2, 0, 0),
                    Vector3.new(0, 0.2, 0),
                    Vector3.new(0, -0.2, 0),
                }

                local visible = 0
                for _, off in ipairs(offsets) do
                    local worldPos = pos + (part.CFrame:VectorToWorldSpace(off))
                    local dir = worldPos - origin
                    local res = Workspace:Raycast(origin, dir.Unit * dir.Magnitude, rayParams)
                    if not res or (res.Instance and res.Instance:IsDescendantOf(part.Parent)) then
                        visible = visible + 1
                    end
                end
                return visible / #offsets
            end

            local function colorFromVis(v)
                local red = Color3.fromRGB(200, 0, 0)
                local yellow = Color3.fromRGB(220, 180, 0)
                local green = Color3.fromRGB(0, 200, 0)
                if v <= 0.5 then
                    return red:Lerp(yellow, v / 0.5)
                else
                    return yellow:Lerp(green, (v - 0.5) / 0.5)
                end
            end

            local function updateHighlights()
                for _, pl in ipairs(Players:GetPlayers()) do
                    if pl ~= Player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local targetPart = pl.Character:FindFirstChild(AimbotState.TargetPart) or pl.Character:FindFirstChild("Head")
                        if targetPart then
                            local vis = visibilityScore(targetPart)
                            local h = getHighlight(pl)
                            h.Adornee = pl.Character
                            h.FillColor = colorFromVis(vis)
                            h.OutlineColor = h.FillColor
                            h.FillTransparency = 0.9 - (vis * 0.75)
                            h.OutlineTransparency = 0.6 - (vis * 0.5)
                        else
                            removeHighlight(pl)
                        end
                    else
                        removeHighlight(pl)
                    end
                end
            end

            local function findNearestTarget()
                local bestDist, bestPlayer, bestPart = math.huge, nil, nil
                for _, pl in pairs(Players:GetPlayers()) do
                    if pl ~= Player and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                        local hrp = pl.Character.HumanoidRootPart
                        local dir = (hrp.Position - Camera.CFrame.Position)
                        local dist = dir.Magnitude
                        if dist <= AimbotState.Radius then
                            local lookVector = Camera.CFrame.LookVector
                            local dot = math.clamp(lookVector:Dot(dir.Unit), -1, 1)
                            local angle = math.deg(math.acos(dot))
                            if angle <= (AimbotState.FOV / 2) then
                                local targetPart = pl.Character:FindFirstChild(chooseTargetPart()) or hrp
                                if targetPart and visibilityScore(targetPart) > 0.3 then
                                    if dist < bestDist then
                                        bestDist = dist
                                        bestPlayer = pl
                                        bestPart = targetPart
                                    end
                                end
                            end
                        end
                    end
                end
                return bestPlayer, bestPart, bestDist
            end

            local function aimAt(part, smoothing, dist)
                if not part then return end
                if dist < 50 then
                    local desired = CFrame.lookAt(Camera.CFrame.Position, part.Position)
                    Camera.CFrame = Camera.CFrame:Lerp(desired, smoothing)
                else
                    local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dx, dy = screenPos.X - Mouse.X, screenPos.Y - Mouse.Y
                        pcall(function() mousemoverel(dx * smoothing * 0.05, dy * smoothing * 0.05) end)
                    end
                end
            end

            local function renderStep(dt)
                if not AimbotState.Enabled then return end
                updateHighlights()
                local target, part, dist = findNearestTarget()
                if target and part then
                    aimAt(part, intensityToSmoothing(AimbotState.Intensity), dist)
                end
            end

            local function disable()
                RunService:UnbindFromRenderStep("AimbotUpdate")
                cleanupAllHighlights()
                for _, conn in pairs(connections) do
                    conn:Disconnect()
                end
                connections = {}
            end

            if state then
                -- immediately show highlights
                updateHighlights()
                connections.charAdded = Player.CharacterAdded:Connect(function(char)
                    rayParams.FilterDescendantsInstances = { char }
                    updateHighlights()
                end)
                connections.playerRemoving = Players.PlayerRemoving:Connect(function(plr)
                    removeHighlight(plr)
                end)
                RunService:BindToRenderStep("AimbotUpdate", Enum.RenderPriority.Camera.Value + 1, renderStep)
            else
                disable()
            end
        end
    }),


    Tabs.Aimbot:Dropdown({
        Title = "Target Part",
        Desc = "Which body part to target",
        Values = { "Head", "Torso" },
        Value = "Head",
        Callback = function(option)
            AimbotState.TargetPart = option
            print("Target part set to:", option)
        end
    }),

    Tabs.Aimbot:Slider({
        Title = "Effect Intensity",
        Desc = "0-50 = smooth, 90-100 = snappy",
        Value = { Min = 0, Max = 100, Default = 50 },
        Callback = function(value)
            AimbotState.Intensity = value
        end,
    }),

    Tabs.Aimbot:Slider({
        Title = "FOV (degrees)",
        Desc = "Field of view used to pick targets",
        Value = { Min = 10, Max = 180, Default = 90 },
        Callback = function(value)
            AimbotState.FOV = value
        end,
    }),

    Tabs.Aimbot:Slider({
        Title = "Radius (studs)",
        Desc = "Max search distance",
        Value = { Min = 10, Max = 1000, Default = 100 },
        Callback = function(value)
            AimbotState.Radius = value
        end,
    }),
}

local AppearanceElements = { }
