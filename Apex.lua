-- ============================================================
--  APEX | MVSD
-- ============================================================
if getgenv().TFjhJhggCUo then
    print("you have already executed this script!")
    return
end
getgenv().TFjhJhggCUo = true

local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local window = wind:CreateWindow({
    Title = "APEX | MVSD",
    Icon = "rbxassetid://139687752061139",
    Author = "by APEX | MVSD",
    Folder = "APEXMVSD_Script",
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
    Title = "Welcome to APEX | MVSD",
    Desc =
    "We hope you find this script useful, if you find any issues please report them below to my discord by making a ticket, thank you for using us!",
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
    Desc =
    "You are currently using an unsupported executor (Solara/Xeno). Certain features have been restricted by our automated system to ensure stability. To unlock full functionality and access all available tools, please switch to a recommended executor (Velocity/Madium)!",
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
    if not character or not backpack then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
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
    if not character or not backpack then
        return false
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
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
    local fadeIn = TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
        Width0 = 0.3,
        Width1 = 0.6
    })
    local fadeOut = TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
        Width0 = 0,
        Width1 = 0
    })
    fadeIn:Play()
    fadeIn.Completed:Connect(function()
        fadeOut:Play()
    end)
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
        if sound and sound:IsA("Sound") then
            sound:Play()
        end
        task.delay(2.5, function()
            canShoot = true
        end)
    end
end
local lastNotify = 0
local function NotSupportedFeature()
    local currentTime = tick()
    if currentTime - lastNotify >= 5 then
        lastNotify = currentTime

        wind:Notify({
            Title = "Uh Oh! Executor not supported!",
            Content =
            "Sorry! Your executor isn't supported to run this feature, we have made sure of that by running simple checks once you loaded this script!",
            Duration = 3,
            Icon = "rbxassetid://139687752061139",
        })

        wind:Notify({
            Title = "Notice!",
            Content = "If your on PC/Laptop, try using Velocity (its free!), on Android/Ios please try using Delta!",
            Duration = 3,
            Icon = "rbxassetid://139687752061139",
        })
    end
end
local function FeatureActivated(boolean)
    if boolean then
        wind:Notify({
            Title = "Activated Feature!!",
            Content =
            "Enjoying APEX | MVSD? Join our discord server located in the Welcome tab for even better stuff!",
            Duration = 3,
            Icon = "rbxassetid://139687752061139",
        })
    else
        wind:Notify({
            Title = "Disabled Feature!!",
            Content =
            "Enjoying APEX | MVSD? Join our discord server located in the Welcome tab for even better stuff!",
            Duration = 3,
            Icon = "rbxassetid://139687752061139",
        })
    end
end

-- ======================== MAIN TAB ========================
local Main = window:Tab({
    Title = "Main",
    Icon = "house",
    Locked = false,
})
local ConfigurationSection = Main:Section({
    Title = "Configuration",
    Opened = true,
})
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
                if not character.Parent or humanoid.Health <= 0 then
                    connection:Disconnect()
                    return
                end
                if rootPart.Anchored and autounanchor then
                    rootPart.Anchored = false
                end
            end)
        end
        if Player.Character then
            task.spawn(monitorCharacter, Player.Character)
        end
        Player.CharacterAdded:Connect(monitorCharacter)
    end
})
ConfigurationSection:Colorpicker({
    Title = "Bullet Tracer Color",
    Desc = "Changes the color of your bullet tracer",
    Flag = "BulletTracerColorPicker",
    Default = BulletRendererColor,
    Locked = false,
    Callback = function(color)
        BulletRendererColor = color
    end
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
        if autoshoot_thread then
            task.cancel(autoshoot_thread)
            autoshoot_thread = nil
        end
        if getgenv().autoshoot_enabled then
            local function has_clear_los(fromPos, toPos, myCharacter, targetCharacter)
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = { myCharacter, targetCharacter }
                params.FilterType = Enum.RaycastFilterType.Exclude
                local result = workspace:Raycast(fromPos, (toPos - fromPos), params)
                if result then
                    if not result.Instance:IsDescendantOf(targetCharacter) then
                        return false
                    end
                end
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
                            if targetHrp and has_clear_los(myRoot.Position, targetHrp.Position, myChar, targetChar) then
                                ShootGun(closestTarget)
                            end
                        end
                    end
                    task.wait(0.03)
                end
            end)
        end
    end
})
Main:Slider({
    Title = "Autoshoot Max Distance",
    Step = 1,
    Flag = "AutoshootMaxDistanceSlider",
    Value = { Min = 0, Max = 1000, Default = 300 },
    Callback = function(value) getgenv().max_distance = value end
})
Main:Slider({
    Title = "Cooldown",
    Step = 0.5,
    Flag = "AutoshootCooldownSlider",
    Value = { Min = 0.5, Max = 10, Default = 2 },
    Callback = function(value) getgenv().autoshoot_cooldown = value end
})
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
        ReplicatedStorage.Remotes.ThrowHit:FireServer(raycastResult and raycastResult.Instance,
            raycastResult and raycastResult.Position)
    end)
    lastThrowTime = tick()
end
local uteuirhguh = Main:Toggle({
    Title = "Enable auto throw knife",
    Desc = "Automatically throws your knife at enemies",
    Default = false,
    Callback = function(Value)
        getgenv().auto_throw_enabled = Value
        if autoThrowThread then
            task.cancel(autoThrowThread)
            autoThrowThread = nil
        end
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
                                        local result = workspace:Raycast(myRoot.Position,
                                 
