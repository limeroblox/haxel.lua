loadstring(game:HttpGet("https://raw.githubusercontent.com/limeroblox/meowware.lua/refs/heads/main/core/ui.lua"))()
local Version = "MeowWare.lua | VER: 0.0.1 [DEV]"

-- [This is where all the functions are stored for toggles, buttons, sliders, color pickers, etc] --

local function StartKillAll()
	local LOOP_DELAY = 0.01
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

	Library:Notify({
		Title = "Kill All",
		Description = "Kill All Started",
		Time = 2.5,
	})

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
		local args = { ... }

		if method == "Raycast" then
			return {
				Instance = workspace.Terrain,
				Position = hrp and hrp.Position or Vector3.zero,
				Normal = Vector3.new(0, 1, 0),
				Material = Enum.Material.Grass
			}
		end

		if method == "FireServer" or method == "InvokeServer" then
			for i, v in ipairs(args) do
				if typeof(v) == "Vector3" then
					args[i] = hrp and (hrp.Position + Vector3.new(
						math.random(), math.random(), math.random()
					) * SPOOF_RANGE) or Vector3.zero
				end
			end
			return oldNamecall(self, unpack(args))
		end

		return oldNamecall(self, ...)
	end

	setreadonly(mt, true)

	--// CHARACTER CHECKS
	local function getHumanoid(char)
		return char and char:FindFirstChildOfClass("Humanoid")
	end

	local function isAlive(char)
		local hum = getHumanoid(char)
		return hum and hum.Health > 0
	end

	--// ATTACK (PURE SPAM)
	local function attack(char)
		local part = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
		if not part then return end

		pcall(function()
			SwingRemote:InvokeServer()
			HitRemote:FireServer(part, part.Position)
		end)
	end

	--// ATTACK PLAYER UNTIL DEAD (NO LIMIT)
	local function attackPlayer(target)
		if not target or target == LocalPlayer then return end

		while true do
			local char = target.Character
			if not char or not isAlive(char) then
				break
			end

			attack(char)
			task.wait(LOOP_DELAY)
		end
	end

	--// EXISTING PLAYERS
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			task.spawn(attackPlayer, plr)
			task.wait()
		end
	end

	--// NEW PLAYERS
	Players.PlayerAdded:Connect(function(plr)
		if plr ~= LocalPlayer then
			task.spawn(attackPlayer, plr)
		end
	end)
end


-- [END OF FUNCTIONS] --

local Window = Library:CreateWindow({
  AutoShow = true,
  MobileButtonsSide = "Left",
  Center = true,
	Title = "Blackout: Modded",
	Footer = Version,
	Icon = 84903466827078,
	NotifySide = "Right",
	ShowCustomCursor = false,
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

local GroupBoxes = {
	LeftGroupBox = Tabs.Main:AddLeftGroupbox("Kill All", "boxes")
}
local MyButton = GroupBoxes.LeftGroupBox:AddButton({
    Text = "Kill All",
    Func = function()
        StartKillAll()
    end,
    DoubleClick = false,

    Tooltip = "Kills Everyone, You Need To Hold Out A Melee For This To Work",
    DisabledTooltip = "This Button Is Currently Disabled And Will NOT Work",

    Disabled = false, -- Will disable the button (true / false)
    Visible  = true,  -- Will make the button invisible (true / false)
    Risky    = false, -- Makes the text red (Default = false)
})


