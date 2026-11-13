if getgenv().ApexMvsdExecuted then
    print("you have already executed this script!")
    return
end
getgenv().ApexMvsdExecuted = true

local wind = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local window = wind:CreateWindow({
    Title = "APEX | MVSD",
    Icon = "rbxassetid://114305907211721",
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
    User = { Enabled = true, Anonymous = true, Callback = function() end },
})
window:EditOpenButton({
    Title = "APEX",
    Icon = "rbxassetid://114305907211721",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("0A1128"), Color3.fromHex("4B0082")),
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
    Title = " BEM-VINDO À APEX",
    Desc = "O melhor script para dominar o servidor. Entre no nosso Discord para novidades e atualizações.",
    Color = Color3.fromHex("#1756B8"),
    Thumbnail = "rbxassetid://114305907211721",
    ThumbnailSize = 150,
    Buttons = {
        {
            Icon = "square-arrow-out-up-right",
            Title = "Copiar Nosso Discord",
            Callback = function()
                setclipboard("https://discord.gg/aNsWdE6nN")
                wind:Notify({Title = "Copiado!", Content = "Link do Discord copiado.", Duration = 3})
            end,
        }
    }
})
local lockedParagraph = Welcome:Paragraph({
    Title = "Executor Não Suportado",
    Desc = "Você está usando um executor não suportado (Solara/Xeno). Alguns recursos foram limitados para garantir a estabilidade. Mude para um executor recomendado (Velocity/Madium) para desbloquear tudo!",
    Color = "Red",
    Locked = false
})
Welcome:Paragraph({
    Title = "Atualizações",
    Desc = "Você pode ver as últimas atualizações e correções no nosso servidor do Discord!",
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
            getgenv().match = Player:GetAttribute("Match") and true or false
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
                        gun = tool; break
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
                    soundConnection = fireSound.Played:Connect(function() lastFiredTime = tick() end)
                end
            end
        else
            lastGunTracked = nil
            if soundConnection then soundConnection:Disconnect(); soundConnection = nil end
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
        if gun then humanoid:EquipTool(gun); return true end
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
                humanoid:EquipTool(tool); return true
            end
        end
    end
    return false
end

local BulletRendererColor = Color3.fromRGB(255, 255, 255)
local function BulletRenderer(origin, targetPos)
    local function CreatePseudoPart(cf)
        local p = Instance.new("Part")
        p.Size = Vector3.new(0.1, 0.1, 0.1); p.Transparency = 1; p.CanCollide = false
        p.CanQuery = false; p.CanTouch = false; p.Anchored = true; p.CFrame = cf; p.Parent = workspace
        return p
    end
    local startPart = CreatePseudoPart(CFrame.lookAt(origin, targetPos) * CFrame.new(0, 0, -1))
    local endPart = CreatePseudoPart(CFrame.new(targetPos))
    local beam = Instance.new("Beam")
    beam.Texture = ""; beam.TextureLength = 1; beam.TextureMode = Enum.TextureMode.Stretch
    beam.TextureSpeed = 0; beam.Color = ColorSequence.new(BulletRendererColor)
    beam.LightEmission = 1; beam.LightInfluence = 0; beam.Brightness = 5
    beam.Width0 = 0; beam.Width1 = 0
    local att0 = Instance.new("Attachment", startPart); local att1 = Instance.new("Attachment", endPart)
    beam.Attachment0 = att0; beam.Attachment1 = att1; beam.Parent = startPart
    local fadeIn = TweenService:Create(beam, TweenInfo.new(0.05, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Width0 = 0.3, Width1 = 0.6 })
    local fadeOut = TweenService:Create(beam, TweenInfo.new(0.1, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), { Width0 = 0, Width1 = 0 })
    fadeIn:Play(); fadeIn.Completed:Connect(function() fadeOut:Play() end)
    Debris:AddItem(startPart, 0.3); Debris:AddItem(endPart, 0.3)
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
        local startPos = origin
        if tool then
            local muzzle = tool:FindFirstChild("Muzzle", true)
            if muzzle then startPos = muzzle.WorldPosition end
        end
        BulletRenderer(startPos, targetPos)
        ReplicatedStorage.Remotes.ShootGun:FireServer(origin, targetPos, hitPart, targetPos)
        if tool then
            local sound = tool:FindFirstChild("Fire")
            if sound and sound:IsA("Sound") then sound:Play() end
        end
        task.delay(2.5, function() canShoot = true end)
    end
end

local lastNotify = 0
local function NotSupportedFeature()
    local currentTime = tick()
    if currentTime - lastNotify >= 5 then
        lastNotify = currentTime
        wind:Notify({ Title = "Executor não suportado!", Content = "Seu executor não suporta esse recurso.", Duration = 3, Icon = "rbxassetid://114305907211721" })
        wind:Notify({ Title = "Aviso!", Content = "Se você usa PC, tente o Velocity. No celular, tente o Delta!", Duration = 3, Icon = "rbxassetid://114305907211721" })
    end
end

local function FeatureActivated(boolean)
    if boolean then
        wind:Notify({ Title = "SISTEMA ATIVADO", Content = "Módulo de combate iniciado.", Duration = 3, Icon = "rbxassetid://114305907211721" })
    else
        wind:Notify({ Title = "SISTEMA DESATIVADO", Content = "Módulo de combate encerrado.", Duration = 3, Icon = "rbxassetid://114305907211721" })
    end
end

local Main = window:Tab({ Title = "Main", Icon = "house", Locked = false })
local ConfigurationSection = Main:Section({ Title = "Configuração", Opened = true })
local autounanchor = false
ConfigurationSection:Toggle({
    Title = "Pular Contagem (Unanchor)",
    Desc = "Bypassa a espera de 5 segundos antes da partida começar.",
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
    Title = "Cor do Traçante",
    Desc = "Muda a cor do rastro da bala.",
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
    Title = "Autoshoot",
    Desc = "Atira automaticamente nos inimigos na sua frente.",
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
                                        closestDistance = dist; closestTarget = enemy
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
Main:Slider({ Title = "Distância Máxima", Step = 1, Flag = "AutoshootMaxDistanceSlider", Value = { Min = 0, Max = 1000, Default = 300 }, Callback = function(value) getgenv().max_distance = value end })
Main:Slider({ Title = "Cooldown do Tiro", Step = 0.5, Flag = "AutoshootCooldownSlider", Value = { Min = 0.5, Max = 10, Default = 2 }, Callback = function(value) getgenv().autoshoot_cooldown = value end })
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
    Title = "Auto Arremessar Faca",
    Desc = "Joga a faca automaticamente nos inimigos.",
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
Main:Slider({ Title = "Distância da Faca", Value = { Min = 0, Max = 1000, Default = 300 }, Callback = function(v) getgenv().max_distance = v end })
Main:Slider({ Title = "Cooldown da Faca", Value = { Min = 0.5, Max = 10, Default = 2 }, Callback = function(v) getgenv().throw_cooldown = v end })
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
    Desc = "Atira automaticamente quando você mira em um inimigo.",
    Icon = "check",
    Default = false,
    Flag = "TriggerBotToggle",
    Callback = function(Value)
        getgenv().triggerbot_enabled = Value
        if getgenv().triggerbot_enabled then FeatureActivated(true) else FeatureActivated(false) end
    end
})
Main:Slider({ Title = "Cooldown do Trigger", Step = 0.1, Flag = "TriggerBotCooldownSlider", Value = { Min = 0, Max = 3, Default = 1 }, Callback = function(value) getgenv().triggerbot_cooldown = value end })
Main:Space()
getgenv().hitbox_expander = false
getgenv().hitbox_size = 13
getgenv().hitbox_color = Color3.fromRGB(255, 0, 0)
Main:Toggle({
    Title = "Hitbox Expander",
    Desc = "Aumenta a hitbox de todos os inimigos para você acertar mais fácil.",
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
Main:Slider({ Title = "Tamanho da Hitbox", Step = 1, Flag = "HitboxSizeSlider", Value = { Min = 5, Max = 100, Default = 13 }, Callback = function(size) getgenv().hitbox_size = size end })
Main:Colorpicker({ Title = "Cor da Hitbox", Default = Color3.fromRGB(255, 0, 0), Transparency = 0, Locked = false, Flag = "HitboxColorPicker", Callback = function(color) getgenv().hitbox_color = color end })
Main:Space()
getgenv().original_cooldowns = {}
Main:Toggle({
    Title = "Remover Cooldown da Arma",
    Desc = "Zera o tempo de espera entre os tiros. Pode precisar reequipar a arma.",
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
                        if getgenv().original_cooldowns[tool] == nil then getgenv().original_cooldowns[tool] = tool:GetAttribute("Cooldown") end
                        if tool:GetAttribute("Cooldown") ~= 0 then tool:SetAttribute("Cooldown", 0) end
                    end
                end
            end)
        else
            for tool, cooldown in pairs(getgenv().original_cooldowns) do
                if tool and tool.Parent then tool:SetAttribute("Cooldown", cooldown) end
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
    Title = "ESP Corpo Inteiro",
    Desc = "Destaca o corpo inteiro dos jogadores.",
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
    Title = "ESP Esqueleto",
    Desc = "Mostra os ossos e articulações dos inimigos.",
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
    Title = "ESP Tracers",
    Desc = "Desenha linhas do seu personagem até os inimigos.",
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
Esp:Colorpicker({ Title = "Cor do Time", Desc = "Cor do ESP para aliados.", Default = Color3.fromRGB(0, 255, 0), Transparency = 0, Locked = false, Flag = "EspTeamColorPicker", Callback = function(color) getgenv().esp_team_color = color end })
Esp:Colorpicker({ Title = "Cor do Inimigo", Desc = "Cor do ESP para inimigos.", Default = Color3.fromRGB(255, 0, 0), Transparency = 0, Locked = false, Flag = "EspEnemyColorPicker", Callback = function(color) getgenv().esp_enemy_color = color end })

local Killing = window:Tab({ Title = "Kill All", Icon = "skull", Locked = false })
getgenv().autoKillGun = false
Killing:Button({
    Title = "[ARMA] Matar todos (Uma vez)",
    Desc = "Mata todos os jogadores do servidor uma vez.",
    Locked = false,
    Callback = function()
        if getgenv().match then
            local myMatch = Player:GetAttribute("Match")
            if myMatch then
                equipGun()
                wind:Notify({ Title = "Matança Iniciada", Content = "Eliminando todos com a arma.", Duration = 3, Icon = "rbxassetid://114305907211721" })
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
    Title = "[ARMA] Matar todos (Auto)",
    Desc = "Fica eliminando todos os jogadores sem parar usando a arma.",
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
    Title = "[FACA] Matar todos (Uma vez)",
    Desc = "Mata todos os jogadores do servidor uma vez.",
    Locked = false,
    Callback = function()
        if getgenv().match then
            local myMatch = Player:GetAttribute("Match")
            if myMatch then
                equipKnife()
                wind:Notify({ Title = "Matança Iniciada", Content = "Eliminando todos com a faca.", Duration = 3, Icon = "rbxassetid://114305907211721" })
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
    Title = "[FACA] Matar todos (Auto)",
    Desc = "Fica eliminando todos os jogadores sem parar usando a faca.",
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
Ability:Toggle({ Title = "Cegar Todos (Auto)", Desc = "Cega automaticamente todos os inimigos da partida.", Value = false, Callback = function(state) getgenv().autoShroud = state end })
Ability:Toggle({ Title = "Modo Leve (Anti-Lag)", Desc = "Funciona em qualquer executor. Pode não mostrar o efeito, mas cega e salva FPS.", Value = false, Callback = function(state) getgenv().lowExecutorsShroud = state end })
Ability:Slider({ Title = "Qtd. de Cegueira por Inimigo", Desc = "Ajusta a taxa de disparo. Valores altos podem causar lag.", Step = 0.1, Value = { Min = 1, Max = 10000, Default = 1 }, Callback = function(value) getgenv().shroudRate = value end })
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
Ability:Toggle({ Title = "Remover Cooldown do Sprint", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.SprintCooldown = state and 0 or originals.SprintCooldown else NotSupportedFeature() end end })
Ability:Toggle({ Title = "Remover Cooldown do Dash", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.DashCooldown = state and 0 or originals.DashCooldown else NotSupportedFeature() end end })
Ability:Toggle({ Title = "Remover Cooldown do Shroud", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.ShroudCooldown = state and 0 or originals.ShroudCooldown else NotSupportedFeature() end end })
Ability:Toggle({ Title = "Remover Delay do Soul Reap", Locked = isLocked, Value = false, Callback = function(state) if state then FeatureActivated(true) else FeatureActivated(false) end; if not isLocked then Config.SoulReapCombatDelay = state and 0 or originals.SoulReapCombatDelay else NotSupportedFeature() end end })
Ability:Space()
Ability:Slider({ Title = "Tempo do Sprint", Step = 0.5, Locked = isLocked, Value = { Min = 0.5, Max = 10, Default = not isLocked and Config.SprintTime or 0 }, Callback = function(value) if not isLocked then Config.SprintTime = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Velocidade do Sprint", Step = 0.1, Locked = isLocked, Value = { Min = 0, Max = 5, Default = not isLocked and Config.SprintBoost or 0 }, Callback = function(value) if not isLocked then Config.SprintBoost = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Tempo do Soul Reap", Step = 0.5, Locked = isLocked, Value = { Min = 0.5, Max = 10, Default = not isLocked and Config.SoulReapTime }, Callback = function(value) if not isLocked then Config.SoulReapTime = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Velocidade do Soul Reap", Step = 0.1, Locked = isLocked, Value = { Min = 0.1, Max = 10, Default = not isLocked and Config.SoulReapSpeedBoost or 0 }, Callback = function(value) if not isLocked then Config.SoulReapSpeedBoost = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Impulso do Propeller", Step = 0.1, Locked = isLocked, Value = { Min = 0.1, Max = 5, Default = not isLocked and Config.PropellerJumpBoost or 0 }, Callback = function(value) if not isLocked then Config.PropellerJumpBoost = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Tempo do Shroud", Step = 0.5, Locked = isLocked, Value = { Min = 0.5, Max = 10, Default = not isLocked and Config.ShroudTime or 0 }, Callback = function(value) if not isLocked then Config.ShroudTime = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Velocidade do Projétil Shroud", Step = 2.5, Locked = isLocked, Value = { Min = 2.5, Max = 100, Default = not isLocked and Config.ShroudProjectileSpeed or 0 }, Callback = function(value) if not isLocked then Config.ShroudProjectileSpeed = value else NotSupportedFeature() end end })
Ability:Slider({ Title = "Alcance do Shroud", Step = 5, Locked = isLocked, Value = { Min = 5, Max = 1000, Default = not isLocked and Config.ShroudProjectileRange or 0 }, Callback = function(value) if not isLocked then Config.ShroudProjectileRange = value else NotSupportedFeature() end end })

local Teleport = window:Tab({ Title = "Teleport", Icon = "map-pin", Locked = false })
local lobby = workspace:WaitForChild("Lobby")
local groups = { DuelRing_1v1 = 1, DuelRing_2v2 = 2, DuelRing_3v3 = 3, DuelRing_4v4 = 4 }
local autoWalkToDuelPad = false
local currentPadModel = nil
local lastJumpTime = 0
local function walkTo(model)
    local character = Player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoid and rootPart and model and model.PrimaryPart then
        local targetPosition = model.PrimaryPart.Position
        local distance = (rootPart.Position - targetPosition).Magnitude
        if distance <= 6 then
            getgenv().noclip = false
            for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
            return
        end
        humanoid.WalkSpeed = 35
        humanoid:MoveTo(targetPosition)
        if os.clock() - lastJumpTime >= 2 then humanoid.Jump = true; lastJumpTime = os.clock() end
        getgenv().noclip = true
        for _, part in ipairs(character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
    end
end
Teleport:Toggle({ Title = "Andar Auto para Duelos", Desc = "Anda sozinho até uma arena de duelo disponível.", Default = false, Flag = "AutoWalkDuelPadToggle", Callback = function(value) autoWalkToDuelPad = value end })
Teleport:Space()
task.spawn(function()
    while true do
        if not Player:GetAttribute("Match") then
            if autoWalkToDuelPad then
                local character = Player.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                if currentPadModel and rootPart then
                    local currentMaxCount = 1
                    for groupName, maxCount in pairs(groups) do
                        if lobby:FindFirstChild("DuelRingsGroup") and lobby.DuelRingsGroup:FindFirstChild(groupName) then
                            if lobby.DuelRingsGroup[groupName]:FindFirstChild(currentPadModel.Name) then currentMaxCount = maxCount; break end
                        end
                    end
                    if currentMaxCount == 1 then
                        local opponentFound = false
                        for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
                            if otherPlayer ~= Player and otherPlayer.Character then
                                local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if otherRoot then
                                    local dist = (rootPart.Position - otherRoot.Position).Magnitude
                                    if dist <= 8 then opponentFound = true; break end
                                end
                            end
                        end
                        if not opponentFound then currentPadModel = nil end
                    end
                end
                if currentPadModel and rootPart then
                    local stillValid = false
                    for _, groupFolder in ipairs(lobby:GetChildren()) do
                        if groupFolder.Name == "DuelRingsGroup" then
                            for groupName, maxCount in pairs(groups) do
                                local ringFolder = groupFolder:FindFirstChild(groupName)
                                if ringFolder and ringFolder:FindFirstChild(currentPadModel.Name) then
                                    local totalPlayersInGroup = 0
                                    local maxPlayersForGroup = maxCount * 2
                                    local targetedPadStillNeedsPlayer = false
                                    for _, model in ipairs(ringFolder:GetChildren()) do
                                        if model:IsA("Model") and model.Name == "DuelPad" then
                                            local count = model:GetAttribute("CharacterCount") or 0
                                            totalPlayersInGroup = totalPlayersInGroup + count
                                            if model == currentPadModel and count < maxCount then targetedPadStillNeedsPlayer = true end
                                        end
                                    end
                                    if (totalPlayersInGroup == maxPlayersForGroup - 1 and targetedPadStillNeedsPlayer) or (totalPlayersInGroup == maxPlayersForGroup) then stillValid = true end
                                    break
                                end
                            end
                        end
                        if stillValid then break end
                    end
                    if not stillValid then currentPadModel = nil end
                end
                if not currentPadModel then
                    local foundNewPad = false
                    for _, groupFolder in ipairs(lobby:GetChildren()) do
                        if groupFolder.Name == "DuelRingsGroup" then
                            for groupName, maxCount in pairs(groups) do
                                local ringFolder = groupFolder:FindFirstChild(groupName)
                                if ringFolder then
                                    local pads = {}
                                    local totalPlayersInGroup = 0
                                    local maxPlayersForGroup = maxCount * 2
                                    for _, model in ipairs(ringFolder:GetChildren()) do
                                        if model:IsA("Model") and model.Name == "DuelPad" then
                                            local count = model:GetAttribute("CharacterCount") or 0
                                            totalPlayersInGroup = totalPlayersInGroup + count
                                            table.insert(pads, { model = model, count = count })
                                        end
                                    end
                                    if totalPlayersInGroup == maxPlayersForGroup - 1 then
                                        for _, pad in ipairs(pads) do
                                            if pad.count < maxCount then
                                                local opponentReady = true
                                                if maxCount == 1 then
                                                    opponentReady = false
                                                    for _, otherPlayer in ipairs(game:GetService("Players"):GetPlayers()) do
                                                        if otherPlayer ~= Player and otherPlayer.Character then
                                                            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                                                            if otherRoot and pad.model.PrimaryPart then
                                                                local dist = (otherRoot.Position - pad.model.PrimaryPart.Position).Magnitude
                                                                if dist <= 8 then opponentReady = true; break end
                                                            end
                                                        end
                                                    end
                                                end
                                                if opponentReady then
                                                    walkTo(pad.model)
                                                    if rootPart and pad.model.PrimaryPart then
                                                        local distance = (rootPart.Position - pad.model.PrimaryPart.Position).Magnitude
                                                        if distance <= 6 then currentPadModel = pad.model end
                                                    end
                                                    foundNewPad = true
                                                    task.wait(0.5)
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                                if foundNewPad then break end
                            end
                        end
                        if foundNewPad then break end
                    end
                end
            else
                currentPadModel = nil
            end
        else
            currentPadModel = nil
        end
        task.wait(0.2)
    end
end)
if lobby and lobby:FindFirstChild("DuelRingsGroup") then
    for groupName, _ in pairs(groups) do
        local ringFolder = lobby.DuelRingsGroup:FindFirstChild(groupName)
        if ringFolder then
            local padIndex = 1
            for _, model in ipairs(ringFolder:GetChildren()) do
                if model:IsA("Model") and model.Name == "DuelPad" then
                    local sideName = (padIndex % 2 == 1) and "Direita" or "Esquerda"
                    local cleanTitle = "Ir para " .. groupName .. " " .. sideName
                    Teleport:Button({
                        Title = cleanTitle,
                        Locked = false,
                        Callback = function()
                            wind:Notify({ Title = "Indo para o local", Content = "Movendo até a arena de duelo.", Duration = 3, Icon = "rbxassetid://114305907211721" })
                            walkTo(model)
                        end
                    })
                    padIndex = padIndex + 1
                end
            end
        end
    end
end

local fov = window:Tab({ Title = "FOV Shooting", Icon = "crosshair", Locked = false })
local fov_autoshoot_enabled = false
local fov_manualShoot_enabled = false
local fov_circle_enabled = false
local fov_radius = 100
local fov_shoot_cooldown = 1
local fov_last_shot = 0
local fov_circle = nil
local fov_gunController = nil
local fov_autoshoot_toggle = nil
local fov_manual_toggle = nil
local function createFovCircle()
    if fov_circle then fov_circle:Remove() end
    fov_circle = Drawing.new("Circle")
    fov_circle.Thickness = 2
    fov_circle.NumSides = 64
    fov_circle.Radius = fov_radius
    fov_circle.Color = Color3.fromRGB(255, 255, 255)
    fov_circle.Transparency = 1
    fov_circle.Visible = false
    fov_circle.Filled = false
end
createFovCircle()
local function update_fov_circle()
    if fov_circle and (fov_circle_enabled or fov_autoshoot_enabled or fov_manualShoot_enabled) then
        local screen_center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        fov_circle.Position = screen_center
        fov_circle.Radius = fov_radius
        fov_circle.Visible = true
    elseif fov_circle then
        fov_circle.Visible = false
    end
end
local function is_in_fov(target_position)
    local screen_pos, on_screen = Camera:WorldToViewportPoint(target_position)
    if not on_screen then return false end
    local screen_center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local distance = math.sqrt((screen_pos.X - screen_center.X) ^ 2 + (screen_pos.Y - screen_center.Y) ^ 2)
    return distance <= fov_radius
end
local function has_clear_los(from_pos, to_pos, target_character)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { Player.Character, target_character }
    params.FilterType = Enum.RaycastFilterType.Exclude
    local result = Workspace:Raycast(from_pos, (to_pos - from_pos), params)
    if result then if not result.Instance:IsDescendantOf(target_character) then return false end end
    return true
end
local function valid_enemy(enemy)
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
local function shoot_enemy(target)
    local my_char = Player.Character
    local my_root = my_char and my_char:FindFirstChild("HumanoidRootPart")
    local target_hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not (my_root and target_hrp) then return false end
    if not has_clear_los(my_root.Position, target_hrp.Position, target.Character) then return false end
    if not is_in_fov(target_hrp.Position) then return false end
        local current_time = tick()
    if current_time - fov_last_shot < fov_shoot_cooldown then return false end
    local hit_part = target.Character:FindFirstChild("LowerTorso") or target.Character:FindFirstChild("UpperTorso") or target.Character:FindFirstChild("Head")
    if hit_part then
        ShootGun(target)
        fov_last_shot = current_time
        return true
    end
    return false
end
RunService.Heartbeat:Connect(function()
    update_fov_circle()
    if not fov_autoshoot_enabled then return end
    local my_char = Player.Character
    if not my_char then return end
    for _, enemy in pairs(Players:GetPlayers()) do
        if valid_enemy(enemy) then
            if shoot_enemy(enemy) then break end
        end
    end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if fov_manualShoot_enabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        local current_time = tick()
        if current_time - fov_last_shot < fov_shoot_cooldown then return end
        local my_char = Player.Character
        if not my_char then return end
        for _, enemy in pairs(Players:GetPlayers()) do
            if valid_enemy(enemy) then
                if shoot_enemy(enemy) then break end
            end
        end
    end
end)
local function start_gun_controller_loop()
    if fov_gunController then task.cancel(fov_gunController) end
    fov_gunController = task.spawn(function()
        while fov_manualShoot_enabled do
            task.wait()
            local gun_controller = Workspace:FindFirstChild(Player.Name)
            if gun_controller then
                local controller = gun_controller:FindFirstChild("GunController")
                if controller then controller.Parent = nil end
            end
        end
    end)
end
local function stop_gun_controller_loop()
    if fov_gunController then task.cancel(fov_gunController); fov_gunController = nil end
end
fov:Toggle({ Title = "Mostrar Círculo FOV", Desc = "Mostra o círculo do FOV na tela.", Default = false, Flag = "EnableFovCircle", Callback = function(value) fov_circle_enabled = value end })
fov_autoshoot_toggle = fov:Toggle({ Title = "Autoshoot FOV", Desc = "Atira automaticamente em quem estiver no círculo.", Default = false, Flag = "EnableAutoshootFov", Callback = function(value) fov_autoshoot_enabled = value; if value then if fov_manual_toggle then fov_manual_toggle:Lock() end else if fov_manual_toggle then fov_manual_toggle:Unlock() end end end })
fov_manual_toggle = fov:Toggle({ Title = "Tiro Manual FOV", Desc = "Clique na tela para acertar quem está no círculo.", Default = false, Flag = "EnableManualShootToggle", Callback = function(value) fov_manualShoot_enabled = value; if value then if fov_autoshoot_toggle then fov_autoshoot_toggle:Lock() end; start_gun_controller_loop() else if fov_autoshoot_toggle then fov_autoshoot_toggle:Unlock() end; stop_gun_controller_loop() end end })
fov:Slider({ Title = "Tamanho do FOV", Step = 5, Flag = "FovCircleSizeSlider", Value = { Min = 35, Max = 300, Default = 100 }, Callback = function(value) fov_radius = value end })
fov:Slider({ Title = "Cooldown do FOV", Step = 0.1, Flag = "FovAutoshootCooldownSlider", Value = { Min = 0, Max = 5, Default = 2 }, Callback = function(value) fov_shoot_cooldown = value end })

local Misc = window:Tab({ Title = "Misc", Icon = "folder", Locked = false })
getgenv().original_speed = 16
getgenv().speed_enabled = false
getgenv().current_speed = 16
getgenv().remove_gun_cooldown = false
Misc:Toggle({ Title = "Auto Girar Roleta", Desc = "Gira a roleta automaticamente quando você não está em partida.", Default = false, Callback = function(state) getgenv().autoSpin = state; task.spawn(function() while getgenv().autoSpin do if not Player:GetAttribute("Match") then local SpinnerService = require(game:GetService("ReplicatedStorage").Dailies.SpinnerService); SpinnerService.Spin() end; task.wait(0.1) end end) end })
Misc:Toggle({ Title = "Noclip", Desc = "Permite atravessar paredes e obstáculos.", Default = false, Callback = function(state) getgenv().noclip = state; if state then FeatureActivated(true); local noclipLoop; noclipLoop = game:GetService("RunService").Stepped:Connect(function() if not getgenv().noclip then noclipLoop:Disconnect(); return end; local char = Player.Character; if char then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end) else FeatureActivated(false) end end })
Misc:Toggle({ Title = "Mudar Velocidade", Desc = "Aumenta ou diminui a velocidade do personagem.", Icon = "check", Default = false, Flag = "SpeedChangerToggle", Callback = function(Value) getgenv().speed_enabled = Value; if Value then task.spawn(function() while getgenv().speed_enabled do local character = Player.Character; local humanoid = character and character:FindFirstChild("Humanoid"); if humanoid and humanoid.WalkSpeed ~= getgenv().current_speed then humanoid.WalkSpeed = getgenv().current_speed end; task.wait(0.1) end end) else local character = Player.Character; local humanoid = character and character:FindFirstChild("Humanoid"); if humanoid then humanoid.WalkSpeed = getgenv().original_speed end end end })
Misc:Slider({ Title = "Velocidade de Caminhada", Step = 1, Value = { Min = 16, Max = 200, Default = 16 }, Flag = "SpeedChangerSlider", Callback = function(speed) getgenv().current_speed = speed; if getgenv().speed_enabled then local character = Player.Character; local humanoid = character and character:FindFirstChild("Humanoid"); if humanoid then humanoid.WalkSpeed = speed end end end })
Player.CharacterAdded:Connect(function(character) task.wait(0.2); if getgenv().speed_enabled then local humanoid = character:WaitForChild("Humanoid"); humanoid.WalkSpeed = getgenv().current_speed end end)

local Settings = window:Tab({ Title = "Settings", Icon = "settings", Locked = false })
local themeNames = {}
for name in pairs(wind.Themes) do table.insert(themeNames, name) end
table.sort(themeNames)
Settings:Dropdown({ Title = "Temas", Desc = "Selecione o tema do menu.", Flag = "SelectedTheme", Values = themeNames, Value = "Dark", Callback = function(option) wind:SetTheme(option) end })
Settings:Keybind({ Title = "Atalho do Menu", Desc = "Tecla para abrir a interface.", Value = "LeftControl", Flag = "KeybindOpenWindow", Callback = function(v) window:SetToggleKey(Enum.KeyCode[v]) end })
Settings:Space()
local ConfigManager = window.ConfigManager
local CurrentConfigName = "default"
local ConfigNameInput = Settings:Input({ Title = "Nome da Config", Value = CurrentConfigName, Callback = function(value) CurrentConfigName = value end })
local ConfigDropdown = Settings:Dropdown({ Title = "Todas as Configs", Values = ConfigManager:AllConfigs(), Callback = function(value) CurrentConfigName = value; ConfigNameInput:Set(value) end })
Settings:Button({ Title = "Salvar Config", Callback = function() local config = ConfigManager:CreateConfig(CurrentConfigName); if config:Save() then ConfigDropdown:Refresh(ConfigManager:AllConfigs()) end end })
Settings:Button({ Title = "Carregar Config", Callback = function() local config = ConfigManager:CreateConfig(CurrentConfigName); if config:Load() then end end })
Settings:Button({ Title = "Deletar Config", Callback = function() local config = ConfigManager:CreateConfig(CurrentConfigName); config:Delete(); ConfigDropdown:Refresh(ConfigManager:AllConfigs()) end })
wind:Notify({ Title = "BEM-VINDO À APEX | MVSD", Duration = 15, Icon = "rbxassetid://114305907211721" })
