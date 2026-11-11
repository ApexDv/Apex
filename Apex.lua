-- Carrega a Wind UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local lp = Players.LocalPlayer

-- Módulo de Fling da Source Original
local Module = loadstring(game:HttpGet("https://raw.smokingscripts.org/module"))()

-- Cria a Janela Principal no Wind UI
local Window = WindUI:CreateWindow({
    Title = "APEX HUB | MM2",
    Icon = "rbxassetid://10734934585",
    Author = "Apex + Vertex",
    Folder = "APEX_MM2",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false,
})

-- ==========================================
-- VARIÁVEIS E LÓGICA DA SOURCE ORIGINAL
-- ==========================================
local CurrentTween = nil
local ActiveChams = {}
local SilentAimConnection = nil
local AntiFlingConnection = nil
local UnboxConnection = nil
local TargetPlayerName = nil
local LastSafePosition = nil
local SafePositionTime = nil
local InvisActive = false

local function EquipTool(toolName)
    local character = lp.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local tool = lp.Backpack:FindFirstChild(toolName)
    if humanoid and tool then humanoid:EquipTool(tool) end
end

local function GetMapContainer(containerType)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and not string.find(string.lower(obj.Name), "lobby") then
            local coinContainer = obj:FindFirstChild("CoinContainer")
            local spawns = obj:FindFirstChild("Spawns")
            if containerType == "CoinContainer" and coinContainer then return coinContainer end
            if containerType == "Spawns" and spawns then return spawns end
        end
    end
    return nil
end

local function GetGunDrop()
    local spawns = GetMapContainer("Spawns")
    if spawns and spawns.Parent then return spawns.Parent:FindFirstChild("GunDrop") end
    return nil
end

local function FindPlayerHolding(toolName)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            if player.Backpack:FindFirstChild(toolName) or (player.Character and player.Character:FindFirstChild(toolName)) then
                return player.Name
            end
        end
    end
    return nil
end

local function IsPlayerAlive(player)
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function SetCharacterPhysics(speed, jump)
    local character = lp.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if humanoid then
        if speed then humanoid.WalkSpeed = speed end
        if jump then humanoid.JumpPower = jump end
    end
end

local function MoveToCFrame(targetCFrame, speed, easingStyle, waitForArrival, coinObj)
    local character = lp.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if CurrentTween then CurrentTween:Cancel() end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = math.clamp(distance / (speed or 21), 0.15, 5)
    local tweenInfo = TweenInfo.new(duration, easingStyle and Enum.EasingStyle.Quad or Enum.EasingStyle.Linear, easingStyle and Enum.EasingDirection.Out or Enum.EasingDirection.In)
    CurrentTween = TweenService:Create(root, tweenInfo, { CFrame = targetCFrame })
    CurrentTween:Play()
    if waitForArrival then
        while task.wait() do
            if not coinObj or not coinObj:GetAttribute("Collected") then
                if not IsPlayerAlive(lp) then break end
            else break end
        end
    end
end

local function ShootMurderer()
    local murdererName = FindPlayerHolding("Knife")
    local gun = lp.Backpack:FindFirstChild("Gun") or (lp.Character and lp.Character:FindFirstChild("Gun"))
    if not gun or not murdererName then return end
    local targetPlayer = Players:FindFirstChild(murdererName)
    local targetChar = targetPlayer and targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        EquipTool("Gun")
        if gun:FindFirstChild("Shoot") then gun.Shoot:FireServer("Shoot", targetRoot.CFrame) end
    end
end

local function HasLineOfSight(targetPlayer)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local targetChar = targetPlayer and targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return false end
    local rayDirection = (targetRoot.Position - root.Position).Unit * 50
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = { char }
    local result = Workspace:Raycast(root.Position, rayDirection, rayParams)
    return not result or (result.Instance and result.Instance.Parent == targetChar)
end

local function GetNextCoin(mode)
    local container = GetMapContainer("CoinContainer")
    if not container then return nil end
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    
    local murdererName = FindPlayerHolding("Knife")
    local murdererRoot = murdererName and Players:FindFirstChild(murdererName).Character and Players:FindFirstChild(murdererName).Character:FindFirstChild("HumanoidRootPart")
    local murdererPos = murdererRoot and murdererRoot.Position

    local closeCoins, safeCoins, nearestCoin = {}, {}, nil
    local shortestDist = math.huge

    for _, coin in ipairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:FindFirstChild("TouchInterest") and not coin:GetAttribute("Collected") then
            local coinVisual = coin:FindFirstChild("CoinVisual")
            if coinVisual then
                local distToPlayer = (root.Position - coinVisual.Position).Magnitude
                local distToMurderer = murdererPos and (coinVisual.Position - murdererPos).Magnitude or math.huge
                if distToPlayer < shortestDist then shortestDist = distToPlayer; nearestCoin = coin end
                if distToMurderer >= 25 then table.insert(safeCoins, coin) end
                if distToPlayer <= 50 then table.insert(closeCoins, coin) end
            end
        end
    end
    if mode == "closest" then return nearestCoin
    elseif mode == "random" then
        if #closeCoins > 0 then return closeCoins[math.random(1, #closeCoins)]
        elseif #safeCoins > 0 then return safeCoins[math.random(1, #safeCoins)] end
    end
    return nearestCoin
end

local function CollectCoin(coin)
    if not coin or not coin:FindFirstChild("CoinVisual") then return end
    local coinPos = coin.CoinVisual.Position
    local targetCF = CFrame.new(coinPos.X, coinPos.Y + 1.5, coinPos.Z)
    MoveToCFrame(targetCF, 21, true, true, coin)
end

local function UpdatePlayerChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp then
            local char = player.Character
            if char then
                local highlight = char:FindFirstChild("Highlight") or Instance.new("Highlight", char)
                ActiveChams[player] = highlight
                if player.Character:FindFirstChild("Knife") or (player.Backpack and player.Backpack:FindFirstChild("Knife")) then
                    highlight.FillColor = Color3.fromRGB(225, 0, 0)
                elseif player.Character:FindFirstChild("Gun") or (player.Backpack and player.Backpack:FindFirstChild("Gun")) then
                    highlight.FillColor = Color3.fromRGB(0, 0, 225)
                else
                    highlight.FillColor = Color3.fromRGB(76, 215, 134)
                end
            end
        end
    end
end

local function RemovePlayerChams()
    for player, highlight in pairs(ActiveChams) do if highlight then highlight:Destroy() end end
    table.clear(ActiveChams)
end

local function UpdateNameESP(player)
    if player == lp or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head or head:FindFirstChild("UsernameTag") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "UsernameTag"
    billboard.Adornee = head
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = head
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Text = player.Name
    label.TextSize = 20
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.5
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.SourceSansBold
end

local function RemoveNameESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local tag = head and head:FindFirstChild("UsernameTag")
            if tag then tag:Destroy() end
        end
    end
end

local function TeleportToLobby()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("Folder")) and string.find(string.lower(obj.Name), "lobby") then
            for _, desc in ipairs(obj:GetDescendants()) do
                if desc:IsA("SpawnLocation") then MoveToCFrame(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000); return end
            end
        end
    end
end

local function TeleportToMap()
    local spawns = GetMapContainer("Spawns")
    if spawns then
        for _, desc in ipairs(spawns:GetDescendants()) do
            if desc:IsA("BasePart") then MoveToCFrame(desc.CFrame * CFrame.new(0, 5, 0), 5000); return end
        end
    end
end

local function KillAll()
    EquipTool("Knife")
    local knife = lp.Backpack:FindFirstChild("Knife") or (lp.Character and lp.Character:FindFirstChild("Knife"))
    if not knife then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= lp and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot and knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched") then
                knife.Events.HandleTouched:FireServer(targetRoot)
            end
        end
    end
end

-- ==========================================
-- CRIAÇÃO DAS ABAS E BOTÕES NA WIND UI
-- ==========================================

-- ABA 1: FARM
local FarmTab = Window:Tab({ Title = "Main / Farm", Icon = "home" })
local isAutoFarm = false
local farmMode = "Nearest"

FarmTab:Dropdown({
    Title = "Farm Mode",
    Values = { "Nearest", "Randomize" },
    Default = "Nearest",
    Callback = function(val) farmMode = val end
})

FarmTab:Toggle({
    Title = "AutoFarm de Moedas",
    Default = false,
    Callback = function(state)
        isAutoFarm = state
        task.spawn(function()
            while isAutoFarm do
                task.wait()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and IsPlayerAlive(lp) then
                    local targetCoin = GetNextCoin(farmMode == "Randomize" and "random" or "closest")
                    if targetCoin then CollectCoin(targetCoin) end
                end
            end
        end)
    end
})

FarmTab:Toggle({
    Title = "Auto Grab (Puxar Arma)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local gunDrop = GetGunDrop()
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local sheriffName = FindPlayerHolding("Gun")
                if gunDrop and root and sheriffName ~= lp.Name then gunDrop.CFrame = root.CFrame end
            end
        end)
    end
})

FarmTab:Toggle({
    Title = "Dodge Knife (Desviar Faca)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj.Name == "ThrowingKnife" and obj:FindFirstChild("BladePosition") then
                            if (obj.Position - root.Position).Magnitude <= 15 then
                                local origPos = root.Position
                                root.CFrame = CFrame.new(origPos.X, origPos.Y + 100, origPos.Z)
                                task.wait(0.2); root.CFrame = CFrame.new(origPos)
                            end
                        end
                    end
                end
            end
        end)
    end
})

FarmTab:Button({ Title = "Ir para o Mapa", Callback = TeleportToMap })
FarmTab:Button({ Title = "Ir para o Lobby", Callback = TeleportToLobby })
FarmTab:Button({ Title = "Auto End Round (Fling)", Callback = function()
    local murdererName = FindPlayerHolding("Knife")
    local murdererPlayer = murdererName and Players:FindFirstChild(murdererName)
    if murdererPlayer and not IsPlayerAlive(lp) then Module:fling(murdererPlayer) end
end})

-- ABA 2: TARGET (FLING)
local TargetTab = Window:Tab({ Title = "Target", Icon = "crosshair" })
local targetList = {}
for _, p in ipairs(Players:GetPlayers()) do if p ~= lp then table.insert(targetList, p.Name) end end

TargetTab:Dropdown({
    Title = "Escolher Alvo",
    Values = targetList,
    Default = "",
    Callback = function(val) TargetPlayerName = val end
})

TargetTab:Toggle({
    Title = "Fling Alvo",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local target = TargetPlayerName and Players:FindFirstChild(TargetPlayerName)
                if target then Module:fling(target); task.wait(3) end
            end
        end)
    end
})

TargetTab:Toggle({
    Title = "Spectate (Assistir)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local target = TargetPlayerName and Players:FindFirstChild(TargetPlayerName)
                local head = target and target.Character and target.Character:FindFirstChild("Head")
                if head then Workspace.CurrentCamera.CameraSubject = head end
            end
            local myHumanoid = lp.Character and lp.Character:FindFirstChild("Humanoid")
            if myHumanoid then Workspace.CurrentCamera.CameraSubject = myHumanoid end
        end)
    end
})

TargetTab:Toggle({
    Title = "Loop Go To (Ir até)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local target = TargetPlayerName and Players:FindFirstChild(TargetPlayerName)
                local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                if myRoot and targetRoot then myRoot.CFrame = targetRoot.CFrame end
            end
        end)
    end
})

TargetTab:Button({ Title = "Teleportar até Alvo", Callback = function()
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    local target = TargetPlayerName and Players:FindFirstChild(TargetPlayerName)
    local targetRoot = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if myRoot and targetRoot then myRoot.CFrame = targetRoot.CFrame end
end})

TargetTab:Toggle({ Title = "Fling Sheriff", Default = false, Callback = function(state)
    task.spawn(function() while state do task.wait(); local sName = FindPlayerHolding("Gun"); if sName and sName ~= lp.Name then Module:fling(Players:FindFirstChild(sName)); task.wait(3) end end end)
end})

TargetTab:Toggle({ Title = "Fling Murderer", Default = false, Callback = function(state)
    task.spawn(function() while state do task.wait(); local mName = FindPlayerHolding("Knife"); if mName and mName ~= lp.Name then Module:fling(Players:FindFirstChild(mName)); task.wait(3) end end end)
end})

-- ABA 3: ROLES (ASSASSINO E XERIFE)
local RolesTab = Window:Tab({ Title = "Roles", Icon = "swords" })
local auraDist = 15

RolesTab:Toggle({
    Title = "Silent Aim (Xerife)",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                while state do
                    task.wait()
                    local gun = lp.Character and lp.Character:FindFirstChild("Gun")
                    if gun and FindPlayerHolding("Gun") == lp.Name and not SilentAimConnection then
                        SilentAimConnection = gun.Activated:Connect(function()
                            local mName = FindPlayerHolding("Knife")
                            local mPlayer = mName and Players:FindFirstChild(mName)
                            local mRoot = mPlayer and mPlayer.Character and mPlayer.Character:FindFirstChild("HumanoidRootPart")
                            if mRoot and gun:FindFirstChild("Shoot") then gun.Shoot:FireServer("Shoot", mRoot.CFrame) end
                        end)
                    elseif not gun and SilentAimConnection then SilentAimConnection:Disconnect(); SilentAimConnection = nil end
                    if not state and SilentAimConnection then SilentAimConnection:Disconnect(); SilentAimConnection = nil; break end
                end
            end)
        end
    end
})

RolesTab:Toggle({
    Title = "Auto Shoot Murderer (Xerife)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local mName = FindPlayerHolding("Knife")
                local mPlayer = mName and Players:FindFirstChild(mName)
                if mPlayer and FindPlayerHolding("Gun") == lp.Name and HasLineOfSight(mPlayer) then
                    EquipTool("Gun"); ShootMurderer()
                end
            end
        end)
    end
})

RolesTab:Slider({
    Title = "Distância da Aura",
    Value = { Min = 5, Max = 50, Default = 15 },
    Callback = function(val) auraDist = val end
})

RolesTab:Toggle({
    Title = "Kill Aura (Assassino)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do
                task.wait()
                local char = lp.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and FindPlayerHolding("Knife") == lp.Name then
                    EquipTool("Knife")
                    local knife = char:FindFirstChild("Knife")
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= lp and player.Character and IsPlayerAlive(player) then
                            local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                                                        if tRoot and (tRoot.Position - root.Position).Magnitude <= auraDist then
                                if knife and knife:FindFirstChild("Events") then knife.Events.HandleTouched:FireServer(tRoot) end
                            end
                        end
                    end
                end
            end
        end)
    end
})

RolesTab:Toggle({
    Title = "Kill All (Assassino)",
    Default = false,
    Callback = function(state)
        task.spawn(function() while state do task.wait(); if FindPlayerHolding("Knife") == lp.Name then KillAll() end end end)
    end
})

-- ABA 4: VISUAL (CHAMS E ESP)
local VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" })

VisualTab:Toggle({
    Title = "Player Chams (ESP)",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do task.wait(); UpdatePlayerChams() end
            RemovePlayerChams()
        end)
    end
})

VisualTab:Toggle({
    Title = "Name ESP",
    Default = false,
    Callback = function(state)
        task.spawn(function()
            while state do task.wait(); for _, p in ipairs(Players:GetPlayers()) do UpdateNameESP(p) end end
            RemoveNameESP()
        end)
    end
})

VisualTab:Toggle({
    Title = "Desligar Renderização (FPS Boost)",
    Default = false,
    Callback = function(state) RunService:Set3dRenderingEnabled(not state) end
})

VisualTab:Toggle({
    Title = "Unbox Notification",
    Default = false,
    Callback = function(state)
        if state then
            local unboxEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Shop"):WaitForChild("Unbox")
            UnboxConnection = unboxEvent.OnClientEvent:Connect(function(item)
                WindUI:Notify({ Title = "Unbox", Content = "Você tirou: "..tostring(item), Duration = 5 })
            end)
        else
            if UnboxConnection then UnboxConnection:Disconnect(); UnboxConnection = nil end
        end
    end
})

-- ABA 5: PLAYER (FÍSICA E ANTI-FLING)
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local speedVal, jumpVal = 16, 50

PlayerTab:Toggle({ Title = "WalkSpeed", Default = false, Callback = function(s)
    task.spawn(function() while s do task.wait(); SetCharacterPhysics(speedVal, nil) end; SetCharacterPhysics(16, nil) end)
end})
PlayerTab:Slider({ Title = "Velocidade", Value = { Min = 16, Max = 200, Default = 16 }, Callback = function(v) speedVal = v end })

PlayerTab:Toggle({ Title = "JumpPower", Default = false, Callback = function(s)
    task.spawn(function() while s do task.wait(); SetCharacterPhysics(nil, jumpVal) end; SetCharacterPhysics(nil, 50) end)
end})
PlayerTab:Slider({ Title = "Força do Pulo", Value = { Min = 50, Max = 200, Default = 50 }, Callback = function(v) jumpVal = v end })

PlayerTab:Toggle({
    Title = "Anti Fling",
    Default = false,
    Callback = function(state)
        if state then
            AntiFlingConnection = RunService.Stepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Character then
                        for _, part in ipairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                    end
                end
            end)
        else
            if AntiFlingConnection then AntiFlingConnection:Disconnect(); AntiFlingConnection = nil end
        end
    end
})

PlayerTab:Toggle({
    Title = "Invisibilidade (Invis Chair)",
    Default = false,
    Callback = function(state)
        InvisActive = state
        if not InvisActive then
            local chair = Workspace:FindFirstChild("invischair")
            if chair then chair:Destroy() end
        else
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local seat = Instance.new("Seat", Workspace)
                seat.Anchored, seat.CanCollide, seat.Name, seat.Transparency = false, false, "invischair", 1
                seat.Position = Vector3.new(-25.95, 84, 3537.55)
                local weld = Instance.new("Weld", seat)
                weld.Part0, weld.Part1 = seat, root
            end
        end
    end
})

-- ABA 6: WEBHOOK
local WebhookTab = Window:Tab({ Title = "Webhook", Icon = "link" })
local webhookUrl = ""

WebhookTab:Input({
    Title = "URL do Webhook",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(text) webhookUrl = text end
})

WebhookTab:Button({
    Title = "Enviar Teste pro Discord",
    Callback = function()
        if webhookUrl == "" then return end
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        if req then
            req({
                Url = webhookUrl, Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode({ content = "APEX HUB MM2 - Webhook Conectado com Sucesso!" })
            })
            WindUI:Notify({ Title = "Webhook", Content = "Mensagem enviada!", Duration = 3 })
        end
    end
})

-- ABA 7: SEGURANÇA (ANTI-TRADE DA SOURCE)
local TradeFolder = ReplicatedStorage:WaitForChild("Trade")
local DeclineTrade = TradeFolder:WaitForChild("DeclineTrade")
local UpdateTrade = TradeFolder:WaitForChild("UpdateTrade")

DeclineTrade.AncestryChanged:Connect(function(_, parent)
    if not parent then lp:Kick("Security Alert:\nUnauthorized trade behavior detected.") end
end)

UpdateTrade.OnClientEvent:Connect(function()
    if not DeclineTrade.Parent then lp:Kick("Security Alert:\nUnauthorized trade behavior detected.") else
        DeclineTrade:FireServer()
        WindUI:Notify({ Title = "AVISO", Content = "Detectamos comércio suspeito. Declinei automaticamente.", Duration = 5 })
    end
end)

-- Loop de segurança (Safe position)
task.spawn(function()
    local destroyHeight = Workspace.FallenPartsDestroyHeight
    while task.wait(0.1) do
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local yPos = root.Position.Y
            if yPos < destroyHeight or yPos > 5000 then
                if not SafePositionTime then SafePositionTime = os.clock() end
                if os.clock() - SafePositionTime >= 5 and LastSafePosition then
                    root.CFrame = LastSafePosition + Vector3.new(0, 4, 0)
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                end
            else
                SafePositionTime = nil
                LastSafePosition = root.CFrame
            end
        end
    end
end)

-- Notificação de carregamento
WindUI:Notify({
    Title = "APEX HUB",
    Content = "Todas as funções do Vertex MM2 foram carregadas!",
    Duration = 5,
})
