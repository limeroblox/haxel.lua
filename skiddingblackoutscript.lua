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

local function sendStyledWebhook(filePath, customEmbed)
    -- First check if file exists
    if not isfile(filePath) then
        warn("[Webhook] File does not exist:", filePath)
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
    local fileSizeKB = string.format("%.2f KB", #fileData / 1024)
    print("[Webhook] Attempting to send file:", fileName, "Size:", #fileData, "bytes")
    
    -- Create boundary for multipart form data
    local boundary = "----WebKitFormBoundary" .. tostring(math.random(100000, 999999))
    
    -- Create the multipart form data body
    local body = ""
    
    -- Add JSON payload part
    local payload = {
        username = "Haxel's Cool Webhook",
        embeds = customEmbed or {{
            title = "RBXM Saved",
            description = "**Export Completed**",
            color = 0x2B2D31,
            fields = {
                { name = "File", value = "`" .. fileName .. "`", inline = true },
                { name = "Size", value = fileSizeKB, inline = true },
                { name = "Type", value = filePath:match("%.(.+)$") or "Unknown", inline = true }
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

-- Create tabs
local MainTab = Window:CreateTab("Main", 4483362458) -- Home icon
local TestTab = Window:CreateTab("Testing", 4483362458) -- Home icon for testing
local MethodsTab = Window:CreateTab("Save Methods", 4483362458) -- Home icon for methods
local WebhookTab = Window:CreateTab("Webhook Config", 4483362458) -- Settings icon

-- Status paragraph for Main tab
local StatusParagraph = MainTab:CreateParagraph({
    Title = "Status",
    Content = "Initializing..."
})

-- Dropdown for Main tab
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

--// BUTTONS FOR MAIN TAB
local SendWebhookToggle = MainTab:CreateToggle({
    Name = "Send to webhook when saved?",
    CurrentValue = false,
    Flag = "SendWebhook",
    Callback = function(value) end
})

local SaveButton = MainTab:CreateButton({
    Name = "Start Saving (Main Method)",
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
            local baseExportDir = "NightboundExports/MainMethod"
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
                
                print("[Main Method] Attempting to save:", baseName, "to", rbxmPath)
                
                -- First delete old file if it exists
                if isfile(rbxmPath) then
                    pcall(delfile, rbxmPath)
                end

                local ok, err = pcall(function()
                    StatusParagraph:Set({Title = "Status", Content = "Saving " .. baseName .. "..."})
                    
                    -- Clone the NPC and ensure it's archivable
                    local npcClone = npc:Clone()
                    
                    -- Make everything in the clone archivable
                    for _, descendant in pairs(npcClone:GetDescendants()) do
                        pcall(function()
                            descendant.Archivable = true
                        end)
                    end
                    
                    npcClone.Archivable = true
                    
                    -- Try to save with different syntaxes
                    local saveSuccess = false
                    local originalThread
                    
                    if setthreadidentity then
                        originalThread = getthreadidentity and getthreadidentity() or 2
                        setthreadidentity(7)
                    end
                    
                    -- Attempt 1: Standard saveinstance
                    local ok1, err1 = pcall(function()
                        saveinstance_func(rbxmPath)
                    end)
                    
                    if ok1 then
                        saveSuccess = true
                        print("[Main Method] Save successful with standard syntax")
                    else
                        warn("[Main Method] Standard syntax failed:", err1)
                        
                        -- Attempt 2: With object parameter
                        local ok2, err2 = pcall(function()
                            saveinstance_func(npcClone, rbxmPath)
                        end)
                        
                        if ok2 then
                            saveSuccess = true
                            print("[Main Method] Save successful with object parameter")
                        else
                            warn("[Main Method] Object parameter failed:", err2)
                            
                            -- Attempt 3: Table format
                            local ok3, err3 = pcall(function()
                                saveinstance_func({Objects = {npcClone}, FileName = rbxmPath})
                            end)
                            
                            if ok3 then
                                saveSuccess = true
                                print("[Main Method] Save successful with table format")
                            else
                                warn("[Main Method] Table format failed:", err3)
                            end
                        end
                    end
                    
                    if setthreadidentity and originalThread then
                        setthreadidentity(originalThread)
                    end
                    
                    -- Clean up the clone
                    npcClone:Destroy()
                    
                    if saveSuccess then
                        -- Wait for file to be written
                        for waitAttempt = 1, 5 do
                            task.wait(1)
                            if isfile(rbxmPath) then
                                local fileSize
                                pcall(function()
                                    fileSize = #readfile(rbxmPath)
                                end)
                                
                                if fileSize and fileSize > 100 then
                                    savedFiles = savedFiles + 1
                                    print("[Main Method] ✓ Successfully saved:", rbxmPath, "Size:", fileSize, "bytes")
                                    
                                    -- Send webhook if enabled
                                    if sendWebhook then
                                        StatusParagraph:Set({Title = "Status", Content = "Sending webhook for " .. baseName .. "..."})
                                        task.wait(1)
                                        
                                        local webhookSuccess = sendStyledWebhook(rbxmPath)
                                        table.insert(webhookResults, {
                                            name = baseName,
                                            success = webhookSuccess
                                        })
                                    end
                                    break
                                end
                            end
                            
                            if waitAttempt == 5 then
                                warn("[Main Method] File not created or empty after 5 seconds:", rbxmPath)
                            end
                        end
                    else
                        warn("[Main Method] All save attempts failed for:", baseName)
                    end
                end)

                if not ok then
                    warn("[Main Method] Error exporting " .. baseName .. ":", err)
                    StatusParagraph:Set({Title = "Status", Content = "Error exporting " .. baseName})
                elseif savedFiles > 0 then
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
                    Content = "Saved " .. savedFiles .. " NPC(s) to NightboundExports/MainMethod",
                    Duration = 8
                })
            end
        end)
    end,
})

--// TESTING TAB CONTENT
local TestStatus = TestTab:CreateParagraph({
    Title = "Testing Status",
    Content = "Ready for testing..."
})

-- Test NPC Finder
TestTab:CreateButton({
    Name = "Test NPC Finder",
    Callback = function()
        TestStatus:Set({Title = "Testing", Content = "Looking for NPCs..."})
        
        task.spawn(function()
            local npcCount = 0
            local npcList = {}
            
            local allNPCs = workspace:FindFirstChild("NPCs")
            if allNPCs then
                for _, folder in {allNPCs:FindFirstChild("Hostile"), allNPCs:FindFirstChild("Custom")} do
                    if folder then
                        for _, obj in folder:GetChildren() do
                            if obj:IsA("Model") then
                                npcCount = npcCount + 1
                                table.insert(npcList, obj.Name)
                            end
                        end
                    end
                end
            end
            
            TestStatus:Set({
                Title = "NPC Finder Test",
                Content = "Found " .. npcCount .. " NPCs\nFirst 5: " .. table.concat(table.move(npcList, 1, math.min(5, #npcList), 1, {}), ", ")
            })
            
            Rayfield:Notify({
                Title = "NPC Finder Test",
                Content = "Found " .. npcCount .. " NPCs in total",
                Duration = 5
            })
        end)
    end,
})

-- Test File System
TestTab:CreateButton({
    Name = "Test File System",
    Callback = function()
        TestStatus:Set({Title = "Testing", Content = "Testing file system access..."})
        
        local testDir = "NightboundTest"
        local testFile = testDir .. "/test.txt"
        local testContent = "File system test at " .. os.date()
        
        -- Test folder creation
        if not isfolder(testDir) then
            makefolder(testDir)
            print("[Test] Created folder:", testDir)
        end
        
        -- Test file writing
        local writeSuccess, writeErr = pcall(writefile, testFile, testContent)
        
        -- Test file reading
        local readSuccess, readData = false, ""
        if writeSuccess then
            readSuccess, readData = pcall(readfile, testFile)
        end
        
        -- Test file deletion
        local deleteSuccess = false
        if readSuccess then
            deleteSuccess = pcall(delfile, testFile)
        end
        
        TestStatus:Set({
            Title = "File System Test",
            Content = string.format("Write: %s | Read: %s | Delete: %s\nContent: %s", 
                writeSuccess and "✓" or "✗", 
                readSuccess and "✓" or "✗", 
                deleteSuccess and "✓" or "✗",
                string.sub(readData or "N/A", 1, 50)
            )
        })
        
        Rayfield:Notify({
            Title = "File System Test",
            Content = string.format("Write: %s | Read: %s | Delete: %s", 
                writeSuccess and "Success" or "Failed", 
                readSuccess and "Success" or "Failed", 
                deleteSuccess and "Success" or "Failed"
            ),
            Duration = 5
        })
    end,
})

-- Test Saveinstance Function
TestTab:CreateButton({
    Name = "Test Saveinstance",
    Callback = function()
        TestStatus:Set({Title = "Testing", Content = "Testing saveinstance function..."})
        
        task.spawn(function()
            local testObj = Instance.new("Part")
            testObj.Name = "TestPart_Saveinstance"
            testObj.Parent = workspace
            testObj.Position = Vector3.new(0, 100, 0) -- Put it high up
            
            local testDir = "NightboundTest"
            if not isfolder(testDir) then
                makefolder(testDir)
            end
            
            local testPath = testDir .. "/test_saveinstance.rbxm"
            
            if isfile(testPath) then
                pcall(delfile, testPath)
            end
            
            local success, err = pcall(function()
                if setthreadidentity then
                    setthreadidentity(7)
                end
                
                testObj.Archivable = true
                
                -- Try different syntaxes
                local attempts = {
                    {name = "Standard", func = function() saveinstance_func(testPath) end},
                    {name = "With Object", func = function() saveinstance_func(testObj, testPath) end},
                    {name = "Table Format", func = function() saveinstance_func({Objects = {testObj}, FileName = testPath}) end}
                }
                
                local results = {}
                for i, attempt in ipairs(attempts) do
                    local ok, attemptErr = pcall(attempt.func)
                    table.insert(results, string.format("%s: %s", attempt.name, ok and "✓" or "✗"))
                    if ok then
                        break
                    end
                end
                
                if setthreadidentity then
                    setthreadidentity(2)
                end
                
                return table.concat(results, " | ")
            end)
            
            -- Clean up
            testObj:Destroy()
            
            local fileExists = isfile(testPath)
            local fileSize = 0
            if fileExists then
                pcall(function()
                    fileSize = #readfile(testPath)
                end)
            end
            
            TestStatus:Set({
                Title = "Saveinstance Test",
                Content = string.format("Success: %s\nFile exists: %s | Size: %d bytes\nAttempts: %s",
                    success and "✓" or "✗",
                    fileExists and "✓" or "✗",
                    fileSize,
                    success and err or "All failed"
                )
            })
            
            Rayfield:Notify({
                Title = "Saveinstance Test",
                Content = string.format("Success: %s | File: %s | Size: %d bytes",
                    success and "Yes" or "No",
                    fileExists and "Created" or "Missing",
                    fileSize
                ),
                Duration = 5
            })
        end)
    end,
})

--// SAVE METHODS TAB
local MethodsStatus = MethodsTab:CreateParagraph({
    Title = "Methods Status",
    Content = "Select a save method..."
})

-- Method 1: Clone and Serialize
MethodsTab:CreateButton({
    Name = "Method 1: Clone & Serialize",
    Callback = function()
        local selected = Dropdown.CurrentOption[1]
        MethodsStatus:Set({Title = "Method 1", Content = "Cloning " .. selected .. "..."})
        
        task.spawn(function()
            local npc = nil
            pcall(function()
                local allNPCs = workspace:FindFirstChild("NPCs")
                if allNPCs then
                    for _, folder in {allNPCs:FindFirstChild("Hostile"), allNPCs:FindFirstChild("Custom")} do
                        if folder then
                            npc = folder:FindFirstChild(selected)
                            if npc then break end
                        end
                    end
                end
            end)
            
            if not npc then
                MethodsStatus:Set({Title = "Method 1", Content = selected .. " not found"})
                return
            end
            
            -- Create directory
            local methodDir = "NightboundExports/Method1"
            if not isfolder("NightboundExports") then makefolder("NightboundExports") end
            if not isfolder(methodDir) then makefolder(methodDir) end
            
            local baseName = selected:gsub(" ", "") .. "_clone"
            local outputPath = methodDir .. "/" .. baseName .. ".txt"
            
            -- Clone and analyze
            local npcClone = npc:Clone()
            local analysis = {
                Name = npcClone.Name,
                ClassName = npcClone.ClassName,
                ChildrenCount = #npcClone:GetChildren(),
                DescendantsCount = #npcClone:GetDescendants(),
                Archivable = npcClone.Archivable,
                PrimaryPart = npcClone.PrimaryPart and true or false,
                Scripts = 0,
                Parts = 0,
                Meshes = 0,
                Time = os.date()
            }
            
            -- Count object types
            for _, descendant in pairs(npcClone:GetDescendants()) do
                if descendant:IsA("BaseScript") then
                    analysis.Scripts = analysis.Scripts + 1
                elseif descendant:IsA("BasePart") then
                    analysis.Parts = analysis.Parts + 1
                elseif descendant:IsA("MeshPart") or descendant:IsA("SpecialMesh") then
                    analysis.Meshes = analysis.Meshes + 1
                end
            end
            
            -- Generate report
            local report = "=== NPC Clone Analysis ===\n"
            for key, value in pairs(analysis) do
                report = report .. key .. ": " .. tostring(value) .. "\n"
            end
            
            report = report .. "\n=== Top Level Children ===\n"
            for _, child in pairs(npcClone:GetChildren()) do
                report = report .. "- " .. child.Name .. " (" .. child.ClassName .. ")\n"
            end
            
            writefile(outputPath, report)
            npcClone:Destroy()
            
            MethodsStatus:Set({Title = "Method 1", Content = "Clone analysis saved!"})
            
            -- Send webhook if enabled
            if SendWebhookToggle.CurrentValue then
                task.wait(1)
                sendStyledWebhook(outputPath, {{
                    title = "Method 1: Clone Analysis",
                    description = "**NPC clone analysis completed**",
                    color = 0x00FF00,
                    fields = {
                        { name = "NPC", value = "`" .. selected .. "`", inline = true },
                        { name = "Scripts", value = tostring(analysis.Scripts), inline = true },
                        { name = "Parts", value = tostring(analysis.Parts), inline = true }
                    },
                    footer = { text = "Clone Method" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }})
            end
            
            Rayfield:Notify({
                Title = "Method 1 Complete",
                Content = "Clone analysis saved to " .. outputPath,
                Duration = 5
            })
        end)
    end,
})

-- Method 2: Property Dumper
MethodsTab:CreateButton({
    Name = "Method 2: Property Dumper",
    Callback = function()
        local selected = Dropdown.CurrentOption[1]
        MethodsStatus:Set({Title = "Method 2", Content = "Dumping properties of " .. selected .. "..."})
        
        task.spawn(function()
            local npc = nil
            pcall(function()
                local allNPCs = workspace:FindFirstChild("NPCs")
                if allNPCs then
                    for _, folder in {allNPCs:FindFirstChild("Hostile"), allNPCs:FindFirstChild("Custom")} do
                        if folder then
                            npc = folder:FindFirstChild(selected)
                            if npc then break end
                        end
                    end
                end
            end)
            
            if not npc then
                MethodsStatus:Set({Title = "Method 2", Content = selected .. " not found"})
                return
            end
            
            -- Create directory
            local methodDir = "NightboundExports/Method2"
            if not isfolder("NightboundExports") then makefolder("NightboundExports") end
            if not isfolder(methodDir) then makefolder(methodDir) end
            
            local baseName = selected:gsub(" ", "") .. "_properties"
            local outputPath = methodDir .. "/" .. baseName .. ".txt"
            
            local function getProperties(obj, depth)
                depth = depth or 0
                local indent = string.rep("  ", depth)
                local result = indent .. obj.Name .. " (" .. obj.ClassName .. ")\n"
                
                -- Get properties (safely)
                local success, properties = pcall(function()
                    local props = {}
                    for _, prop in pairs(getproperties(obj)) do
                        local ok, value = pcall(function() return obj[prop] end)
                        if ok then
                            props[prop] = value
                        end
                    end
                    return props
                end)
                
                if success then
                    for prop, value in pairs(properties) do
                        result = result .. indent .. "  " .. prop .. ": " .. tostring(value) .. "\n"
                    end
                end
                
                -- Recursively get children properties
                for _, child in pairs(obj:GetChildren()) do
                    result = result .. getProperties(child, depth + 1)
                end
                
                return result
            end
            
            local propertyDump = "=== Property Dump for " .. selected .. " ===\n"
            propertyDump = propertyDump .. "Generated: " .. os.date() .. "\n\n"
            propertyDump = propertyDump .. getProperties(npc)
            
            writefile(outputPath, propertyDump)
            
            MethodsStatus:Set({Title = "Method 2", Content = "Property dump saved!"})
            
            -- Send webhook if enabled
            if SendWebhookToggle.CurrentValue then
                task.wait(1)
                sendStyledWebhook(outputPath, {{
                    title = "Method 2: Property Dump",
                    description = "**NPC property dump completed**",
                    color = 0xFFA500,
                    fields = {
                        { name = "NPC", value = "`" .. selected .. "`", inline = true },
                        { name = "Class", value = npc.ClassName, inline = true },
                        { name = "Children", value = tostring(#npc:GetChildren()), inline = true }
                    },
                    footer = { text = "Property Dumper" },
                    timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
                }})
            end
            
            Rayfield:Notify({
                Title = "Method 2 Complete",
                Content = "Property dump saved to " .. outputPath,
                Duration = 5
            })
        end)
    end,
})

--// WEBHOOK CONFIG TAB
local WebhookStatus = WebhookTab:CreateParagraph({
    Title = "Webhook Status",
    Content = "Webhook functionality ready..."
})

-- Webhook URL input
local WebhookUrlInput = WebhookTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Enter webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        if Text ~= "" then
            WEBHOOK_URL = Text
            WebhookStatus:Set({Title = "Webhook", Content = "URL updated: " .. string.sub(Text, 1, 50) .. "..."})
        end
    end,
})

-- Test current webhook
WebhookTab:CreateButton({
    Name = "Test Current Webhook",
    Callback = function()
        WebhookStatus:Set({Title = "Testing", Content = "Testing webhook..."})
        
        -- Create a test file
        local testDir = "NightboundExports"
        if not isfolder(testDir) then makefolder(testDir) end
        
        local testFilePath = testDir .. "/webhook_test.txt"
        local testContent = "Webhook Test File\n"
        testContent = testContent .. "Generated at: " .. os.date() .. "\n"
        testContent = testContent .. "Webhook URL: " .. string.sub(WEBHOOK_URL, 1, 50) .. "...\n"
        testContent = testContent .. "Executor: " .. tostring(identifyexecutor and identifyexecutor() or "Unknown") .. "\n"
        
        writefile(testFilePath, testContent)
        
        local success = sendStyledWebhook(testFilePath, {{
            title = "Webhook Test",
            description = "**Testing webhook configuration**",
            color = 0x3498DB,
            fields = {
                { name = "Test Type", value = "Configuration Test", inline = true },
                { name = "Time", value = os.date("%H:%M:%S"), inline = true },
                { name = "Status", value = "Testing...", inline = true }
            },
            footer = { text = "Webhook Config Test" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }})
        
        if success then
            WebhookStatus:Set({Title = "Webhook Test", Content = "✓ Webhook sent successfully!"})
            Rayfield:Notify({
                Title = "Webhook Test",
                Content = "Webhook sent successfully!",
                Duration = 5
            })
        else
            WebhookStatus:Set({Title = "Webhook Test", Content = "✗ Webhook failed. Check console."})
            Rayfield:Notify({
                Title = "Webhook Test Failed",
                Content = "Check console for error details",
                Duration = 5
            })
        end
        
        -- Clean up
        pcall(delfile, testFilePath)
    end,
})

-- Webhook embed preview
WebhookTab:CreateButton({
    Name = "Preview Webhook Embed",
    Callback = function()
        WebhookStatus:Set({Title = "Preview", Content = "Generating embed preview..."})
        
        local previewEmbed = {
            title = "Embed Preview",
            description = "**This is how your webhook will look**",
            color = 0x2B2D31,
            fields = {
                { name = "Field 1", value = "Value 1", inline = true },
                { name = "Field 2", value = "Value 2", inline = true },
                { name = "Field 3", value = "Value 3", inline = true }
            },
            thumbnail = { url = "https://static.wikitide.net/blackoutwiki/5/54/Flare.png" },
            footer = { text = "Preview" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
        
        WebhookStatus:Set({
            Title = "Embed Preview",
            Content = "Title: " .. previewEmbed.title .. "\n" ..
                     "Description: " .. previewEmbed.description .. "\n" ..
                     "Color: #" .. string.format("%06X", previewEmbed.color) .. "\n" ..
                     "Fields: " .. tostring(#previewEmbed.fields) .. "\n" ..
                     "Footer: " .. previewEmbed.footer.text
        })
        
        Rayfield:Notify({
            Title = "Embed Preview",
            Content = "Check status box for embed details",
            Duration = 5
        })
    end,
})

-- Status for all tabs
StatusParagraph:Set({Title = "Status", Content = "Ready - Select and Start Saving"})
TestStatus:Set({Title = "Testing", Content = "Use buttons to test different functions"})
MethodsStatus:Set({Title = "Methods", Content = "Select a save method to try"})
WebhookStatus:Set({Title = "Webhook", Content = "Configure and test webhook functionality"})
