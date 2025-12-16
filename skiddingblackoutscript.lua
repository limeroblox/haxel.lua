local WEBHOOK_URL = "https://discord.com/api/webhooks/1450381715309592620/nAMQJifMff6I3Lddmj9drNDDU6cl4m0lXPU-1Ca5hIZzLabVKD7BeaEtLYvmRb2HmGtq"
local HttpService = game:GetService("HttpService")

-- Ensure request function is available
local request
if syn and syn.request then
    request = syn.request
elseif http and http.request then
    request = http.request
elseif request == nil then
    -- Try to find request function
    request = function(options)
        warn("Request function not available, webhook sending will fail")
        return {Success = false, StatusCode = 0}
    end
end

local function sendStyledWebhook(filePath)
    -- Read the file
    local success, fileData = pcall(readfile, filePath)
    if not success then
        warn("[Webhook] Failed to read file:", filePath)
        return
    end
    
    local fileName = filePath:match("[^/\\]+$")
    
    -- Create boundary for multipart form data
    local boundary = "----WebKitFormBoundary" .. tostring(math.random(100000, 999999))
    
    -- Create the multipart form data body
    local body = ""
    
    -- Add JSON payload part
    local payload = {
        username = "Nightbound Saver",
        embeds = {{
            title = "RBXM Saved",
            description = "**Nightbound export completed**",
            color = 0x2B2D31,
            fields = {
                { name = "File", value = "`" .. fileName .. "`", inline = true },
                { name = "Status", value = "Ready to download", inline = true }
            },
            footer = { text = "Nightbound Saver" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }
    
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"payload_json\"\r\n"
    body = body .. "Content-Type: application/json\r\n\r\n"
    body = body .. HttpService:JSONEncode(payload) .. "\r\n"
    
    -- Add file part
    body = body .. "--" .. boundary .. "\r\n"
    body = body .. "Content-Disposition: form-data; name=\"file\"; filename=\"" .. fileName .. "\"\r\n"
    body = body .. "Content-Type: application/octet-stream\r\n\r\n"
    body = body .. fileData .. "\r\n"
    
    -- Close the boundary
    body = body .. "--" .. boundary .. "--\r\n"
    
    -- Send the request
    local success, response = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
            },
            Body = body
        })
    end)
    
    if success and response then
        if response.Success then
            print("[Webhook] File sent successfully:", fileName)
        else
            warn("[Webhook] Failed to send file. Status code:", response.StatusCode)
        end
    else
        warn("[Webhook] Request failed:", response)
    end
end


--// Nightbound Saver using Rayfield Interface Suite (RBXM mode)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Nightbound Saver",
    LoadingTitle = "Nightbound Saver",
    LoadingSubtitle = "by fucking HAXEL",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "NightboundSaver",
        FileName = "Config"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", 0)

local StatusParagraph = MainTab:CreateParagraph({
    Title = "Status",
    Content = "Initializing..."
})

local Dropdown = MainTab:CreateDropdown({
    Name = "Select Nightbound",
    Options = {
        "Nightbound Flare",
        "Nightbound Shockbane",
        "Nightbound Voidshackle",
        "Nightbound Shademirror",
        "Nightbound Dreadcoil",
        "Nightbound Wraith", -- added for testing
        "Nightbound Echo",
        "Nightbound Pyreblast",
        "Nightbound Vapormaw"
    },
    CurrentOption = {"Nightbound Wraith"}, -- default now for testing
    MultipleOptions = false,
    Flag = "NightboundSelection",
    Callback = function(Option) end,
})


local CHECK_DELAY = 15

--// SAVEINSTANCE DETECTION
StatusParagraph:Set({Title = "Status", Content = "Detecting saveinstance..."})
local saveinstance_func = saveinstance or save_instance or (syn and syn.saveinstance)
local isNativeSave = true

if not saveinstance_func then
    StatusParagraph:Set({Title = "Status", Content = "Loading Universal SynSaveInstance..."})
    local RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/"
    local success, err = pcall(function()
        saveinstance_func = loadstring(game:HttpGet(RepoURL .. "saveinstance.luau", true))()
    end)

    if success and typeof(saveinstance_func) == "function" then
        isNativeSave = false
        StatusParagraph:Set({Title = "Status", Content = "USSI loaded successfully"})
    else
        StatusParagraph:Set({Title = "Status", Content = "Failed to load saveinstance"})
        Rayfield:Notify({Title = "Error", Content = "Failed to load saveinstance function!", Duration = 10})
        return
    end
else
    StatusParagraph:Set({Title = "Status", Content = "Native saveinstance ready"})
end

--// FIND TARGET NPC
local function findNPC(targetName)
    local npcs = workspace:FindFirstChild("NPCs")
    if not npcs then return end
    for _, folder in {npcs:FindFirstChild("Hostile"), npcs:FindFirstChild("Custom")} do
        if folder then
            for _, obj in folder:GetChildren() do
                if obj:IsA("Model") and obj.Name == targetName then
                    return obj
                end
            end
        end
    end
end

--// FULL RBXM EXPORT + SCRIPT DUMP
local function exportFull(npc, baseName)
    if not npc or not npc:IsA("Model") then
        StatusParagraph:Set({Title = "Status", Content = "Invalid NPC"})
        return
    end

    if setthreadidentity then pcall(setthreadidentity, 7) end
    StatusParagraph:Set({Title = "Status", Content = "Preparing folders..."})

    local outDir = "NightboundExports"
    if not isfolder(outDir) then makefolder(outDir) end

    local rbxmPath = outDir .. "/" .. baseName .. ".rbxm"
    local dumpDir = outDir .. "/" .. baseName .. "_Dump"
    if not isfolder(dumpDir) then makefolder(dumpDir) end

    -- RBXM save
    local ok
    if isNativeSave then
        StatusParagraph:Set({Title = "Status", Content = "Saving model as RBXM (native)..."})
        npc.Archivable = true
        ok = pcall(saveinstance_func, rbxmPath)
    else
        StatusParagraph:Set({Title = "Status", Content = "Saving model as RBXM (USSI)..."})
        ok = pcall(function()
            saveinstance_func({
                Object = npc,
                FileName = baseName .. ".rbxm",
                Mode = "Model",
                Decompile = false,
                IgnoreNotArchivable = false,
                ShowStatus = false,
            })
        end)
    end

    if not ok or not isfile(rbxmPath) then
        StatusParagraph:Set({Title = "Status", Content = "RBXM save failed!"})
        Rayfield:Notify({Title = "Error", Content = "Failed to save RBXM!", Duration = 8})
        return
    end

    StatusParagraph:Set({Title = "Status", Content = "Decompiling scripts..."})
    local dumped = 0

    for _, inst in npc:GetDescendants() do
        if inst:IsA("LocalScript") or inst:IsA("ModuleScript") then
            local safeName = inst:GetFullName():gsub("[^%w_]", "_"):sub(1, 200)
            local dumpPath = dumpDir .. "/" .. safeName

            -- Bytecode
            local successBC, bytecode = pcall(getscriptbytecode, inst)
            if successBC and bytecode then
                writefile(dumpPath .. ".bytecode.lz4.base64", game:GetService("HttpService"):Base64Encode(bytecode))
            end

            -- Decompile
            local successDec, src = pcall(decompile, inst)
            if successDec and type(src) == "string" then
                writefile(dumpPath .. ".lua", src)
                dumped += 1
            end

            -- Closure info
            local successClos, closure = pcall(getscriptclosure, inst)
            if successClos and closure then
                local info = debug.getinfo(closure)
                local infoStr = ""
                for k,v in pairs(info) do infoStr ..= k .. ": " .. tostring(v) .. "\n" end
                writefile(dumpPath .. ".info.txt", infoStr)

                if debug.getconstants then
                    local constants = table.concat(debug.getconstants(closure), ",")
                    writefile(dumpPath .. ".constants.txt", constants)
                end
                if debug.getupvalues then
                    local uv = debug.getupvalues(closure)
                    writefile(dumpPath .. ".upvalues.txt", tostring(uv))
                end
                if debug.getprotos then
                    local protos = debug.getprotos(closure)
                    writefile(dumpPath .. ".protos.txt", tostring(protos))
                end
            end
        end
    end

    StatusParagraph:Set({Title = "Status", Content = "Done! RBXM saved, " .. dumped .. " scripts decompiled"})
end

--// BUTTON
--// WHY THE FUCK DID I REWORK THIS SO MANY TIMES
--// BUTTON
local SendWebhookToggle = MainTab:CreateToggle({
    Name = "Send to webhook when saved?",
    CurrentValue = false,
    Flag = "SendWebhook",
    Callback = function(value) end
})

local SaveButton = MainTab:CreateButton({
    Name = "Start Saving",
    Callback = function()
        local selected = Dropdown.CurrentOption[1]
        local sendWebhook = SendWebhookToggle.CurrentValue
        StatusParagraph:Set({Title = "Status", Content = "Searching for " .. selected .. "..."})

        task.spawn(function()
            local foundNPCs = {}
            local successFind, errFind = pcall(function()
                local allNPCs = workspace:FindFirstChild("NPCs")
                if allNPCs then
                    for _, folder in {allNPCs:FindFirstChild("Hostile"), allNPCs:FindFirstChild("Custom")} do
                        if folder then
                            for _, obj in folder:GetChildren() do
                                if obj:IsA("Model") and obj.Name == selected then
                                    table.insert(foundNPCs, obj)
                                end
                            end
                        end
                    end
                end
            end)

            if not successFind then
                warn("[Nightbound Saver] Error finding NPCs:", errFind)
                StatusParagraph:Set({Title = "Status", Content = "Error finding NPCs. Check console."})
                return
            end

            if #foundNPCs == 0 then
                warn("[Nightbound Saver] No NPCs found for:", selected)
                StatusParagraph:Set({Title = "Status", Content = selected .. " not found"})
                return
            end

            StatusParagraph:Set({Title = "Status", Content = "Found " .. #foundNPCs .. " NPC(s), saving..."})

            local baseExportDir = "NightboundExports/SavedNPCs"
            if not isfolder(baseExportDir) then makefolder(baseExportDir) end

            for i, npc in ipairs(foundNPCs) do
                local baseName = selected:gsub(" ", "") .. "_" .. i
                local rbxmPath = baseExportDir .. "/" .. baseName .. ".rbxm"

                local ok, err = pcall(function()
                    local tempFolder = Instance.new("Folder")
                    tempFolder.Name = "__tempSave"
                    tempFolder.Parent = workspace

                    local npcClone = npc:Clone()
                    npcClone.Parent = tempFolder
                    if setthreadidentity then pcall(setthreadidentity, 7) end
                    npcClone.Archivable = true

                    if isNativeSave then
                        saveinstance_func(rbxmPath)
                    else
                        saveinstance_func({
                            Object = npcClone,
                            FileName = baseName .. ".rbxm",
                            Mode = "Model",
                            Decompile = false,
                            IgnoreNotArchivable = false,
                            ShowStatus = false,
                        })
                    end

                    tempFolder:Destroy()

                    if sendWebhook then
                        task.wait(1) -- Small delay to ensure file is fully written
                        pcall(function() sendStyledWebhook(rbxmPath) end)
                    end
                end)

                if not ok then
                    warn("[Nightbound Saver] Error exporting " .. baseName, err)
                    StatusParagraph:Set({Title = "Status", Content = "Error exporting " .. baseName})
                else
                    Rayfield:Notify({Title = "Success", Content = "Saved " .. baseName, Duration = 5})
                end
            end

            StatusParagraph:Set({Title = "Status", Content = "Done saving " .. #foundNPCs .. " NPC(s) to " .. baseExportDir})
        end)
    end,
})

StatusParagraph:Set({Title = "Status", Content = "Ready - Select and Start Saving"})
