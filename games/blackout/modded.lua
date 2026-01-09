local repo 			= "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/" 
local Library 		= loadstring(game:HttpGet(repo .. "Library.lua"))() 
local ThemeManager 	= loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))() 
local SaveManager 	= loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()
local Options 		= Library.Options
local Toggles 		= Library.Toggles
local Version 		= "MeowWare.lua | VER: 0.0.1 [DEV]"
Library.ForceCheckbox = false 
Library.ShowToggleFrameInKeybinds = true 

-- [[ Ui Based ]] --

-- [This is where all the functions are stored for toggles, buttons, sliders, color pickers, etc] --

local function StartKillAll()
	local LOOP_DELAY = 0.01
	local SPOOF_RANGE = 3
	local running = true
	
	-- Track all spawned KillTarget loops
	local activeLoops = {}
	
	--// SERVICES
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local RS = game:GetService("ReplicatedStorage")

	Library:Notify({
		Title = "Kill All",
		Description = "Kill All Instance Started",
		Time = 2.5,
	})

	--// KILLTARGET FUNCTION (INFINITE LOOP INSIDE)
	local function KillTarget()
		--// REMOTES
		local MeleeStorage = RS:WaitForChild("MeleeStorage")
		local Events = MeleeStorage:WaitForChild("Events")
		local SwingRemote = Events:WaitForChild("Swing")
		local HitRemote = Events:WaitForChild("Hit")
		
		local killLoopRunning = true
		local loopId = #activeLoops + 1
		activeLoops[loopId] = true
		
		--// INFINITE KILL LOOP
		task.spawn(function()
			while killLoopRunning do
				--// HRP
				local char = LocalPlayer.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				
				--// SETUP SPOOFING
				local oldIndex, oldNamecall
				local mt = getrawmetatable(game)
				
				setreadonly(mt, false)
				
				oldIndex = mt.__index
				oldNamecall = mt.__namecall
				
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
								args[i] = hrp
									and (hrp.Position + Vector3.new(
										math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)
									) * SPOOF_RANGE)
									or Vector3.zero
							end
						end
						return oldNamecall(self, unpack(args))
					end
					
					return oldNamecall(self, ...)
				end
				
				setreadonly(mt, true)
				
				--// HIT ALL PLAYERS
				for _, plr in ipairs(Players:GetPlayers()) do
					if plr ~= LocalPlayer then
						local targetChar = plr.Character
						if targetChar and targetChar:FindFirstChildOfClass("Humanoid") then
							local hum = targetChar:FindFirstChildOfClass("Humanoid")
							if hum and hum.Health > 0 then
								local part = targetChar:FindFirstChild("Head") 
									or targetChar:FindFirstChild("HumanoidRootPart")
								
								if part then
									pcall(function()
										SwingRemote:InvokeServer()
										HitRemote:FireServer(part, part.Position)
									end)
								end
							end
						end
					end
				end
				
				--// RESTORE METATABLE
				setreadonly(mt, false)
				mt.__index = oldIndex
				mt.__namecall = oldNamecall
				setreadonly(mt, true)
				
				task.wait(LOOP_DELAY)
			end
			
			-- Clean up when loop stops
			activeLoops[loopId] = nil
		end)
		
		-- Return a function to stop this specific KillTarget loop
		return function()
			killLoopRunning = false
			activeLoops[loopId] = nil
		end
	end

	--// SPAWN MULTIPLE KILLTARGET LOOPS (CREATES SHREDDER EFFECT)
	local stopFunctions = {}
	for i = 1, 10 do  -- Spawn 10 KillTarget loops for shredder effect
		local stopFunc = KillTarget()
		table.insert(stopFunctions, stopFunc)
		task.wait(0.001) -- Small delay between spawning loops
	end

	--// MONITOR LOOP (STOPS ALL KILLTARGET LOOPS WHEN EVERYONE DEAD)
	task.spawn(function()
		while running do
			-- Check if anyone is still alive
			local anyoneAlive = false
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer then
					local char = plr.Character
					if char and char:FindFirstChildOfClass("Humanoid") then
						local hum = char:FindFirstChildOfClass("Humanoid")
						if hum and hum.Health > 0 then
							anyoneAlive = true
							break
						end
					end
				end
			end
			
			-- If no one is alive, stop ALL KillTarget loops
			if not anyoneAlive then
				running = false
				
				-- Stop all spawned KillTarget loops
				for _, stopFunc in ipairs(stopFunctions) do
					pcall(stopFunc)
				end
				
				-- Clear active loops
				activeLoops = {}
				
				Library:Notify({
					Title = "Kill All",
					Description = "Kill All Finished (Instance)",
					Time = 2.5,
				})
				break
			end
			
			task.wait(0.1) -- Check less frequently
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

    Disabled = false, 
    Visible  = true,  
    Risky    = false, 
})


