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

        local Movement = Tab("Character")("Movement", "Left")

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
                                debug.setupvalue(senv.block_main, 4, 50)
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

        local Other = Tab("Character")("Other", "Right")

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

        -- # Settings
    end
    
    local old
    old = hookmetamethod(game, "__namecall", function(...)
        if getnamecallmethod() == "TakeDamage" then
            if Library.flags.NoFall then
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
                    for i=1,ui.flags.Multiplier2 do
                        __Invoke(...)
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
