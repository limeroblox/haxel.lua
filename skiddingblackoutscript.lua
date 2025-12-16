local WEBHOOK_URL = "https://discord.com/api/webhooks/1450349493743652955/d-BpW7PGhWHfakh-UG1nbDWekGXA_1rUaFG6QC42iWowkI7ALseaEXmtXIFkHQYXr2DW"
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
    -- First check if file exists
    if not isfile(filePath) then
        warn("[Webhook] File does not exist:", filePath)
        return false
    end
    
    -- Get file size first to avoid reading huge files
    local fileInfo = readfile and readfile(filePath, true) -- Check if it exists
    if not fileInfo then
        warn("[Webhook] Cannot access file:", filePath)
        return false
    end
    
    -- Read the file
    local success, fileData = pcall(readfile, filePath)
    if not success then
        warn("[Webhook] Failed to read file:", filePath)
        return false
    end
    
    -- Check if file is empty
    if #fileData == 0 then
        warn("[Webhook] File is empty:", filePath)
        return false
    end
    
    local fileName = filePath:match("[^/\\]+$")
    print("[Webhook] Attempting to send file:", fileName, "Size:", #fileData, "bytes")
    
    -- Create boundary for multipart form data
    local boundary = "----WebKitFormBoundary" .. tostring(math.random(100000, 999999))
    
    -- Create the multipart form data body
    local body = ""
    
    -- Add JSON payload part
    local payload = {
        username = "Haxel's Cool Webhook",
        embeds = {{
            title = "RBXM Saved",
            description = "**Export Completed**",
            color = 0x2B2D31,
            fields = {
                { name = "File", value = "`" .. fileName .. "`", inline = true },
                { name = "Size", value = string.format("%.2f KB", #fileData / 1024), inline = true }
            },
            thumbnail = { url = "https://static.wikitide.net/blackoutwiki/5/54/Flare.png" }, 
            footer = { text = "Saveinstance()" },
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
    local requestSuccess, response = pcall(function()
        return request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "multipart/form-data; boundary=" .. boundary,
                ["Content-Length"] = tostring(#body)
            },
            Body = body
        })
    end)
    
    if requestSuccess and response then
        if response.Success then
            print("[Webhook] ✓ File sent successfully:", fileName)
            return true
        else
            warn("[Webhook] ✗ Failed to send file. Status code:", response.StatusCode)
            if response.Body then
                warn("[Webhook] Response body:", response.Body)
            end
            return false
        end
    else
        warn("[Webhook] ✗ Request failed:", response)
        return false
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
        "Nightbound Wraith",
        "Nightbound Echo",
        "Nightbound Pyreblast",
        "Nightbound Vapormaw"
    },
    CurrentOption = {"Nightbound Wraith"},
    MultipleOptions = false,
    Flag = "NightboundSelection",
    Callback = function(Option) end,
})

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

            -- Create base directory
            local baseExportDir = "NightboundExports/SavedNPCs"
            if not isfolder("NightboundExports") then
                makefolder("NightboundExports")
            end
            if not isfolder(baseExportDir) then 
                makefolder(baseExportDir) 
            end

            local savedFiles = 0
            local webhookResults = {}
            
            for i, npc in ipairs(foundNPCs) do
                local baseName = selected:gsub(" ", "") .. "_" .. i
                local rbxmPath = baseExportDir .. "/" .. baseName .. ".rbxm"
                
                print("[Saver] Attempting to save:", baseName, "to", rbxmPath)

                local ok, err = pcall(function()
                    -- Create a temporary location for the NPC
                    local tempFolder = Instance.new("Folder")
                    tempFolder.Name = "__tempSave_" .. tostring(math.random(1000, 9999))
                    tempFolder.Parent = workspace

                    -- Clone and prepare the NPC
                    local npcClone = npc:Clone()
                    npcClone.Parent = tempFolder
                    if setthreadidentity then 
                        pcall(setthreadidentity, 7) 
                    end
                    npcClone.Archivable = true

                    -- Save using the appropriate method
                    if isNativeSave then
                        StatusParagraph:Set({Title = "Status", Content = "Saving " .. baseName .. " (native)..."})
                        local successSave = pcall(function()
                            saveinstance_func(rbxmPath, npcClone)
                        end)
                        if not successSave then
                            -- Try alternative syntax
                            saveinstance_func(rbxmPath)
                        end
                    else
                        StatusParagraph:Set({Title = "Status", Content = "Saving " .. baseName .. " (USSI)..."})
                        saveinstance_func({
                            Object = npcClone,
                            FileName = baseName .. ".rbxm",
                            Mode = "Model",
                            Decompile = false,
                            IgnoreNotArchivable = false,
                            ShowStatus = false,
                            Path = baseExportDir
                        })
                    end

                    -- Clean up
                    tempFolder:Destroy()

                    -- Check if file was actually created
                    task.wait(2) -- Give time for file to write
                    
                    if isfile(rbxmPath) then
                        savedFiles = savedFiles + 1
                        print("[Saver] ✓ Successfully saved:", rbxmPath)
                        
                        -- Send webhook if enabled
                        if sendWebhook then
                            StatusParagraph:Set({Title = "Status", Content = "Sending webhook for " .. baseName .. "..."})
                            task.wait(1) -- Small delay
                            
                            local webhookSuccess = sendStyledWebhook(rbxmPath)
                            table.insert(webhookResults, {
                                name = baseName,
                                success = webhookSuccess
                            })
                        end
                    else
                        warn("[Saver] ✗ File not created after save attempt:", rbxmPath)
                    end
                end)

                if not ok then
                    warn("[Nightbound Saver] Error exporting " .. baseName .. ":", err)
                    StatusParagraph:Set({Title = "Status", Content = "Error exporting " .. baseName})
                else
                    Rayfield:Notify({Title = "Success", Content = "Saved " .. baseName, Duration = 3})
                end
            end

            -- Final status update
            local statusMsg = "Done! Saved " .. savedFiles .. "/" .. #foundNPCs .. " NPC(s)"
            
            if sendWebhook and #webhookResults > 0 then
                local successfulWebhooks = 0
                for _, result in ipairs(webhookResults) do
                    if result.success then
                        successfulWebhooks = successfulWebhooks + 1
                    end
                end
                statusMsg = statusMsg .. " | Webhooks: " .. successfulWebhooks .. "/" .. #webhookResults .. " sent"
            end
            
            StatusParagraph:Set({Title = "Status", Content = statusMsg})
            
            -- Show final notification
            if savedFiles > 0 then
                Rayfield:Notify({
                    Title = "Export Complete",
                    Content = "Saved " .. savedFiles .. " NPC(s) to NightboundExports/SavedNPCs",
                    Duration = 8
                })
            end
        end)
    end,
})

-- Add a test webhook button for debugging
local DebugButton = MainTab:CreateButton({
    Name = "Test Webhook (Debug)",
    Callback = function()
        StatusParagraph:Set({Title = "Status", Content = "Testing webhook..."})
        
        -- Create a test file
        local testDir = "NightboundExports"
        if not isfolder(testDir) then makefolder(testDir) end
        
        local testFilePath = testDir .. "/test_file.txt"
        writefile(testFilePath, "This is a test file created at " .. os.date() .. "\nNightbound Saver Webhook Test")
        
        StatusParagraph:Set({Title = "Status", Content = "Sending test webhook..."})
        
        local success = sendStyledWebhook(testFilePath)
        if success then
            StatusParagraph:Set({Title = "Status", Content = "Test webhook sent successfully!"})
            Rayfield:Notify({
                Title = "Webhook Test",
                Content = "Test webhook sent successfully!",
                Duration = 5
            })
        else
            StatusParagraph:Set({Title = "Status", Content = "Test webhook failed. Check console."})
            Rayfield:Notify({
                Title = "Webhook Test Failed",
                Content = "Check console for error details",
                Duration = 5
            })
        end
        
        -- Clean up test file
        pcall(delfile, testFilePath)
    end,
})

StatusParagraph:Set({Title = "Status", Content = "Ready - Select and Start Saving"})
