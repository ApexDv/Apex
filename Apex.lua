if getgenv().ApexMvsdExecuted then
    print("you have already executed this script!")
    return
end
getgenv().ApexMvsdExecuted = true

local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local window = wind:CreateWindow({
    Title = "APEX | MVSD",
    Icon = "rbxassetid://139687752061139",
    Author = "by APEX",
    Folder = "ApexMvsdScript",
    Size = UDim2.fromOffset(650, 430),
    MinSize = Vector2.new(450, 250),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
        end,
    },
})
window:EditOpenButton({
    Title = "APEX",
    Icon = "rbxassetid://139687752061139",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("0A1128"),
        Color3.fromHex("4B0082")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})
window:Tag({
    Title = "NEW UPDATE",
    Icon = "shield-check",
    Color = Color3.fromHex("#30aaff"),
    Radius = 5,
})
local Welcome = window:Tab({
    Title = "Welcome",
    Icon = "shield-user",
    Locked = false,
})
Welcome:Paragraph({
    Title = "Welcome to APEX",
    Desc = "We hope you find this script useful, if you find any issues please report them below.",
    Color = Color3.fromHex("#1756B8"),
    Thumbnail = "rbxassetid://139687752061139",
    ThumbnailSize = 150,
    Buttons = {
        {
            Icon = "square-arrow-out-up-right",
            Title = "Copy Our Discord",
            Callback = function()
            end,
        }
    }
})
local lockedParagraph = Welcome:Paragraph({
    Title = "Unsupported Executor",
    Desc = "You are currently using an unsupported executor (Solara/Xeno). Certain features have been restricted by our automated system to ensure stability. To unlock full functionality and access all available tools, please switch to a recommended executor (Velocity/Madium)!",
    Color = "Red",
    Locked = false
})
Welcome:Paragraph({
    Title = "Changelogs and Patches",
    Desc = "You may view our latest changelogs and patches right in our discord server!",
    Color = "Green",
    Locked = false
})
Welcome:Select()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Collection = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer

getgenv().match = false
local canShoot = true
local matchEnemies = {}

task.spawn(function()
    while true do
        if Player then
            if Player:GetAttribute("Match") then
                getgenv().match = true
            else
                getgenv().match = false
            end
        end
        task.wait(0.1)
    end
end)
task.spawn(function()
    while task.wait(0.1) do
        local currentMatch = Player:GetAttribute("Match")
        local tempTable = {}
        if currentMatch then
            for _, v in ipairs(Players:GetPlayers()) do
                if v ~= Player and v:GetAttribute("Match") == currentMatch then
                    local char = v.Character
                    if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        table.insert(tempTable, v)
                    end
                end
            end
        end
        matchEnemies = tempTable
    end
end)
task.spawn(function()
    local lastGunTracked = nil
    local soundConnection = nil
    while task.wait(0.1) do
        local character = Player.Character
        local gun = nil
        local locations = { Player:FindFirstChild("Backpack") }
        if character then table.insert(locations, character) end
        for _, container in ipairs(locations) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Fire") and tool:FindFirstChild("Reload") then
                        gun = tool
                        break
                    end
                end
            end
            if gun then break end
        end
        if gun then
            if gun ~= lastGunTracked then
                lastGunTracked = gun
                if soundConnection then soundConnection:Disconnect() end
                local fireSound = gun:FindFirstChild("Fire")
                if fireSound and fireSound:IsA("Sound") then
                    soundConnection = fireSound.Played:Connect(function()
                        lastFiredTime = tick()
                    end)
                end
            end
        else
            lastGunTracked = nil
            if soundConnection then
                soundConnection:Disconnect()
                soundConnection = nil
            end
        end
    end
end)

local function getGun()
    local character = Player.Character
    local locations = { Player:FindFirstChild("Backpack") }
    if character then table.insert(locations, character) end
    for _, container in ipairs(locations) do
        if container then
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Fire") and tool:FindFirstChild("Reload") then
                    return tool
                end
            end
        end
    end
    return nil
end
local function equipGun()
    local character = Player.Character
    local backpack = Player:FindFirstChildOfClass("Backpack")
    if not character or not backpack then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if getgenv().match then
        local gun = getGun()
        if gun then
            humanoid:EquipTool(gun)
            return true
        end
    end
    return false
end
local function equipKnife()
    local character = Player.Character
    local backpack = Player:FindFirstChildOfClass("Backpack")
    if not character or not backpack then return false end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if getgenv().match then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("EquipAnimation") == "Knife_Equip" then
                humanoid:EquipTool(tool)
                return true
            end
        end
    end
    return false
end
local BulletRendererColor = Color3.fromRGB(255, 255, 255)
local function BulletRenderer(origin, targetPos)
    local function CreatePseudoPart(cf)
        local p = Instance.new("Part")
        p.Size = Vector3.new(0.1, 0.1, 0.1)
        p.Transparency = 1
        p.CanCollide = false
        p.CanQuery = false
        p.CanTouch = false
        p.Anchored = true
        p.CFrame = cf
        p.Parent = workspace
        return p
    end
    local startPart = CreatePseudoPart(CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -1))
    local endPart = CreatePseudoPart(CFrame.new(targetPos))
    local beam = Instance.new("Beam")
    beam.Texture = ""
    beam.TextureLength = 1
    beam.TextureMode = Enum.TextureMode.Stretch
    beam.TextureSpeed = 0
    beam.Color = ColorSequence.new(BulletRendererColor)
    beam.LightEmission = 1
    beam.LightInfluence = 0
    beam.Brightness = 5
    beam.Width0 = 0
    beam.Width1 = 0
    local att0 = Instance.new("Attachment", startPart)
    local att1 = Instance.new("Attachment", endPart)
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Parent = startPart
    local fadeIn = TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Width0 = 0.3, Width1 = 0.6 })
    local fadeOut = TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Width0 = 0, Width1 = 0 })
    fadeIn:Play()
    fadeIn.Completed:Connect(function() fadeOut:Play() end)
    Debris:AddItem(startPart, 0.3)
    Debris:AddItem(endPart, 0.3)
end
local function CharacterRayOrigin(char)
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    return (hrp.CFrame * CFrame.new(0, 0, hrp.Size.Z / 2)).Position
end
local function ShootGun(target)
    local myChar = Player.Character
    if not myChar then return end
    local origin = CharacterRayOrigin(myChar)
    if not origin then return end
    local hitPart = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
    local tool = getGun()
    if not tool then return end
    if hitPart then
        canShoot = false
        local targetPos = hitPart.Position
        local muzzle = tool:FindFirstChild("Muzzle", true)
        local startPos = muzzle and muzzle.WorldPosition or origin
        BulletRenderer(startPos, targetPos)
        ReplicatedStorage.Remotes.ShootGun:FireServer(origin, targetPos, hitPart, targetPos)
        local sound = tool and tool:FindFirstChild("Fire")
        if sound and sound:IsA("Sound") then sound:Play() end
        task.delay(2.5, function() canShoot = true end)
    end
end
local lastNotify = 0
local function NotSupportedFeature()
    local currentTime = tick()
    if currentTime - lastNotify >= 5 then
        lastNotify = currentTime
        wind:Notify({ Title = "Uh Oh! Executor not supported!", Content = "Sorry! Your executor isn't supported to run this feature.", Duration = 3, Icon = "rbxassetid://139687752061139" })
        wind:Notify({ Title = "Notice!", Content = "If your on PC/Laptop, try using Velocity, on Android/Ios please try using Delta!", Duration = 3, Icon = "rbxassetid://139687752061139" })
    end
end
local function FeatureActivated(boolean)
    if boolean then
        wind:Notify({ Title = "Activated Feature!!", Content = "Enjoying APEX? Join our discord server!", Duration = 3, Icon = "rbxassetid://139687752061139" })
    else
        wind:Notify({ Title = "Disabled Feature!!", Content = "Enjoying APEX? Join our discord server!", Duration = 3, Icon = "rbxassetid://139687752061139" })
    end
end

local Main = window:Tab({ Title = "Main", Icon = "house", Locked = false })
local ConfigurationSection = Main:Section({ Title = "Configuration", Opened = true })
local autounanchor = false
ConfigurationSection:Toggle({
    Title = "Auto UnAnchor Character",
    Desc = "Lets you bypass the 5 second wait before the match starts",
    Icon = "check",
    Default = false,
    Flag = "AutoAunacnchorToggle",
    Callback = function(Value)
        autounanchor = Value
        local function monitorCharacter(character)
            local rootPart = character:WaitForChild("HumanoidRootPart", 5)
            local humanoid = character:WaitForChild("Humanoid", 5)
            if not rootPart or not humanoid then return end
            local connection
            connection = RunService.Heartbeat:Connect(function()
                if not character.Parent or humanoid.Health <= 0 then connection:Disconnect(); return end
                if rootPart.Anchored and autounanchor then rootPart.Anchored = false end
            end)
        end
        if Player.Character then task.spawn(monitorCharacter, Player.Character) end
        Player.CharacterAdded:Connect(monitorCharacter)
    end
})
ConfigurationSection:Colorpicker({
    Title = "Bullet Tracer Color",
    Desc = "Changes the color of your bullet tracer",
    Flag = "BulletTracerColorPicker",
    Default = BulletRendererColor,
    Locked = false,
    Callback = function(color) BulletRendererColor = color end
})
Main:Space()

getgenv().autoshoot_enabled = false
getgenv().max_distance = 300
getgenv().autoshoot_cooldown = 2
local autoshoot_thread = nil
Main:Toggle({
    Title = "Enable Autoshoot",
    Desc = "This will automatically shoot enemies for you blatantly.",
    Icon = "check",
    Default = false,
    Flag = "EnableAutoShootToggle",
    Callback = function(Value)
        getgenv().autoshoot_enabled = Value
        FeatureActivated(Value)
        if autoshoot_thread then task.cancel(autoshoot_thread); autoshoot_thread = nil end
        if getgenv().autoshoot_enabled then
            local function has_clear_los(fromPos, toPos, myCharacter, targetCharacter)
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = { myCharacter, targetCharacter }
                params.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(fromPos, (toPos - fromPos), params)
                if result then if not result.Instance:IsDescendantOf(targetCharacter) then return false end end
                return true
            end
            autoshoot_thread = task.spawn(function()
                while getgenv().autoshoot_enabled do
                    local myChar = Player.Character
                    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local myHum = myChar and myChar:FindFirstChild("Humanoid")
                    if getgenv().match and myRoot and myHum and myHum.Health > 0 then
                        local closestTarget = nil
                        local closestDistance = getgenv().max_distance or 1000
                        for _, enemy in ipairs(matchEnemies) do
                            local char = enemy.Character
                            local hrp = char and char:FindFirstChild("HumanoidRootPart")
                            local hum = char and char:FindFirstChild("Humanoid")
                            if enemy ~= Player and hum and hum.Health > 0 and hrp then
                                local dist = (hrp.Position - myRoot.Position).Magnitude
                                if dist < closestDistance then
                                    local onDifferentTeam = (not enemy.Team or enemy.Team ~= Player.Team)
                                    local isVisibleInFov = (Camera.CFrame.LookVector:Dot((hrp.Position - Camera.CFrame.Position).Unit) >= 0.9)
                                    if onDifferentTeam and isVisibleInFov then
                                        closestDistance = dist
                                        closestTarget = enemy
                                    end
                                end
                            end
                        end
                        if closestTarget and canShoot then
                            local targetChar = closestTarget.Character
                            local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                            if targetHrp and has_clear_los(myRoot.Position, targetHrp.Position, myChar, targetChar) then ShootGun(closestTarget) end
                        end
                    end
                    task.wait(0.03)
                end
            end)
        end
    end
})
Main:Slider({ Title = "Autoshoot Max Distance", Step = 1, Flag = "AutoshootMaxDistanceSlider", Value = { Min = 0, Max = 1000, Default = 300 }, Callback = function(value) getgenv().max_distance = value end })
Main:Slider({ Title = "Cooldown", Step = 0.5, Flag = "AutoshootCooldownSlider", Value = { Min = 0.5, Max = 10, Default = 2 }, Callback = function(value) getgenv().autoshoot_cooldown = value end })
Main:Space()

getgenv().auto_throw_enabled = false
getgenv().max_distance = 300
getgenv().throw_cooldown = 2
local autoThrowThread = nil
local lastThrowTime = 0
local function throwKnife(targetChar)
    local tool = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool or not tool:FindFirstChild("RightHandle") then return end
    local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
    if not targetHrp then return end
    local origin = CharacterRayOrigin(game.Players.LocalPlayer.Character)
    local direction = (targetHrp.Position - origin).Unit
    ReplicatedStorage.Remotes.ThrowStart:FireServer(origin, direction)
    require(ReplicatedStorage.Modules.KnifeProjectileController)({
        Speed = tool:GetAttribute("ThrowSpeed"),
        KnifeProjectile = tool.RightHandle:Clone(),
        Direction = direction,
        Origin = origin
    }, function(raycastResult)
        ReplicatedStorage.Remotes.ThrowHit:FireServer(raycastResult and raycastResult.Instance, raycastResult and raycastResult.Position)
    end)
    lastThrowTime = tick()
end
local uteuirhguh = Main:Toggle({
    Title = "Enable auto throw knife",
    Desc = "Automatically throws your knife at enemies",
    Default = false,
    Callback = function(Value)
        getgenv().auto_throw_enabled = Value
        if autoThrowThread then task.cancel(autoThrowThread); autoThrowThread = nil end
        if Value then
            autoThrowThread = task.spawn(function()
                while getgenv().auto_throw_enabled do
                    if (tick() - lastThrowTime) >= getgenv().throw_cooldown then
                        local myChar = game.Players.LocalPlayer.Character
                        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                        if myRoot then
                            local closestTarget = nil
                            local shortestDist = getgenv().max_distance
                            for _, player in matchEnemies do
                                if player ~= game.Players.LocalPlayer and player.Character and player.Team ~= Player.Team then
                                    local enemyHrp = player.Character:FindFirstChild("HumanoidRootPart")
                                    local enemyHum = player.Character:FindFirstChild("Humanoid")
                                    if enemyHrp and enemyHum and enemyHum.Health > 0 then
                                        local dist = (enemyHrp.Position - myRoot.Position).Magnitude
                                        local params = RaycastParams.new()
                                        params.FilterDescendantsInstances = { myChar, player.Character }
                                        params.FilterType = Enum.RaycastFilterType.Exclude
                                        local result = workspace:Raycast(myRoot.Position, (enemyHrp.Position - myRoot.Position), params)
                                        if dist < shortestDist and not result then
                                            shortestDist = dist
                                            closestTarget = player.Character
                                        end
                                    end
                                end
                            end
                            if closestTarget then throwKnife(closestTarget) end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})
Main:Slider({ Title = "Max Throw Distance", Value = { Min = 0, Max = 1000, Default = 300 }, Callback = function(v) getgenv().max_distance = v end })
Main:Slider({ Title = "Cooldown", Value = { Min = 0.5, Max = 10, Default = 2 }, Callback = function(v) getgenv().throw_cooldown = v end })
Main:Space()

getgenv().triggerbot_enabled = false
getgenv().triggerbot_firing = false
getgenv().triggerbot_cooldown = 1
local function triggerbot_valid_enemy(enemy)
    if not enemy or enemy == Player then return false end
    local character = enemy.Character
    if not character or character.Parent ~= Workspace then return false end
    if enemy.Team and enemy.Team == Player.Team then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local my_hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and hrp and my_hrp) then return false end
    if humanoid.Health <= 0 then return false end
    if Collection:HasTag(character, "Invulnerable") or Collection:HasTag(character, "SpeedTrail") then return false end
    return true
end
local function triggerbot_shoot(target)
    local my_char = Player.Character
    local my_root = my_char and my_char:FindFirstChild("HumanoidRootPart")
    local target_hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not (my_root and target_hrp) then getgenv().triggerbot_firing = false; return end
    local hit_part = target.Character:FindFirstChild("LowerTorso") or target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Head")
    if hit_part then ShootGun(target) else getgenv().triggerbot_firing = false end
end
RunService.Heartbeat:Connect(function()
    if not getgenv().triggerbot_enabled then return end
    if not getgenv().match then return end
    if getgenv().triggerbot_firing then return end
    local character = Player.Character
    if not character then return end
    local mousePos = UserInputService:GetMouseLocation()
    local ray = Camera:ViewportPointToRay(mousePos.X, mousePos.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { character }
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 2000, rayParams)
    if not result then return end
    local hitCharacter = result.Instance:FindFirstAncestorOfClass("Model")
    if not hitCharacter then return end
    local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)
    if not hitPlayer then return end
    if triggerbot_valid_enemy(hitPlayer) then
        getgenv().triggerbot_firing = true
        triggerbot_shoot(hitPlayer)
        task.delay(getgenv().triggerbot_cooldown, function() getgenv().triggerbot_firing = false end)
    end
end)
Main:Toggle({
    Title = "Trigger Bot",
    Desc = "Automatically shoots when your mouse hovers over an enemy",
    Icon = "check",
    Default = false,
    Flag = "TriggerBotToggle",
    Callback = function(Value)
        getgenv().triggerbot_enabled = Value
        if getgenv().triggerbot_enabled then FeatureActivated(true) else FeatureActivated(false) end
    end
})
Main:Slider({ Title = "Trigger Bot Cooldown", Step = 0.1, Flag = "TriggerBotCooldownSlider", Value = { Min = 0, Max = 3, Default = 1 }, Callback = function(value) getgenv().triggerbot_cooldown = value end })
Main:Space()

getgenv().hitbox_expander = false
getgenv().hitbox_size = 13
getgenv().hitbox_color = Color3.fromRGB(255, 0, 0)
Main:Toggle({
    Title = "Enable Hitbox Expander",
    Desc = "Adds hitbox to all enemies",
    Icon = "check",
    Default = false,
    Flag = "HitboxEnableToggle",
    Callback = function(Value)
        getgenv().hitbox_expander = Value
        if getgenv().hitbox_expander then FeatureActivated(true) else FeatureActivated(false) end
        if not getgenv().hitbox_expander then
            for _, player in matchEnemies do
                if player ~= Player then
                    local character = player.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2, 2, 1)
                        hrp.CanCollide = false
                        local hit_box = hrp:FindFirstChild("hit_box")
                        if hit_box then hit_box:Destroy() end
                    end
                end
            end
            return
        end
        task.spawn(function()
            while getgenv().hitbox_expander and task.wait(0.1) do
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= Player and player.Character then
                        local character = player.Character
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local enemy = player.Team ~= Player.Team
                            if enemy then
                                hrp.Size = Vector3.new(getgenv().hitbox_size, getgenv().hitbox_size, getgenv().hitbox_size)
                                hrp.CanCollide = true
                                local hit_box = hrp:FindFirstChild("hit_box")
                                if not hit_box then
                                    local box_handle = Instance.new("BoxHandleAdornment")
                                    box_handle.Name = "hit_box"
                                    box_handle.Adornee = hrp
                                    box_handle.AlwaysOnTop = true
                                    box_handle.ZIndex = 10
                                    box_handle.Size = hrp.Size
                                    box_handle.Color3 = getgenv().hitbox_color
                                    box_handle.Transparency = 0.8
                                    box_handle.Parent = hrp
                                else
                                    hit_box.Size = hrp.Size
                                end
                            else
                                hrp.Size = Vector3.new(2, 2, 1)
                                hrp.CanCollide = false
                                local hit_box = hrp:FindFirstChild("hit_box")
                                if hit_box then hit_box:Destroy() end
                            end
                        end
                    end
                end
            end
        end)
    end
})
Main:Slider({ Title = "Hitbox Size", Step = 1, Flag = "HitboxSizeSlider", Value = { Min = 5, Max = 100, Default = 13 }, Callback = function(size) getgenv().hitbox_size = size end })
Main:Colorpicker({ Title = "Hitbox Color", Default = Color3.fromRGB(255, 0, 0), Transparency = 0, Locked = false, Flag = "HitboxColorPicker", Callback = function(color) getgenv().hitbox_color = color end })
Main:Space()
getgenv().original_cooldowns = {}
Main:Toggle({
    Title = "Remove Gun Cooldown",
    Desc = "You may need to re-equip your weapon for changes to apply",
    Icon = "check",
    Default = false,
    Flag = "RemoveGunCooldownToggle",
    Callback = function(Value)
        getgenv().remove_gun_cooldown = Value
        if getgenv().remove_gun_cooldown then FeatureActivated(true) else FeatureActivated(false) end
        if Value then
            getgenv().original_cooldowns = {}
            task.spawn(function()
                while getgenv().remove_gun_cooldown do
                    task.wait(0.1)
                    local tools = {}
                                                for _, container in ipairs({ Player:FindFirstChild("Backpack"), Player.Character }) do
                        if container then
                            for _, tool in ipairs(container:GetChildren()) do
                                if tool:IsA("Tool") and tool:FindFirstChild("Fire") then 
                                    table.insert(tools, tool) 
                                end
                            end
                        end
                    end
                    for _, tool in ipairs(tools) do
                        if getgenv().original_cooldowns[tool] == nil then 
                            getgenv().original_cooldowns[tool] = tool:GetAttribute("Cooldown") 
                        end
                        if tool:GetAttribute("Cooldown") ~= 0 then 
                            tool:SetAttribute("Cooldown", 0) 
                        end
                    end
                end
            end)
        else
            for tool, cooldown in pairs(getgenv().original_cooldowns) do
                if tool and tool.Parent then 
                    tool:SetAttribute("Cooldown", cooldown) 
                end
            end
            getgenv().original_cooldowns = {}
        end
    end,
})
local Esp = window:Tab({ Title = "Esp Highlights", Icon = "eye", Locked = false })
getgenv().esp_team_color = Color3.fromRGB(0, 255, 0)
getgenv().esp_enemy_color = Color3.fromRGB(255, 0, 0)
getgenv().esp_charms_highlighter = false
local charms_esp = CoreGui:FindFirstChild("Highlights") or Instance.new("Folder")
charms_esp.Name = "CharmsESP"
charms_esp.Parent = CoreGui
Esp:Toggle({
    Title = "Enable Charms Highlighter",
    Desc = "Highlights players full body",
    Icon = "check",
    Default = false,
    Flag = "EspCharmsToggle",
    Callback = function(Value)
        getgenv().esp_charms_highlighter = Value
        if not getgenv().esp_charms_highlighter then
            FeatureActivated(false)
            for _, esp_players in ipairs(charms_esp:GetChildren()) do esp_players:Destroy() end
            return
        else
            FeatureActivated(true)
        end
        task.spawn(function()
            while getgenv().esp_charms_highlighter do
                task.wait(0.1)
                for _, v in matchEnemies do
                    if not getgenv().esp_charms_highlighter then break end
                    if v ~= Player then
                        local character = v.Character
                        if character then
                            local highlight = charms_esp:FindFirstChild(v.Name)
                            if not highlight then
                                highlight = Instance.new("Highlight")
                                highlight.Name = v.Name
                                highlight.FillTransparency = 0.6
                                highlight.OutlineTransparency = 0.4
                                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                highlight.Parent = charms_esp
                            end
                            local teamColor = (v.Team == Player.Team) and getgenv().esp_team_color or getgenv().esp_enemy_color
                            highlight.FillColor = teamColor
                            highlight.OutlineColor = teamColor
                            highlight.Adornee = character
                        end
                    end
                end
            end
        end)
    end
})
getgenv().esp_skeleton = false
local skeleton_folder = CoreGui:FindFirstChild("Skeletons") or Instance.new("Folder")
skeleton_folder.Name = "Skeletons"
skeleton_folder.Parent = CoreGui
Esp:Toggle({
    Title = "Enable Skeletal Highlighter",
    Desc = "Highlights players skeleton",
    Icon = "check",
    Default = false,
    Flag = "EspSkeletonToggle",
    Callback = function(Value)
        getgenv().esp_skeleton = Value
        local function cleanup()
            for _, child in ipairs(skeleton_folder:GetChildren()) do child:Destroy() end
        end
        if not Value then cleanup(); FeatureActivated(false); return else FeatureActivated(true) end
        task.spawn(function()
            local function createLine()
                local line = Instance.new("LineHandleAdornment")
                line.Thickness = 2
                line.ZIndex = 10
                line.AlwaysOnTop = true
                return line
            end
            local bones = {
                { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
                { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
                { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
                { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
                { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" }
            }
            while getgenv().esp_skeleton do
                task.wait(0.1)
                for _, v in matchEnemies do
                    local char = v.Character
                    local holder = skeleton_folder:FindFirstChild(v.Name)
                    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                        if not holder then holder = Instance.new("Folder"); holder.Name = v.Name; holder.Parent = skeleton_folder end
                        local color = (v.Team == Player.Team) and getgenv().esp_team_color or getgenv().esp_enemy_color
                        for i, bonePair in ipairs(bones) do
                            local p1, p2 = char:FindFirstChild(bonePair[1]), char:FindFirstChild(bonePair[2])
                            if p1 and p2 then
                                local line = holder:FindFirstChild(tostring(i)) or createLine()
                                line.Name = tostring(i)
                                line.Color3 = color
                                line.Adornee = p1
                                line.CFrame = CFrame.new(Vector3.zero, p1.CFrame:PointToObjectSpace(p2.Position))
                                line.Length = (p1.Position - p2.Position).Magnitude
                                line.Parent = holder
                            end
                        end
                    elseif holder then holder:Destroy() end
                end
                for _, child in ipairs(skeleton_folder:GetChildren()) do
                    if not Players:FindFirstChild(child.Name) then child:Destroy() end
                end
            end
            cleanup()
        end)
    end
})
getgenv().esp_tracers = false
local tracers_folder = CoreGui:FindFirstChild("Tracers") or Instance.new("Folder")
tracers_folder.Name = "Tracers"
tracers_folder.Parent = CoreGui
local tracerConnection = nil
Esp:Toggle({
    Title = "Enable Tracers Highlighter",
    Desc = "Draws lines from your character to others smoothly.",
    Icon = "check",
    Default = false,
    Flag = "EspTracersToggle",
    Callback = function(Value)
        getgenv().esp_tracers = Value
        local function cleanup()
            for _, child in ipairs(tracers_folder:GetChildren()) do child:Destroy() end
        end
        if tracerConnection then tracerConnection:Disconnect(); tracerConnection = nil end
        if not Value then cleanup(); FeatureActivated(false); return else FeatureActivated(true) end
        tracerConnection = RunService.RenderStepped:Connect(function()
            if not getgenv().esp_tracers then
                if tracerConnection then tracerConnection:Disconnect(); tracerConnection = nil end
                cleanup()
                return
            end
            local myChar = Player.Character
            local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
            if myRoot then
                for _, v in ipairs(matchEnemies) do
                    if v ~= Player and v.Parent then
                        local char = v.Character
                        local tracer = tracers_folder:FindFirstChild(v.Name)
                        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                            if not tracer then
                                tracer = Instance.new("LineHandleAdornment")
                                tracer.Name = v.Name
                                tracer.Thickness = 1.5
                                tracer.ZIndex = 10
                                tracer.AlwaysOnTop = true
                                tracer.Parent = tracers_folder
                            end
                            local targetRoot = char.HumanoidRootPart
                            local color = (v.Team == Player.Team) and getgenv().esp_team_color or getgenv().esp_enemy_color
                            tracer.Color3 = color
                            tracer.Adornee = workspace.Terrain
                            tracer.CFrame = CFrame.lookAt(myRoot.Position, targetRoot.Position)
                            tracer.Length = (myRoot.Position - targetRoot.Position).Magnitude
                        elseif tracer then
                            tracer:Destroy()
                        end
                    end
                end
            else
                cleanup()
            end
            for _, child in ipairs(tracers_folder:GetChildren()) do
                if not Players:FindFirstChild(child.Name) then child:Destroy() end
            end
        end)
    end
})
Esp:Colorpicker({ Title = "Team Color Highlight", Desc = "Esp color for teammates", Default = Color3.fromRGB(0, 255, 0), Transparency = 0, Locked = false, Flag = "EspTeamColorPicker", Callback = function(color) getgenv().esp_team_color = color end })
Esp:Colorpicker({ Title = "Enemy Color Highlight", Desc = "Esp color for enemies", Default = Color3.fromRGB(255, 0, 0), Transparency = 0, Locked = false, Flag = "EspEnemyColorPicker", Callback = function(color) getgenv().esp_enemy_color = color end })

local Killing = window:Tab({ Title = "Kill All", Icon = "skull", Locked = false })
getgenv().autoKillGun = false
Killing:Button({
    Title = "[GUN] Kill all players once",
    Desc = "Kills all players in your server once",
    Locked = false,
    Callback = function()
        if getgenv().match then
            local myMatch = Player:GetAttribute("Match")
            if myMatch then
                equipGun()
                wind:Notify({ Title = "Killing all players!", Content = "Enjoying APEX?", Duration = 3, Icon = "rbxassetid://139687752061139" })
                for _, plr in matchEnemies do
                    if plr.Team ~= Player.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local target = plr.Character.HumanoidRootPart
                        local origin = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if origin then
                            local ShootGun = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")
                            ShootGun:FireServer(origin.Position, target.Position, target, target.Position)
                        end
                    end
                    task.wait(0.1)
                end
            end
        end
    end
})
Killing:Toggle({
    Title = "[GUN] Auto kill all players",
    Desc = "Kills everyone constantly in your server with gun",
    Value = false,
    Callback = function(state)
        getgenv().autoKillGun = state
        if state then FeatureActivated(true) else FeatureActivated(false) end
    end
})
task.spawn(function()
    while true do
        if getgenv().autoKillGun then
            local myMatch = Player:GetAttribute("Match")
            if myMatch then
                equipGun()
                for _, plr in matchEnemies do
                    if plr.Team ~= Player.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local target = plr.Character.HumanoidRootPart
                        local origin = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                        if origin then
                            local ShootGun = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ShootGun")
                            ShootGun:FireServer(origin.Position, target.Position, target, target.Position)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
getgenv().autoKillKnife = false
Killing:Button({
    Title = "[KNIFE] Kill all players once",
    Desc = "Kills all players in your server once",
    Locked = false,
    Callback = function()
        if getgenv().match then
            local myMatch = Player:GetAttribute("Match")
            if myMatch then
                equipKnife()
                wind:Notify({ Title = "Killing all players!", Content = "Enjoying APEX?", Duration = 3, Icon = "rbxassetid://139687752061139" })
                for _, target in ipairs(Players:GetPlayers()) do
                    if target ~= Player and target.Character then
                        local humanoid = target.Character:FindFirstChild("Humanoid")
                        local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                        if humanoid and humanoid.Health > 0 and rootPart then
                            local knifeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ThrowHit")
                            knifeRemote:FireServer(rootPart, rootPart.Position)
                        end
                    end
                    task.wait(0.1)
                end
            end
        end
    end
})
Killing:Toggle({
    Title = "[KNIFE] Auto kill all players",
    Desc = "Kills everyone constantly in your server with knife",
    Value = false,
    Callback = function(state)
        getgenv().autoKillKnife = state
        if state then FeatureActivated(true) else FeatureActivated(false) end
    end
})
task.spawn(function()
    while true do
        if getgenv().autoKillKnife then
            local myMatch = Player:GetAttribute("Match")
            if myMatch then
                equipKnife()
                for _, target in matchEnemies do
                    if target ~= Player and target.Character then
                        local humanoid = target.Character:FindFirstChild("Humanoid")
                        local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                        if humanoid and humanoid.Health > 0 and rootPart then
                            local knifeRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ThrowHit")
                            knifeRemote:FireServer(rootPart, rootPart.Position)
                        end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
local Ability = window:Tab({ Title = "Abilitys", Icon = "zap", Locked = false })
getgenv().autoShroud = false
getgenv().lowExecutorsShroud = false
getgenv().shroudRate = 1
local ConfigSuccess, Config = pcall(function() return require(game:GetService("ReplicatedStorage").Ability.AbilityConfig) end)
local ActivateShroud = ReplicatedStorage.Ability:WaitForChild("ActivateShroud")
local isLocked = (not ConfigSuccess)
local originals = {
    SprintCooldown = not isLocked and Config.SprintCooldown or 15,
    DashCooldown = not isLocked and Config.DashCooldown or 6,
    ShroudCooldown = not isLocked and Config.ShroudCooldown or 7,
    SoulReapCombatDelay = not isLocked and Config.SoulReapCombatDelay or 0.35
}
if isLocked then uteuirhguh:Lock() end
local function blind(targetPlayer)
    local character = Players.LocalPlayer.Character
    if targetPlayer and targetPlayer.Character and character then
        local targetPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local root = character:FindFirstChild("HumanoidRootPart")
        if targetPart and root then
            local origin
            local direction
            if getgenv().lowExecutorsShroud then
                origin = root.Position
                direction = (targetPart.Position - origin).Unit
                ActivateShroud:FireServer(origin, direction)
            else
                local s1, CharacterRayOrigin = pcall(function() return require(ReplicatedStorage.Modules.CharacterRayOrigin) end)
                local s2, ShroudProjectileController = pcall(function() return require(ReplicatedStorage.Ability.ShroudProjectileController) end)
                if s1 and s2 then
                    origin = CharacterRayOrigin(character)
                    direction = (targetPart.Position - origin).Unit
                    ActivateShroud:FireServer(origin, direction)
                    ShroudProjectileController(origin, direction)
                else
                    getgenv().lowExecutorsShroud = true
                    origin = root.Position
                    direction = (targetPart.Position - origin).Unit
                    ActivateShroud:FireServer(origin, direction)
                end
            end
        end
    end
end
Ability:Toggle({ Title = "Auto Shroud All", Desc = "Automatically blinds all enemies in match", Value = false, Callback = function(state) getgenv().autoShroud = state end })
Ability:Toggle({ Title = "Low Executor Mode", Desc = "Supports all executors, may not notice shroud box/sound but blinds enemy and saves FPS", Value = false, Callback = function(state) getgenv().lowExecutorsShroud = state end })
Ability:Slider({ Title = "Amount of Shrouds per Enemy", Desc = "Adjust firing rate per enemy, a high number increases fps for entire game", Step = 0.1, Value = { Min = 1, Max = 10000, Default = 1 }, Callback = function(value) getgenv().shroudRate = value end })
task.spawn(function()
    while true do
        if getgenv().autoShroud then
            for _, p in matchEnemies do blind(p) end
            task.wait(1 / getgenv().shroudRate)
        else
            task.wait(0.5)
        end
    end
end)
Ability:Space()
task.spawn(function() if not isLocked then lockedParagraph:Destroy() end end)
Ability:Toggle({ Title = "Remove Sprint Cooldown", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.SprintCooldown = state and 0 or originals.SprintCooldown else NotSupportedFeature() end end })
Ability:Toggle({ Title = "Remove Dash Cooldown", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.DashCooldown = state and 0 or originals.DashCooldown else NotSupportedFeature() end end })
Ability:Toggle({ Title = "Remove Shroud Cooldown", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.ShroudCooldown = state and 0 or originals.ShroudCooldown else NotSupportedFeature() end end })
Ability:Toggle({ Title = "Remove Soul Reap Combat Delay", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.SoulReapCombatDelay = state and 0 or originals.SoulReapCombatDelay else NotSupportedFeature() end end })
Ability:Space()
Ability:Slider({ Title = "Sprint Time", Step = 0.5, Locked = isLocked, Value = { Min = 0.5, Max = 10, Default = not isLocked and Config.SprintTime or 0 }, Callback = function(value) if not isLocked then Config.SprintTime = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Sprint Boost", Step = 0.1, Locked = isLocked, Value = { Min = 0, Max = 5, Default = not isLocked and Config.SprintBoost or 0 }, Callback = function(value) if not isLocked then Config.SprintBoost = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Soul Reap Time", Step = 0.5, Locked = isLocked, Value = { Min = 0.5, Max = 10, Default = not isLocked and Config.SoulReapTime }, Callback = function(value) if not isLocked then Config.SoulReapTime = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Soul Reap Speed Boost", Step = 0.1, Locked = isLocked, Value = { Min = 0.1, Max = 10, Default = not isLocked and Config.SoulReapSpeedBoost or 0 }, Callback = function(value) if not isLocked then Config.SoulReapSpeedBoost = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Propeller Jump Boost", Step = 0.1, Locked = isLocked, Value = { Min = 0.1, Max = 5, Default = not isLocked and Config.PropellerJumpBoost or 0 }, Callback = function(value) if not isLocked then Config.PropellerJumpBoost = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Shroud Time", Step = 0.5, Locked = isLocked, Value = { Min = 0.5, Max = 10, Default = not isLocked and Config.ShroudTime or 0 }, Callback = function(value) if not isLocked then Config.ShroudTime = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Shroud Projectile Speed", Step = 2.5, Locked = isLocked, Value = { Min = 2.5, Max = 100, Default = not isLocked and Config.ShroudProjectileSpeed or 0 }, Callback = function(value) if not isLocked then Config.ShroudProjectileSpeed = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Shroud Projectile Range", Step = 5, Locked = isLocked, Value = { Min = 5, Max = 1000, Default = not isLocked and Config.ShroudProjectileRange or 0 }, Callback = function(value) if not isLocked then Config.ShroudProjectileRange = value else NotSupportedFeature() end end })
