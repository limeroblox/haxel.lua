--// Nightbound Saver using Rayfield Interface Suite (RBXM mode)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Nightbound Saver",
    LoadingTitle = "Nightbound Saver",
    LoadingSubtitle = "by Grok",
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
        "Nightbound Voidshackle",
        "Nightbound Shademirror",
        "Nightbound Dreadcoil",
        "Nightbound Wraith" -- added for testing
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
                writefile(dumpPath .. ".bytecode.lz4.base64", base64_encode(lz4compress(bytecode)))
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
local SaveButton = MainTab:CreateButton({
    Name = "Start Saving",
    Callback = function()
        local selected = Dropdown.CurrentOption[1]
        StatusParagraph:Set({Title = "Status", Content = "Searching for " .. selected .. "..."})

        task.spawn(function()
            while true do
                local npc = findNPC(selected)
                if npc then
                    local baseName = selected:gsub(" ", "")
                    exportFull(npc, baseName)
                    Rayfield:Notify({Title = "Success", Content = "Saved " .. selected .. " as RBXM successfully!", Duration = 5})
                    StatusParagraph:Set({Title = "Status", Content = "Ready - Select and Start Saving"})
                    return
                else
                    StatusParagraph:Set({Title = "Status", Content = selected .. " not found, retrying in " .. CHECK_DELAY .. "s..."})
                    task.wait(CHECK_DELAY)
                end
            end
        end)
    end,
})

StatusParagraph:Set({Title = "Status", Content = "Ready - Select and Start Saving"})
