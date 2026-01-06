local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local function waitForChildSafe(parent, name, timeout)
	timeout = timeout or 5
	local start = os.clock()
	local obj = parent:FindFirstChild(name)
	while not obj and os.clock() - start < timeout do
		parent.ChildAdded:Wait()
		obj = parent:FindFirstChild(name)
	end
	return obj
end

local function waitForCharacter(player, timeout)
	timeout = timeout or 5
	if player.Character then
		return player.Character
	end
	local start = os.clock()
	while os.clock() - start < timeout do
		local char = player.Character
		if char then
			return char
		end
		RunService.Heartbeat:Wait()
	end
	return nil
end

local function neutralizeRoomScripts(roomsFolder)
	for _, obj in ipairs(roomsFolder:GetDescendants()) do
		if obj:IsA("BaseScript") then
			obj.Disabled = true
			obj:Destroy()
		end
	end
end

local function grace()
	local LocalPlayer = Players.LocalPlayer
	if not LocalPlayer then return end

	for _, obj in ipairs(LocalPlayer:GetDescendants()) do
		if obj.Name == "NOW" then
			obj:Destroy()
		end
	end

	local beacons = waitForChildSafe(workspace, "Beacons", 3)
	local scriptFolder = waitForChildSafe(workspace, "Script", 3)
	local beaconPickup = scriptFolder and waitForChildSafe(scriptFolder, "BeaconPickup", 3)

	if beacons and beaconPickup then
		for _, child in ipairs(beacons:GetChildren()) do
			if child.Name == "Part" then
				beaconPickup:FireServer(child)
			end
		end
	end

	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			local p = obj.Name:sub(1, 4)
			if p == "Send" or p == "Kill" then
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
	local player = Players.LocalPlayer
	if not player then return end

	local character = waitForCharacter(player, 5)
	if not character then return end

	local root = waitForChildSafe(character, "HumanoidRootPart", 3)
	if not root then return end

	local camera = workspace.CurrentCamera
	if not camera then return end

	local roomsFolder = workspace:FindFirstChild("Rooms")
	if not roomsFolder then return end

	-- CRITICAL FIX: kill Door / Room scripts BEFORE they yield
	neutralizeRoomScripts(roomsFolder)

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
			local hinged = vault:FindFirstChild("Hinged")
			local cylinder = hinged and hinged:FindFirstChild("Cylinder")
			local prompt = cylinder and cylinder:FindFirstChild("ProximityPrompt")
			if prompt and ReplicatedStorage:FindFirstChild("TriggerPrompt") then
				ReplicatedStorage.TriggerPrompt:FireServer(prompt)
			end
			if ReplicatedStorage:FindFirstChild("Events")
				and ReplicatedStorage.Events:FindFirstChild("EnteredSaferoom") then
				ReplicatedStorage.Events.EnteredSaferoom:FireServer()
			end
		end
	end

	if #roomModels == 0 then return end

	table.sort(roomModels, function(a, b)
		return a.number < b.number
	end)

	local safeRoom = roomsFolder:FindFirstChild("SafeRoom", true)
	local deathTimer = workspace:FindFirstChild("DEATHTIMER")
	local deathValue = deathTimer and deathTimer.Value or 0

	if safeRoom
		and safeRoom:IsA("Model")
		and not safeRoom:IsDescendantOf(roomModels[#roomModels].model)
		and not safeRoom:IsDescendantOf(roomModels[1].model)
		and deathValue <= 0 then

		local scale = safeRoom:FindFirstChild("Scale")
		local hitbox = scale and scale:FindFirstChild("hitbox")
		if hitbox and hitbox:IsA("BasePart") then
			root.CFrame = hitbox.CFrame * CFrame.Angles(0, math.rad(225), 0)
			camera.CFrame = root.CFrame
		end
	else
		local index = #roomModels
		if safeRoom and safeRoom:IsA("Model")
			and deathTimer
			and not deathTimer:GetAttribute("AUTOGO") then
			index = math.min(11, #roomModels)
		end

		local highestModel = roomModels[index] and roomModels[index].model
		local exit = highestModel and highestModel:FindFirstChild("Exit")
		if exit and exit:IsA("BasePart") then
			root.CFrame = exit.CFrame * CFrame.Angles(0, math.rad(45), 0)
			camera.CFrame = root.CFrame
		end
	end

	for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
		if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
			local p = obj.Name:sub(1, 4)
			if p == "Send" or p == "Kill" then
				obj:Destroy()
			end
		end
	end
end



local hbGrace1, hbGrace2

local Window = Rayfield:CreateWindow({
    Name = "Grace",
    LoadingTitle = "Grace whatever",
    LoadingSubtitle = "by mafuyu",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MyRayfieldUI",
        FileName = "Config1"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", "home")

MainTab:CreateToggle({
    Name = "❌Grace Reprieve [PATCHED]❌",
    CurrentValue = false,
    Flag = "GraceReprieve",
    Callback = function(Value)
        if Value then
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            if hookfunction then
                hookfunction(LocalPlayer.Kick, function() end)
            end

            if hookmetamethod then
                local oldNamecall
                oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                    if self == LocalPlayer and getnamecallmethod():lower() == "kick" then
                        return
                    end
                    return oldNamecall(self, ...)
                end)
            end

            hbGrace1 = RunService.Heartbeat:Connect(grace)
        else
            if hbGrace1 then hbGrace1:Disconnect() hbGrace1 = nil end
        end
    end,
})

MainTab:CreateToggle({
    Name = "Grace Regular [NORMAL OR ZEN GAMEMODE]",
    CurrentValue = false,
    Flag = "GraceRegular",
    Callback = function(Value)
        if Value then
            hbGrace2 = RunService.Heartbeat:Connect(grace2)
        else
            if hbGrace2 then hbGrace2:Disconnect() hbGrace2 = nil end
        end
    end,
})

MainTab:CreateButton({
    Name = "Create Lobby with OP Modifiers",
    Callback = function()
        pcall(function()
            ReplicatedStorage.CreateLobby:FireServer({
                a=1,
                p=50,
                s=3,
                m={ms={II=true,QU=true,Ep=4,ei=true,oq=true,uR=true,wT=true,TQ=true,rq=10,YQ=3,tr=true,rI=true,ii=3,UO=true,CS=3,IR=true,RO=true,Ty=true,qi=true,im=true,Op=true,tQ=true,pe=true,iP=true,uY=true,MI=true,uy=true,Qr=true,iu=true,ir=true,KA=2,QP=true,WR=true,rt=true,TP=true,Ou=true,UT=5,yw=true,pp=true,To=true,Qi=true,Rw=true,Wt=true,Up=true,Er=true,uu=true,qY=true,RF=true,DR=true,PW=true,HE=true,it=true,iS=true,yE=true,wy=true,eW=3},
                vav=false,
                v=false
                },
                _m=1,
                c=1
            })
        end)
    end,
})

MainTab:CreateButton({
    Name = "Buy crown [uses 100 keys]",
    Callback = function()
        pcall(function()
            game:GetService("ReplicatedStorage"):WaitForChild("BuyKCrown"):InvokeServer()
        end)
    end,
})

MainTab:CreateButton({
    Name = "Return to Lobby",
    Callback = function()
        pcall(function()
            ReplicatedStorage:WaitForChild("byebyemyFRIENDbacktothelobby"):FireServer()
        end)
    end,
})

MainTab:CreateButton({
    Name = "Get badges [kills you]",
    Callback = function()
        local HttpService = game:GetService("HttpService")
        local BadgeGotRemote = game:GetService("ReplicatedStorage"):WaitForChild("BadgeGot")
        local httpRequest = http_request or request
        local universeId = game.GameId
        local function getAllBadgeIds()
            local badgeIds, cursor, url = {}, ""
            repeat
                url = ("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&sortOrder=Asc%s"):format(universeId, cursor ~= "" and "&cursor=" .. cursor or "")
                local response = httpRequest({Url = url, Method = "GET"})
                if not response or response.StatusCode ~= 200 then break end
                local data = HttpService:JSONDecode(response.Body)
                for i = 1, #data.data do
                    badgeIds[#badgeIds+1] = data.data[i].id
                end
                cursor = data.nextPageCursor or ""
            until cursor == ""
            return badgeIds
        end
        local allBadges = getAllBadgeIds()
        for i = 1, #allBadges do
            BadgeGotRemote:FireServer(allBadges[i])
        end
    end,
})
MainTab:CreateLabel("P.S. Use Get badges in Reprieve and in a game with all the modifiers if you want all the badges")
