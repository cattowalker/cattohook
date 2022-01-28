assert(Drawing, "drawing is nil, exploit is not supported.")
assert(hookfunc, "hookfunc is nil, exploit is not supported.")
assert(loadstring, "loadstring is nil, exploit is not supported.")

local function loadlib(file)
    if getgenv()[file] ~= nil then
        return getgenv()[file]
    end
    
    getgenv()[file] = loadstring(game.HttpGet(game, string.format("https://raw.githubusercontent.com/cattowalker/cattohook/master/lib/%s.lua", string.lower(file))))()
    return getgenv()[file]
end

local quick = loadlib("quick")
local broom = loadlib("broom")
local synLog = loadlib("synlog")
local esp = loadlib("esp")
local ui = loadlib("ui")

synLog:info("loaded", synlog.chalk("environment").InfoBlue)

-- # Main Code

if game then
    if(not game:IsLoaded()) then
        game.Loaded:Wait()
    end
    
    local Players = quick.Service["Players"]
    local RunService = quick.Service["RunService"]
    local ReplicatedStorage = quick.Service["ReplicatedStorage"]
    local Client = quick["User"]
    local Assets = ReplicatedStorage:WaitForChild("Assets")
    local Network = Assets.Modules:WaitForChild("NetworkClass")
    Network = require(Network)
    
    assert(debug, "debug is nil, exploit is not supported.")
    assert(getgc, "getgc is nil, exploit is not supported.")
    assert(hookmetamethod, "hookmetamethod is nil, exploit is not supported.")
    assert(getsenv, "getsenv is nil, exploit is not supported.")
    assert(getgenv, "getgenv is nil, exploit is not supported.")

    -- # GetClosest

    local function getClosestTool(distance)
        if not Client or not Client["Character"] then return end
    
        local Path = workspace:WaitForChild("Terrain"):WaitForChild("Ignore").Tools
        
        for i,v in pairs(Path:GetChildren()) do
            if v:IsA("Model") and v.PrimaryPart then
                local magnitude = (v.PrimaryPart.Position-Client.Character.HumanoidRootPart.Position).Magnitude
                if magnitude <= distance then
                    return v
                end
            end
        end
        
        return nil
    end
    
    local function getClosestDoor(distance)
        if not Client or not Client["Character"] then return end
    
        local Path = game:GetService("Workspace").Doors
        
        for i,v in pairs(Path:GetChildren()) do
            if v:IsA("Model") and v.PrimaryPart then
                local magnitude = (v.PrimaryPart.Position-Client.Character.HumanoidRootPart.Position).Magnitude
                if magnitude <= distance then
                    return v
                end
            end
        end
        
        return nil
    end
    
    local function getClosestItem(distance)
        if not Client or not Client["Character"] then return end
    
        local Path = game:GetService("Workspace").Terrain.Ignore.Items
        
        for i,v in pairs(Path:GetChildren()) do
            if v:IsA("Model") and v.PrimaryPart then
                local magnitude = (v.PrimaryPart.Position-Client.Character.HumanoidRootPart.Position).Magnitude
                if magnitude <= distance then
                    return v
                end
            elseif v:IsA("MeshPart") or v:IsA("Part") then
                local magnitude = (v.Position-Client.Character.HumanoidRootPart.Position).Magnitude
                if magnitude <= distance then
                    return v
                end
            end
        end
        
        return nil
    end
    
    local function getClosestCharacter(distance)
        if not Client or not Client["Character"] then return end
        
        primaryPart = Client["Character"].PrimaryPart
        maxDistance = distance or math.huge
    
        for i,v in pairs(Players:GetPlayers()) do
            if v ~= Client and v.Character then
                if v.Character.PrimaryPart then
                    local magnitude = ((v.Character.PrimaryPart.Position)-(primaryPart.Position)).Magnitude
                    if magnitude <= maxDistance then
                        return v.Character
                    end
                end
            end
        end
        
        return nil
    end

    -- # UI
    
    if Client and ui then
        quick.merge(ui.theme, {
            accentcolor = Color3.fromRGB(174, 71, 214);
            accentcolor2 = Color3.fromRGB(133, 54, 163);
            topcolor2 = Color3.fromRGB(35, 35, 35);
        })
        
        local Window = ui:CreateWindow("cattohook", Vector3.new(492, 598), Enum.KeyCode.RightShift)

        -- # Tabs
        
        local Tabs = {}
        local Tab = setmetatable({}, {
            __call = function(self, t)
                if rawget(Tabs, t) then
                    return rawget(Tabs, t)
                end
                
                Tabs[t] = Window:CreateTab(t)
                local CreateSector = Tabs[t].CreateSector
                
                Tabs[t] = setmetatable({}, {
                    __call = function(self, ...)
                        return quick.call(CreateSector, self, ...)
                    end
                })
                
                return Tabs[t]
            end
        })

        -- # Melee Modification
        
        local Combat = Tab("Combat")("Melee Modification", "Left")

        Combat:AddToggle("Enabled", false, nil, "Enabled")
        Combat:AddToggle("Damage Multiplier", false, nil, "Multiplier"):AddSlider(1, 15, 100, 1, nil, "Multiplier2")
        Combat:AddToggle("Always Special", false, nil, "DamageMultiplier")
        Combat:AddToggle("Change Delay", false, nil, "ChangeDelay"):AddSlider(0, .3, 10, 10, nil, "Delay")
        Combat:AddToggle("Change Charge Time", false, nil, "ChangeCharge"):AddSlider(0, .3, 10, 10, nil, "ChargeTime")

        -- # Movement

        local Movement = Tab("Player")("Movement", "Left")

        Movement:AddToggle("Infinite Stamina", false, function(t)
            synLog:info("Infinite-Stamina is now", t==true and "on." or "off.")
            if(t) then
                while task.wait() do
                    if not ui.flags["Infinite-Stamina"] then
                        break
                    end
                    
                    if not Client.Character or not Client.Character.Parent then
                        Client.CharacterAppearanceLoaded:Wait()
                    elseif Client.Character and Client.Character.Parent then
                        local Essentials = Client.Character:WaitForChild("Essentials")
                        local ClientController = Essentials:WaitForChild("ClientController")
                        
                        if Essentials and ClientController and getsenv(ClientController).block_main then
                            local senv = getsenv(ClientController)
                            if debug.getupvalue(senv.block_main, 4) then
                                debug.setupvalue(senv.block_main, 4, math.random(35, 50))
                            end
                        end
                    end
                end
            end
        end, "Infinite-Stamina")
        
        Movement:AddToggle("No Jump Cooldown", false, function(t)
            synLog:info("No Jump Cooldown is now", t==true and "on." or "off.")
            if(t) then
                while task.wait() do
                    if not ui.flags["No-Jump-Cooldown"] then
                        break
                    end

                    if Client.Character and Client.Character:FindFirstChildOfClass("Humanoid") then
                        local Humanoid = Client.Character:FindFirstChildOfClass("Humanoid")

                        Humanoid["JumpPower"] = 50
                    else
                        Client.CharacterAppearanceLoaded:Wait()
                    end
                end
            end
        end, "No-Jump-Cooldown")
        
        Movement:AddToggle("No Dash Cooldown", false, function(t)
            synLog:info("No Dash Cooldown is now", t==true and "on." or "off.")
            if(t) then
                while task.wait() do
                    if not ui.flags["No-Dash-Cooldown"] then 
                        break
                    end

                    if not Client.Character or not Client.Character.Parent then
                        Client.CharacterAppearanceLoaded:Wait()
                    elseif Client.Character and Client.Character.Parent then
                        local Essentials = Client.Character:WaitForChild("Essentials")
                        local ClientController = Essentials:WaitForChild("ClientController")
                        
                        if Essentials and ClientController and getsenv(ClientController).block_main then
                            local senv = getsenv(ClientController)
                            if debug.getupvalue(senv.dash_main, 1) then
                                debug.setupvalue(senv.dash_main, 1, 0)
                            end
                        end
                    end
                end
            end
        end, "No-Dash-Cooldown")
        
        Movement:AddToggle("Always Run", false, function(t)
            synLog:info("Always Run is now", t==true and "on." or "off.")
            if(t and ChangeWalkSpeed and WalkSpeed) then
                task.spawn(WalkSpeed.Set, WalkSpeed, 26.9)
                task.spawn(ChangeWalkSpeed.Set, ChangeWalkSpeed, true)
            else
                ChangeWalkSpeed:Set(false)
            end
        end, "Always-Run")
        
        Movement:AddToggle("No Slowdowns", false, function(t)
            synLog:info("No Slowdowns is now", t==true and "on." or "off.")
            if(t) then
                while task.wait() do
                    if not ui.flags["No-Slowdown"] then
                        break
                    end

                    if not Client.Character or not Client.Character.Parent then
                        Client.CharacterAppearanceLoaded:Wait()
                    elseif Client.Character and Client.Character.Parent then
                        local Humanoid = Client.Character:WaitForChild("Humanoid")
                        
                        if Humanoid["WalkSpeed"] < 15 then
                            Humanoid["WalkSpeed"] = 16
                        end
                    end
                end
            end
        end, "No-Slowdown")
        
        ChangeWalkSpeed = Movement:AddToggle("Change WalkSpeed", false, function(t)
            synLog:info("Change Walkspeed is now", t==true and "on." or "off.")
            if(t) then
                while task.wait() do
                    if not ui.flags["Change-WalkSpeed"] then
                        break
                    end

                    if not Client.Character or not Client.Character.Parent then
                        Client.CharacterAppearanceLoaded:Wait()
                    elseif Client.Character and Client.Character.Parent then
                        local Humanoid = Client.Character:WaitForChild("Humanoid")

                        Humanoid["WalkSpeed"] = ui.flags["WalkSpeed"]
                    else
                        Client.CharacterAppearanceLoaded:Wait()
                    end
                end
            end
        end, "Change-WalkSpeed")
        WalkSpeed = ChangeWalkSpeed:AddSlider(16, 16, 35, 10, nil, "WalkSpeed")

        -- # Other

        local Other = Tab("Player")("Other", "Right")

        Other:AddToggle("No Fall Damage", false, nil, "NoFall")
        
        Other:AddToggle("No Sounds", false, function(t)
            synLog:info("No Sounds is now", t==true and "on." or "off.")
            if(t) then
                sounds = broom()
                local function removeSound()
                    local Character = Client.Character
                    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
                    local Humanoid = Character:WaitForChild("Humanoid")

                    quick.each(HumanoidRootPart:GetChildren(), function(v)
                        if v:IsA("Sound") then
                            wait()
                            v:Destroy()
                        end
                    end)

                    sounds:connect(HumanoidRootPart.ChildAdded, function(v)
                        if v:IsA("Sound") then
                            wait()
                            v:Destroy()
                        end
                    end)
                    
                    Humanoid.Died:Connect(function()
                        sounds:clean()
                    end)
                end

                if Client.Character then
                    removeSound(Client.Character)
                end

                sounds:connect(Client.Character.CharacterAppearanceLoaded, removeSound)
            elseif not(t) then
                if sounds then
                    sounds:clean()
                end
            end
        end)

        Other:AddToggle("Break Joints On Death", false, function(t)
            synLog:info("Break Joints On Death is now", t==true and "on." or "off.")
            if(t) then
                joints = broom()
                local function connect()
                    local Character = Client.Character
                    local Humanoid = Character:WaitForChild("Humanoid")

                    Humanoid.Died:Connect(function()
                        quick.each(Character:GetChildren(), function(v)
                            wait()
                            if v:IsA("Folder") and tostring(v) == "Collisions" or tostring(v) == "Constraints" then
                                v:Destroy()
                            end
                        end)

                        joints:clean()
                    end)
                end

                if Client.Character then
                    connect()
                end

                sounds:connect(Client.Character.CharacterAppearanceLoaded, connect)
            elseif not(t) then
                if sounds then
                    sounds:clean()
                end
            end
        end)
        
        Other:AddToggle("No Name-Tag", false, function(t)
            synLog:info("No Name-Tag is now", t==true and "on." or "off.")
            if(t) then
                nametag = broom()
                local function connect()
                    local Character = Client.Character
                    
                    if Character.Head:FindFirstChildOfClass("BillboardGui") then
                        Character.Head:FindFirstChildOfClass("BillboardGui"):Destroy()
                    end
                    
                    Humanoid.Died:Connect(function()
                        nametag:clean()
                    end)
                end

                if Client.Character then
                    connect()
                end

                nametag:connect(Client.Character.CharacterAppearanceLoaded, connect)
            elseif not(t) then
                if nametag then
                    nametag:clean()
                end
            end
        end)

        Other:AddButton("Disseapear", function(...)
            pcall(Network.FireServer, Network, "load")
        end)

        -- # AutoFarm

        local AutoFarm = Tab("Player")("AutoFarm", "Left")

        AutoFarm:AddToggle("Auto Pick Tools", false, function(t)
            if(t==(true))then
                ToolLoop = game.RunService.RenderStepped:Connect(function()
                    if getClosestTool(15) then
                        Network:InvokeServer("collectTool", getClosestTool(15))
                    end
                end)
            elseif(not(t)and(ToolLoop))then
                ToolLoop:Disconnect()
            end
        end, "AutoPickTools")
        
        AutoFarm:AddToggle("Auto Break Doors", false, function(t)
            if(t==(true))then
                DoorLoop = game.RunService.RenderStepped:Connect(function()
                    if getClosestDoor(15) then
                        Network:InvokeServer("break door", getClosestDoor(15))
                    end
                end)
            elseif(not(t)and(DoorLoop))then
                DoorLoop:Disconnect()
            end
        end, "AutoBreakDoor")
        
        AutoFarm:AddToggle("Auto Pick Items", false, function(t)
            if(t==(true))then
                ItemLoop = game.RunService.RenderStepped:Connect(function()
                    if getClosestItem(15) then
                        Network:InvokeServer("collectItem", getClosestItem(15))
                    end
                end)
            elseif(not(t)and(ItemLoop))then
                ItemLoop:Disconnect()
            end
        end, "AutoPickItems")

        -- # Settings
    end
    
    local old
    old = hookmetamethod(game, "__namecall", function(...)
        if getnamecallmethod() == "TakeDamage" then
            if ui.flags.NoFall then
                return wait(9e0)
            end
        end

        return old(...)
    end)

    __Invoke = Network.InvokeServer
    Network.InvokeServer = function(...)
        local args = {...}
        
        if args[2] == "hit" and ui.flags.Enabled then
            if args[4] then
                if ui.flags.Special then
                    args[4].special = true
                    args[5] = 3
                end
    
                if ui.flags.ChangeDelay then
                    args[4].delay = ui.flags.Delay
                end
    
                if ui.flags.ChangeCharge then
                    args[4].chargeTime = ui.flags.ChargeTime
                end
    
                if ui.flags.Multiplier then
                    for i=1,ui.flags.Multiplier2 or 15 and Client.Character do
                        local args = {...}

                        if type(args[3]) == "table" and args[3][2].Health and args[3][2].Health > 15 and args[3][2].Health ~= 0 then
                            Client.Character:FindFirstChildOfClass("Tool"):Activate()
                            Network:FireServer("Swing")
                            __Invoke(...)
                        end
                    end
                end
            end
        end
    
        return __Invoke(...)
    end
    
    __Fire = Network.FireServer
    Network.FireServer = function(...)
        local args = {...}
        
        if args[2] == "fall" then
            if ui.flags.NoFall then
                return wait(9e0)
            end
        end
    
        return __Fire(...)
    end
    
    synLog:info("loaded", synlog.chalk("cattohook").InfoBlue)
end
