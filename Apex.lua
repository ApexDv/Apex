local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local CONFIG = {
	Key = "apex", 
	Name = "APEX HUB",
	Blue = Color3.fromRGB(0, 140, 255),
	Cyan = Color3.fromRGB(0, 229, 255),
	Dark = Color3.fromRGB(8, 13, 26), 
	Field = Color3.fromRGB(13, 22, 44),
	Success = Color3.fromRGB(46, 204, 113),
	Error = Color3.fromRGB(255, 77, 94),
}

local function onSuccess()
    -- ABRE A WINDUI
    local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    local RunService = game:GetService("RunService")
    local Workspace = game:GetService("Workspace")
    local Camera = Workspace.CurrentCamera
    local LP = Players.LocalPlayer

    WindUI:AddTheme({
        Name = "Rose", Primary = Color3.fromHex("#ff4d6d"), White = Color3.new(1,1,1), Black = Color3.new(0,0,0), Dialog = Color3.fromHex("#1a0b12"), Background = Color3.fromHex("#14080e"), BackgroundTransparency = 0, Hover = Color3.fromHex("#FFFFFF"), PanelBackground = Color3.new(1,1,1), PanelBackgroundTransparency = .95, WindowBackground = Color3.fromHex("#14080e"), WindowShadow = Color3.new(0,0,0), WindowTopbarTitle = Color3.fromHex("#FFFFFF"), WindowTopbarAuthor = Color3.fromHex("#FFFFFF"), WindowTopbarIcon = Color3.fromHex("#ff4d6d"), WindowTopbarButtonIcon = Color3.fromHex("#ff4d6d"), WindowSearchBarBackground = Color3.fromHex("#14080e"), TabBackground = Color3.fromHex("#FFFFFF"), TabBackgroundHover = Color3.fromHex("#FFFFFF"), TabBackgroundHoverTransparency = .97, TabBackgroundActive = Color3.fromHex("#FFFFFF"), TabBackgroundActiveTransparency = 0.93, TabText = Color3.fromHex("#FFFFFF"), TabTextTransparency = 0.3, TabTextTransparencyActive = 0, TabTitle = Color3.fromHex("#FFFFFF"), TabIcon = Color3.fromHex("#ff4d6d"), TabIconTransparency = 0.4, TabIconTransparencyActive = 0.1, TabBorderTransparency = 1, TabBorderTransparencyActive = 0.75, TabBorder = Color3.fromHex("#ff4d6d"), ElementBackground = Color3.fromHex("#FFFFFF"), ElementBackgroundTransparency = .93, ElementBackgroundHover = WindUI.Creator:AddColor("ElementBackground", "#ffffff", 1/10), ElementTitle = Color3.fromHex("#FFFFFF"), ElementDesc = Color3.fromHex("#FFFFFF"), ElementIcon = Color3.fromHex("#ff4d6d"), PopupBackground = Color3.fromHex("#14080e"), PopupBackgroundTransparency = "BackgroundTransparency", PopupTitle = Color3.fromHex("#FFFFFF"), PopupContent = Color3.fromHex("#FFFFFF"), PopupIcon = Color3.fromHex("#ff4d6d"), DialogBackground = Color3.fromHex("#14080e"), DialogBackgroundTransparency = "BackgroundTransparency", DialogTitle = Color3.fromHex("#FFFFFF"), DialogContent = Color3.fromHex("#FFFFFF"), DialogIcon = Color3.fromHex("#ff4d6d"), Toggle = Color3.fromHex("#ff4d6d"), ToggleBar = Color3.new(1,1,1), Checkbox = Color3.fromHex("#ff4d6d"), CheckboxIcon = Color3.new(1,1,1), CheckboxBorder = Color3.new(1,1,1), CheckboxBorderTransparency = .75, SliderIcon = Color3.fromHex("#ff4d6d"), Slider = Color3.fromHex("#ff4d6d"), SliderThumb = Color3.new(1,1,1), SliderIconFrom = Color3.fromHex("#ff4d6d"), SliderIconTo = Color3.fromHex("#ff4d6d"), Tooltip = Color3.fromHex("4C4C4C"), TooltipText = Color3.new(1,1,1), TooltipSecondary = Color3.fromHex("#ff4d6d"), TooltipSecondaryText = Color3.new(1,1,1), TabSectionIcon = Color3.fromHex("#ff4d6d"), SectionIcon = Color3.fromHex("#ff4d6d"), SectionExpandIcon = Color3.new(1,1,1), SectionExpandIconTransparency = .4, SectionBox = Color3.new(1,1,1), SectionBoxTransparency = .95, SectionBoxBorder = Color3.new(1,1,1), SectionBoxBorderTransparency = .75, SectionBoxBackground = Color3.new(1,1,1), SectionBoxBackgroundTransparency = .95, SearchBarBorder = Color3.new(1,1,1), SearchBarBorderTransparency = .75, Notification = Color3.fromHex("#14080e"), NotificationTitle = Color3.fromHex("#FFFFFF"), NotificationTitleTransparency = 0, NotificationContent = Color3.fromHex("#FFFFFF"), NotificationContentTransparency = .4, NotificationDuration = Color3.new(1,1,1), NotificationDurationTransparency = .95, NotificationBorder = Color3.new(1,1,1), NotificationBorderTransparency = .75, DropdownTabBorder = Color3.new(1,1,1), LabelBackground = Color3.new(1,1,1), LabelBackgroundTransparency = .95,
    })

    local TriggerBotOn = false
    local ShootThroughWalls = false
    local FOV = 300
    local FireDelay = 0.1 
    local ChamsObjects = {}
    local lastShotTime = 0

    local Window = WindUI:CreateWindow({
        Title = "Apex | MVSD",
        Icon = "rbxassetid://1794099698676",
        Author = "",
        Folder = "ApexMVSD",
        Size = UDim2.fromOffset(450, 360),
        Theme = "Rose",
        Transparent = true
    })

    local TabCombat = Window:Tab({ Title = "Combat", Icon = "crosshair" })
    TabCombat:Section({ Title = "Trigger Bot" })
    TabCombat:Toggle({ Title = "Tiro Automático", Value = false, Callback = function(s) TriggerBotOn = s end })
    TabCombat:Toggle({ Title = "Atirar na Parede", Value = false, Callback = function(s) ShootThroughWalls = s end })
    TabCombat:Slider({ Title = "FOV", Value = { Min = 10, Max = 800, Default = 300 }, Callback = function(v) FOV = v end })
    TabCombat:Slider({ Title = "Velocidade", Value = { Min = 0.05, Max = 1, Default = 0.1 }, Callback = function(v) FireDelay = v end })

    local TabVisuals = Window:Tab({ Title = "Visuals", Icon = "eye" })
    TabVisuals:Section({ Title = "Player" })
    TabVisuals:Toggle({ Title = "ESP", Value = false, Callback = function(s) 
        if not s then
            for _, highlight in pairs(ChamsObjects) do if highlight then highlight:Destroy() end end
            ChamsObjects = {}
        end
        _G.ChamsOn = s 
    end })

    local TabConfig = Window:Tab({ Title = "Settings", Icon = "settings" })
    TabConfig:Section({ Title = "Sistema" })
    TabConfig:Button({
        Title = "Sair do Script",
        Icon = "log-out",
        Callback = function()
            for _, highlight in pairs(ChamsObjects) do if highlight then highlight:Destroy() end end
            ChamsObjects = {}
            _G.ChamsOn = false
            TriggerBotOn = false
            Window:Destroy()
        end
    })

    local TabSocial = Window:Tab({ Title = "Social", Icon = "users" })
    TabSocial:Section({ Title = "Discord" })
    TabSocial:Button({
        Title = "Copiar Link",
        Icon = "copy",
        IconAlign = "Left",
        Callback = function()
            setclipboard("https://discord.gg/9uQjBAAaP")
            WindUI:Notify({ Title = "Copiado!", Content = "Link copiado.", Duration = 3, Icon = "check" })
        end
    })

    -- LOOP DO TRIGGER BOT
    RunService.RenderStepped:Connect(function()
        if TriggerBotOn then
            if tick() - lastShotTime < FireDelay then return end
            
            local function GetTarget()
                local closest, minDist = nil, FOV
                local center = Camera.ViewportSize / 2
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local hum = p.Character:FindFirstChildOfClass("Humanoid")
                        local head = p.Character:FindFirstChild("Head")
                        if hum and hum.Health > 0 and head then
                            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                            if onScreen then
                                local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                                if dist < minDist then
                                    minDist = dist
                                    closest = head
                                end
                            end
                        end
                    end
                end
                return closest
            end

            local function HasLineOfSight(targetPart)
                local myChar = LP.Character
                if not myChar then return false end
                local myHead = myChar:FindFirstChild("Head")
                if not myHead then return false end
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {myChar, targetPart.Parent}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = Workspace:Raycast(myHead.Position, targetPart.Position - myHead.Position, raycastParams)
                return result == nil
            end
            
            local target = GetTarget()
            
            if target and LP.Character then
                local canShoot = true
                if not ShootThroughWalls then
                    canShoot = HasLineOfSight(target)
                end

                if canShoot then
                    local myHead = LP.Character:FindFirstChild("Head")
                    local Remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("ShootGun")
                    
                    local equippedTool = nil
                    for _, tool in pairs(LP.Character:GetChildren()) do
                        if tool:IsA("Tool") then equippedTool = tool break end
                    end

                    if Remote and myHead and equippedTool then
                        lastShotTime = tick()
                        pcall(function()
                            Remote:FireServer(table.unpack({
                                [1] = myHead.Position, 
                                [2] = target.Position, 
                                [3] = target, 
                                [4] = target.Position, 
                            }))
                            
                            local Events = game:GetService("ReplicatedStorage"):FindFirstChild("Events")
                            local RemoteEvents = Events and Events:FindFirstChild("RemoteEvents")
                            local GunBeam = RemoteEvents and RemoteEvents:FindFirstChild("GunBeam")
                            
                            if GunBeam and firesignal then
                                firesignal(GunBeam.OnClientEvent, table.unpack({
                                    [1] = equippedTool, 
                                    [2] = target.Position, 
                                    [3] = target 
                                }))
                            end

                            local PlaySound = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("PlaySound")
                            if PlaySound and firesignal then
                                firesignal(PlaySound.OnClientEvent)
                            end
                        end)
                    end
                end
            end
        end
    end)

    -- LOOP DOS CHAMS
    RunService.RenderStepped:Connect(function()
        if not _G.ChamsOn then
            for _, highlight in pairs(ChamsObjects) do
                if highlight then highlight:Destroy() end
            end
            ChamsObjects = {}
            return
        end

        for player, highlight in pairs(ChamsObjects) do
            if not player or not player.Parent or not player.Character or not player.Character:FindFirstChild("Humanoid") or player.Character.Humanoid.Health <= 0 then
                highlight:Destroy()
                ChamsObjects[player] = nil
            end
        end

        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                local char = p.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                
                if hum and root and hum.Health > 0 then
                    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    local distance = myRoot and (myRoot.Position - root.Position).Magnitude or 9999
                    
                    if distance < 1000 then 
                        if not ChamsObjects[p] then
                            local highlight = Instance.new("Highlight")
                            highlight.Parent = char
                            highlight.FillColor = Color3.fromRGB(0, 150, 255)
                            highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
                            highlight.FillTransparency = 0.3
                            highlight.OutlineTransparency = 0
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            ChamsObjects[p] = highlight
                        end
                    else
                        if ChamsObjects[p] then
                            ChamsObjects[p]:Destroy()
                            ChamsObjects[p] = nil
                        end
                    end
                end
            end
        end
    end)
end

if CoreGui:FindFirstChild("ApexHubKey") then CoreGui.ApexHubKey:Destroy() end

local function tween(obj, t, props, style, dir)
	local tw = TweenService:Create(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function corner(obj, r)
	return new("UICorner", {CornerRadius = UDim.new(0, r)}, obj)
end

local function blueGradient(parent, rot)
	return new("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, CONFIG.Blue),
			ColorSequenceKeypoint.new(0.5, CONFIG.Cyan),
			ColorSequenceKeypoint.new(1, CONFIG.Blue),
		}),
		Rotation = rot or 0,
	}, parent)
end

local gui = new("ScreenGui", {
	Name = "ApexHubKey", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
if not okParent or not gui.Parent then
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
end

local blur = new("BlurEffect", {Size = 0}, Lighting)
tween(blur, 0.8, {Size = 18})

local dim = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = CONFIG.Dark, 
	BackgroundTransparency = 0.2, 
	BorderSizePixel = 0, ZIndex = 1,
}, gui)

local particlesLayer = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2,
}, gui)

local alive = true
task.spawn(function()
	while alive and particlesLayer.Parent do
		local s = math.random(3, 6)
		local dot = new("Frame", {
			Size = UDim2.fromOffset(s, s), 
			Position = UDim2.new(math.random(), 0, 1.1, 0), 
			BackgroundColor3 = CONFIG.Cyan, 
			BackgroundTransparency = math.random(2, 6) / 10, 
			BorderSizePixel = 0,
		}, particlesLayer)
		corner(dot, 10)
		
		local tw = tween(dot, math.random(4, 10), {
			Position = UDim2.new(dot.Position.X.Scale, math.random(-20, 20), -0.1, 0),
			BackgroundTransparency = 1,
		}, Enum.EasingStyle.Linear)
		
		tw.Completed:Connect(function() dot:Destroy() end)
		task.wait(0.15) 
	end
end)

local root = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(320, 270), BackgroundTransparency = 1, ZIndex = 3,
}, gui)
local scale = new("UIScale", {Scale = 0.6}, root)

local glow = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, 14, 1, 14), BackgroundTransparency = 1, ZIndex = 3,
}, root)
corner(glow, 24)
local glowStroke = new("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 7, Transparency = 0.82}, glow)
local glowGrad = blueGradient(glowStroke)

local main = new("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = CONFIG.Dark,
	BackgroundTransparency = 1,
	ClipsDescendants = true, BorderSizePixel = 0, ZIndex = 4,
}, root)
corner(main, 18)

local innerGlow = new("Frame", {
	Size = UDim2.fromScale(2, 2), 
	Position = UDim2.fromScale(-0.5, -0.5),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.8, 
	BorderSizePixel = 0, ZIndex = 4,
}, main)
local innerGrad = new("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, CONFIG.Dark),
		ColorSequenceKeypoint.new(0.5, CONFIG.Blue),
		ColorSequenceKeypoint.new(1, CONFIG.Dark),
	}),
	Rotation = 45,
}, innerGlow)
TweenService:Create(innerGrad, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 405}):Play()

local stroke = new("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2}, main)
local strokeGrad = blueGradient(stroke)
TweenService:Create(strokeGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()
TweenService:Create(glowGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360}):Play()

local content = new("CanvasGroup", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1, ZIndex = 5,
}, main)

local logo = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 22),
	Size = UDim2.fromOffset(46, 46), BackgroundColor3 = Color3.new(1, 1, 1),
}, content)
corner(logo, 13)
new("UIGradient", {Color = ColorSequence.new(CONFIG.Cyan, CONFIG.Blue), Rotation = 45}, logo)
new("UIStroke", {Color = CONFIG.Cyan, Thickness = 4, Transparency = 0.7}, logo)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
	Text = "A", TextSize = 26, TextColor3 = Color3.new(1, 1, 1),
}, logo)

TweenService:Create(logo, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	Size = UDim2.fromOffset(50, 50), Position = UDim2.new(0.5, 0, 0, 20),
}):Play()

new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 80), BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack, Text = CONFIG.Name, TextSize = 22, TextColor3 = Color3.new(1, 1, 1),
}, content)

new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 106), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, Text = "Digite sua key para continuar", TextSize = 13,
	TextColor3 = Color3.fromRGB(140, 160, 195),
}, content)

local field = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 142),
	Size = UDim2.new(0.86, 0, 0, 42), BackgroundColor3 = CONFIG.Field,
	BackgroundTransparency = 0.2,
}, content)
corner(field, 21)
local fieldStroke = new("UIStroke", {Color = Color3.fromRGB(0, 120, 220), Thickness = 1.5, Transparency = 0.2}, field)

local lock = new("Frame", {
	Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(18, 22), BackgroundTransparency = 1,
}, field)
local shackle = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.fromOffset(12, 14), BackgroundTransparency = 1,
}, lock)
corner(shackle, 6)
new("UIStroke", {Color = CONFIG.Cyan, Thickness = 2.2}, shackle)
local lockBody = new("Frame", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
	Size = UDim2.fromOffset(18, 13), BackgroundColor3 = CONFIG.Cyan, BorderSizePixel = 0,
}, lock)
corner(lockBody, 4)

local box = new("TextBox", {
	Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -52, 1, 0), BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium, PlaceholderText = "Cole ou digite a key",
	PlaceholderColor3 = Color3.fromRGB(100, 120, 155), Text = "", TextColor3 = Color3.new(1, 1, 1),
	TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
}, field)

local btn = new("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 196),
	Size = UDim2.new(0.86, 0, 0, 42), BackgroundColor3 = Color3.new(1, 1, 1),
	    Text = "", AutoButtonColor = false,
}, content)
corner(btn, 21)
local btnGrad = new("UIGradient", {Color = ColorSequence.new(CONFIG.Blue, CONFIG.Cyan), Rotation = 0}, btn)
new("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
	Text = "VERIFICAR", TextSize = 14, TextColor3 = Color3.new(1, 1, 1),
}, btn)

local status = new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 244), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, Text = "", TextSize = 12, TextColor3 = CONFIG.Error,
}, content)

btn.MouseEnter:Connect(function()
	tween(btnGrad, 0.3, {Rotation = 25})
	tween(btn, 0.15, {Size = UDim2.new(0.9, 0, 0, 44)})
end)
btn.MouseLeave:Connect(function()
	tween(btnGrad, 0.3, {Rotation = 0})
	tween(btn, 0.15, {Size = UDim2.new(0.86, 0, 0, 42)})
end)
btn.MouseButton1Down:Connect(function() tween(btn, 0.08, {Size = UDim2.new(0.82, 0, 0, 40)}) end)
btn.MouseButton1Up:Connect(function() tween(btn, 0.12, {Size = UDim2.new(0.86, 0, 0, 42)}) end)

box.Focused:Connect(function() tween(fieldStroke, 0.2, {Color = CONFIG.Cyan, Transparency = 0}) end)
box.FocusLost:Connect(function() tween(fieldStroke, 0.2, {Color = Color3.fromRGB(0, 120, 220), Transparency = 0.2}) end)

tween(scale, 0.7, {Scale = 1}, Enum.EasingStyle.Back)
task.delay(0.35, function() tween(content, 0.5, {GroupTransparency = 0}) end)

local function showApexScreen()
	local screen = new("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(3, 6, 14),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10,
	}, gui)
	tween(screen, 0.6, {BackgroundTransparency = 0})
	task.wait(0.7)

	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(500, 90), BackgroundTransparency = 1, ZIndex = 11,
	}, screen)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4),
	}, holder)

	local letters = {}
	for i = 1, #CONFIG.Name do
		local ch = CONFIG.Name:sub(i, i)
		local l = new("TextLabel", {
			Size = UDim2.fromOffset(ch == " " and 24 or 50, 80), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack, Text = ch, TextSize = 30, TextTransparency = 1,
			TextColor3 = (i <= 4) and CONFIG.Cyan or Color3.new(1, 1, 1), ZIndex = 12, LayoutOrder = i,
		}, holder)
		table.insert(letters, l)
	end

	for _, l in ipairs(letters) do
		tween(l, 0.4, {TextTransparency = 0, TextSize = 70}, Enum.EasingStyle.Back)
		task.wait(0.14)
	end

	local line = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 55),
		Size = UDim2.fromOffset(0, 3), BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0, ZIndex = 11,
	}, screen)
	corner(line, 2)
	blueGradient(line)
	tween(line, 0.9, {Size = UDim2.fromOffset(300, 3)}, Enum.EasingStyle.Quart)

	local loading = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 70),
		Size = UDim2.fromOffset(300, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		Text = "Carregando script...", TextSize = 13, TextColor3 = Color3.fromRGB(140, 160, 195),
		TextTransparency = 1, ZIndex = 11,
	}, screen)
	tween(loading, 0.6, {TextTransparency = 0})

	task.wait(2.2)

	for _, l in ipairs(letters) do tween(l, 0.5, {TextTransparency = 1}) end
	tween(line, 0.5, {BackgroundTransparency = 1})
	tween(loading, 0.5, {TextTransparency = 1})
	tween(screen, 0.8, {BackgroundTransparency = 1})
	tween(blur, 0.8, {Size = 0})
	task.wait(0.9)
	blur:Destroy()
	gui:Destroy()
	onSuccess()
end

local function playSuccess()
	alive = false
	tween(content, 0.3, {GroupTransparency = 1})
	tween(glowStroke, 0.3, {Transparency = 0.6})
	strokeGrad.Color = ColorSequence.new(CONFIG.Success)
	glowGrad.Color = ColorSequence.new(CONFIG.Success)
	task.wait(0.35)

	local circle = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(0, 0), BackgroundColor3 = CONFIG.Success, ZIndex = 6,
	}, main)
	corner(circle, 100)
	local check = new("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
		Text = "✓", TextColor3 = Color3.new(1, 1, 1), TextSize = 1, ZIndex = 7,
	}, circle)
	tween(circle, 0.5, {Size = UDim2.fromOffset(90, 90)}, Enum.EasingStyle.Back)
	tween(check, 0.5, {TextSize = 58}, Enum.EasingStyle.Back)
	task.wait(0.5)

	local msg = new("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.45, 60),
		Size = UDim2.fromOffset(300, 24), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
		Text = "Key válida!", TextColor3 = CONFIG.Success, TextSize = 17, TextTransparency = 1, ZIndex = 6,
	}, main)
	tween(msg, 0.4, {TextTransparency = 0})
	task.wait(1.3)

	tween(scale, 0.5, {Scale = 0}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tween(dim, 0.5, {BackgroundTransparency = 1})
	task.wait(0.55)
	root.Visible = false
	showApexScreen()
end

local function playError()
	status.Text = "Key inválida. Tente novamente."
	tween(fieldStroke, 0.15, {Color = CONFIG.Error, Transparency = 0})
	local base = field.Position
	for i = 1, 6 do
		local d = (i % 2 == 0) and 9 or -9
		tween(field, 0.04, {Position = base + UDim2.fromOffset(d, 0)}).Completed:Wait()
	end
	tween(field, 0.05, {Position = base})
	task.wait(1.2)
	tween(fieldStroke, 0.3, {Color = Color3.fromRGB(0, 120, 220), Transparency = 0.2})
	status.Text = ""
end

local busy = false
local function check()
	if busy then return end
	busy = true
	if box.Text == CONFIG.Key then
		playSuccess()
	else
		playError()
		busy = false
	end
end

btn.MouseButton1Click:Connect(check)
