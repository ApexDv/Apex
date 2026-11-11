local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera or workspace:GetPropertyChangedSignal("CurrentCamera"):Wait() and workspace.CurrentCamera

local NAME = "APEX HUB"
local VERSION = "v4.0"
local TOGGLE_KEY = Enum.KeyCode.RightShift
local KEY = "apex"

local C = {
	Bg = Color3.fromRGB(6, 10, 20),
	Bg2 = Color3.fromRGB(12, 24, 50),
	Panel = Color3.fromRGB(10, 17, 34),
	Element = Color3.fromRGB(18, 30, 58),
	ElementHover = Color3.fromRGB(28, 45, 82),
	Off = Color3.fromRGB(44, 58, 92),
	Text = Color3.fromRGB(238, 244, 255),
	Sub = Color3.fromRGB(135, 155, 195),
	White = Color3.new(1, 1, 1),
	Green = Color3.fromRGB(60, 210, 120),
	Red = Color3.fromRGB(235, 70, 80),
	Blue = Color3.fromRGB(0, 140, 255),
	Cyan = Color3.fromRGB(0, 229, 255),
	Dark = Color3.fromRGB(8, 13, 26),
	Field = Color3.fromRGB(13, 22, 44),
}

local ACCENTS = {
	["Azul"] = { Color3.fromRGB(41, 121, 255), Color3.fromRGB(110, 190, 255) },
	["Ciano"] = { Color3.fromRGB(0, 190, 230), Color3.fromRGB(120, 240, 255) },
	["Roxo"] = { Color3.fromRGB(135, 85, 255), Color3.fromRGB(200, 160, 255) },
	["Rosa"] = { Color3.fromRGB(255, 65, 140), Color3.fromRGB(255, 150, 195) },
}

local theme = { Accent = ACCENTS["Azul"][1], Light = ACCENTS["Azul"][2] }
local themed = {}

local function bindTheme(fn)
	fn(theme.Accent, theme.Light, true)
	table.insert(themed, fn)
end

local function setAccent(name)
	local pair = ACCENTS[name]
	if not pair then return end
	theme.Accent, theme.Light = pair[1], pair[2]
	for _, fn in ipairs(themed) do fn(theme.Accent, theme.Light, false) end
end

local function tween(obj, time, props, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function create(class, props, children)
	local inst = Instance.new(class)
	for k, v in pairs(props) do inst[k] = v end
	for _, c in ipairs(children or {}) do c.Parent = inst end
	return inst
end

local function corner(r) return create("UICorner", { CornerRadius = UDim.new(0, r) }) end

local function label(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or Enum.Font.GothamMedium
	props.TextColor3 = props.TextColor3 or C.Text
	props.TextSize = props.TextSize or 13
	return create("TextLabel", props)
end

local function paint(obj, prop, which)
	bindTheme(function(a, l, instant)
		local c = (which == "Light") and l or a
		if instant then obj[prop] = c else tween(obj, 0.4, { [prop] = c }) end
	end)
end

local function themedGradient(grad, build) bindTheme(function(a, l) grad.Color = build(a, l) end) end
local function diagBuild(a, l) return ColorSequence.new(l, a) end
local function borderBuild(a, l) return ColorSequence.new({
	ColorSequenceKeypoint.new(0, a),
	ColorSequenceKeypoint.new(0.5, l),
	ColorSequenceKeypoint.new(1, a:Lerp(Color3.new(0, 0, 0), 0.55)),
}) end
local function lineBuild(a, l) return ColorSequence.new({
	ColorSequenceKeypoint.new(0, C.Bg),
	ColorSequenceKeypoint.new(0.5, l),
	ColorSequenceKeypoint.new(1, C.Bg),
}) end

local spinners = {}
local function spin(grad, speed) table.insert(spinners, { grad = grad, speed = speed }) end

local function makeDraggable(handle, target, onTap)
	local dragging, dragStart, startPos, moved
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, moved = true, false
			dragStart, startPos = input.Position, target.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if onTap and not moved then onTap() end
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			if d.Magnitude > 6 then moved = true end
			if moved or not onTap then
				target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
			end
		end
	end)
end

local function loadAvatar(imageLabel)
	task.spawn(function()
		local ok, img = pcall(function()
			return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
		end)
		if ok then imageLabel.Image = img end
	end)
end

local ICONS = {}

ICONS.target = function(fill, ring) ring(12, 12, 17, 2); fill(12, 12, 7, 7) end
ICONS.chevrons = function(fill)
	for _, cx in ipairs({ 10.5, 16.5 }) do
		fill(cx - 1.5, 9, 8, 2.4, 45)
		fill(cx - 1.5, 15, 8, 2.4, -45)
	end
end
ICONS.list = function(fill) fill(12, 6, 16, 2.4, 0); fill(10, 12, 12, 2.4, 0); fill(8, 18, 8, 2.4, 0) end
ICONS.signal = function(fill)
	fill(5, 17.5, 3.4, 5, 0); fill(10, 15.5, 3.4, 9, 0); fill(15, 13.5, 3.4, 13, 0)
	fill(19.5, 6, 6, 2, 45); fill(19.5, 6, 6, 2, -45)
end
ICONS.gear = function(fill, ring)
	ring(12, 12, 11, 3)
	for i = 0, 7 do
		local a = math.rad(i * 45)
		fill(12 + 9 * math.cos(a), 12 + 9 * math.sin(a), 3.6, 4.6, i * 45 + 90, 1.2)
	end
end
ICONS.chevdown = function(fill) fill(9.5, 11, 7, 2.4, 45); fill(14.5, 11, 7, 2.4, -45) end
ICONS.close = function(fill) fill(12, 12, 18, 2.4, 45); fill(12, 12, 18, 2.4, -45) end
ICONS.minus = function(fill) fill(12, 12, 16, 2.6, 0) end
ICONS.search = function(fill, ring) ring(10.5, 10.5, 11, 2.2); fill(18.2, 18.2, 7, 2.4, 45) end
ICONS.dot = function(fill) fill(12, 12, 10, 10) end
ICONS.check = function(fill) fill(8, 14, 6, 2.6, 45); fill(14.5, 11.5, 13, 2.6, -45) end
ICONS.info = function(fill, ring) ring(12, 12, 19, 2); fill(12, 16, 2.4, 7); fill(12, 8, 2.8, 2.8) end
ICONS.stop = function(fill) fill(12, 12, 12, 12, 0, 3) end

local function newIcon(name, size, color)
	color = color or C.White
	local outer = create("Frame", { Name = "Icon_" .. name, Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 })
	local base = size / 24
	local uiScale = create("UIScale", { Scale = base })
	local art = create("Frame", {
		Size = UDim2.fromOffset(24, 24), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Parent = outer,
	}, { uiScale })
	local parts = {}
	local function fill(x, y, w, h, rot, cr)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h), Rotation = rot or 0,
			BackgroundColor3 = color, BorderSizePixel = 0, Parent = art,
		}, { create("UICorner", { CornerRadius = cr and UDim.new(0, cr) or UDim.new(1, 0) }) })
		table.insert(parts, { f, "BackgroundColor3" })
	end
	local function ring(x, y, d, thickness)
		local f = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1, Parent = art,
		}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		local s = create("UIStroke", { Color = color, Thickness = thickness, Parent = f })
		table.insert(parts, { s, "Color" })
	end
	local builder = ICONS[name]
	if builder then builder(fill, ring) end
	return { frame = outer, parts = parts, scale = uiScale, base = base }
end

local function tintIcon(icon, color, time)
	for _, p in ipairs(icon.parts) do
		if time then tween(p[1], time, { [p[2]] = color }) else p[1][p[2]] = color end
	end
end

local function placeIcon(icon, parent, xScale, xOff, yScale, yOff)
	icon.frame.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.frame.Position = UDim2.new(xScale or 0.5, xOff or 0, yScale or 0.5, yOff or 0)
	icon.frame.Parent = parent
end

local old = playerGui:FindFirstChild("ApexHub")
if old then old:Destroy() end
if CoreGui:FindFirstChild("ApexHubKey") then CoreGui.ApexHubKey:Destroy() end

local gui = create("ScreenGui", {
	Name = "ApexHub", ResetOnSpawn = false, IgnoreGuiInset = true,
	DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
if not okParent or not gui.Parent then gui.Parent = playerGui end

local CENTER = UDim2.fromScale(0.5, 0.5)
local ANCHOR = Vector2.new(0.5, 0.5)
local FULL_SIZE = UDim2.fromOffset(560, 340)
local HEADER_H = 48
local WINDOW_TRANSPARENCY = 0.22

local function baseScale()
	local v = camera.ViewportSize
	return math.clamp(math.min(v.X / 600, v.Y / 380), 0.55, 1)
end

local function newParticlesLayer(parent)
	local layer = create("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, Parent = parent })
	local alive = true
	task.spawn(function()
		while alive and layer.Parent do
			local s = math.random(3, 6)
			local dot = create("Frame", {
				Size = UDim2.fromOffset(s, s), Position = UDim2.new(math.random(), 0, 1.1, 0),
				BackgroundColor3 = C.Cyan, BackgroundTransparency = math.random(2, 6) / 10, BorderSizePixel = 0, Parent = layer,
			}, { corner(10) })
			tween(dot, math.random(4, 10), {
				Position = UDim2.new(dot.Position.X.Scale, math.random(-20, 20), -0.1, 0),
				BackgroundTransparency = 1,
			}, Enum.EasingStyle.Linear).Completed:Connect(function() dot:Destroy() end)
			task.wait(0.15)
		end
	end)
	return layer, function() alive = false end
end

local blur = create("BlurEffect", { Size = 0, Parent = Lighting })
tween(blur, 0.8, { Size = 18 })

local keyGui = create("ScreenGui", {
	Name = "ApexHubKey", ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 200,
})
local okKey = pcall(function() keyGui.Parent = (gethui and gethui()) or CoreGui end)
if not okKey or not keyGui.Parent then keyGui.Parent = playerGui end

local dim = create("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.Dark, BackgroundTransparency = 0.2,
	BorderSizePixel = 0, ZIndex = 1, Parent = keyGui,
})

local _, stopKeyParticles = newParticlesLayer(keyGui)

local root = create("Frame", {
	AnchorPoint = ANCHOR, Position = CENTER, Size = UDim2.fromOffset(320, 270),
	BackgroundTransparency = 1, ZIndex = 3, Parent = keyGui,
})
local keyScale = create("UIScale", { Scale = 0.6, Parent = root })

local glow = create("Frame", {
	AnchorPoint = ANCHOR, Position = CENTER, Size = UDim2.new(1, 14, 1, 14),
	BackgroundTransparency = 1, ZIndex = 3, Parent = root,
}, { corner(24) })
local glowStroke = create("UIStroke", { Color = C.White, Thickness = 7, Transparency = 0.82, Parent = glow })
local glowGrad = create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Blue),
		ColorSequenceKeypoint.new(0.5, C.Cyan),
		ColorSequenceKeypoint.new(1, C.Blue),
	}),
	Rotation = 0, Parent = glowStroke,
})

local main = create("Frame", {
	Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.Dark, BackgroundTransparency = 1,
	ClipsDescendants = true, BorderSizePixel = 0, ZIndex = 4, Parent = root,
}, { corner(18) })

local innerGlow = create("Frame", {
	Size = UDim2.fromScale(2, 2), Position = UDim2.fromScale(-0.5, -0.5),
	BackgroundColor3 = C.White, BackgroundTransparency = 0.8, BorderSizePixel = 0,
	ZIndex = 4, Parent = main,
})
local innerGrad = create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Dark),
		ColorSequenceKeypoint.new(0.5, C.Blue),
		ColorSequenceKeypoint.new(1, C.Dark),
	}),
	Rotation = 45, Parent = innerGlow,
})
TweenService:Create(innerGrad, TweenInfo.new(6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 405 }):Play()

local stroke = create("UIStroke", { Color = C.White, Thickness = 2, Parent = main })
local strokeGrad = create("UIGradient", {
	Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, C.Blue),
		ColorSequenceKeypoint.new(0.5, C.Cyan),
		ColorSequenceKeypoint.new(1, C.Blue),
	}),
	Rotation = 0, Parent = stroke,
})
TweenService:Create(strokeGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 }):Play()
TweenService:Create(glowGrad, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 }):Play()

local content = create("CanvasGroup", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1,
	ZIndex = 5, Parent = main,
})

local logo = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 22),
	Size = UDim2.fromOffset(46, 46), BackgroundColor3 = C.White, Parent = content,
}, { corner(13) })
create("UIGradient", { Color = ColorSequence.new(C.Cyan, C.Blue), Rotation = 45, Parent = logo })
create("UIStroke", { Color = C.Cyan, Thickness = 4, Transparency = 0.7, Parent = logo })
create("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
	Text = "A", TextSize = 26, TextColor3 = C.White, Parent = logo,
})

TweenService:Create(logo, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
	Size = UDim2.fromOffset(50, 50), Position = UDim2.new(0.5, 0, 0, 20),
}):Play()

create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 26), Position = UDim2.fromOffset(0, 80), BackgroundTransparency = 1,
	Font = Enum.Font.GothamBlack, Text = NAME, TextSize = 22, TextColor3 = C.White, Parent = content,
})
create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 106), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, Text = "Digite sua key para continuar", TextSize = 13,
	TextColor3 = Color3.fromRGB(140, 160, 195), Parent = content,
})

local field = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 142),
	Size = UDim2.new(0.86, 0, 0, 42), BackgroundColor3 = C.Field, BackgroundTransparency = 0.2,
	Parent = content,
}, { corner(21) })
local fieldStroke = create("UIStroke", { Color = Color3.fromRGB(0, 120, 220), Thickness = 1.5, Transparency = 0.2, Parent = field })

local lock = create("Frame", { Position = UDim2.fromOffset(14, 10), Size = UDim2.fromOffset(18, 22), BackgroundTransparency = 1, Parent = field })
local shackle = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 0),
	Size = UDim2.fromOffset(12, 14), BackgroundTransparency = 1, Parent = lock,
}, { corner(6) })
create("UIStroke", { Color = C.Cyan, Thickness = 2.2, Parent = shackle })
create("Frame", {
	AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, 0),
	Size = UDim2.fromOffset(18, 13), BackgroundColor3 = C.Cyan, BorderSizePixel = 0, Parent = lock,
}, { corner(4) })

local box = create("TextBox", {
	Position = UDim2.fromOffset(40, 0), Size = UDim2.new(1, -52, 1, 0), BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium, PlaceholderText = "Cole ou digite a key",
	PlaceholderColor3 = Color3.fromRGB(100, 120, 155), Text = "", TextColor3 = C.White,
	TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, Parent = field,
})

local btn = create("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, 196),
	Size = UDim2.new(0.86, 0, 0, 42), BackgroundColor3 = C.White, Text = "", AutoButtonColor = false, Parent = content,
}, { corner(21) })
local btnGrad = create("UIGradient", { Color = ColorSequence.new(C.Blue, C.Cyan), Rotation = 0, Parent = btn })
create("TextLabel", {
	Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
	Text = "VERIFICAR", TextSize = 14, TextColor3 = C.White, Parent = btn,
})

local status = create("TextLabel", {
	Size = UDim2.new(1, 0, 0, 18), Position = UDim2.fromOffset(0, 244), BackgroundTransparency = 1,
	Font = Enum.Font.Gotham, Text = "", TextSize = 12, TextColor3 = C.Red, Parent = content,
})

btn.MouseEnter:Connect(function()
	tween(btnGrad, 0.3, { Rotation = 25 })
	tween(btn, 0.15, { Size = UDim2.new(0.9, 0, 0, 44) })
end)
btn.MouseLeave:Connect(function()
	tween(btnGrad, 0.3, { Rotation = 0 })
	tween(btn, 0.15, { Size = UDim2.new(0.86, 0, 0, 42) })
end)
btn.MouseButton1Down:Connect(function() tween(btn, 0.08, { Size = UDim2.new(0.82, 0, 0, 40) }) end)
btn.MouseButton1Up:Connect(function() tween(btn, 0.12, { Size = UDim2.new(0.86, 0, 0, 42) }) end)

box.Focused:Connect(function() tween(fieldStroke, 0.2, { Color = C.Cyan, Transparency = 0 }) end)
box.FocusLost:Connect(function() tween(fieldStroke, 0.2, { Color = Color3.fromRGB(0, 120, 220), Transparency = 0.2 }) end)

tween(keyScale, 0.7, { Scale = 1 }, Enum.EasingStyle.Back)
task.delay(0.35, function() tween(content, 0.5, { GroupTransparency = 0 }) end)

local function showApexScreen(onDone)
	local screen = create("Frame", {
		Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(3, 6, 14),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 10, Parent = keyGui,
	})
	tween(screen, 0.6, { BackgroundTransparency = 0 })
	task.wait(0.7)

	local holder = create("Frame", {
		AnchorPoint = ANCHOR, Position = CENTER, Size = UDim2.fromOffset(500, 90),
		BackgroundTransparency = 1, ZIndex = 11, Parent = screen,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 4), Parent = holder,
	})

	local letters = {}
	for i = 1, #NAME do
		local ch = NAME:sub(i, i)
		local l = create("TextLabel", {
			Size = UDim2.fromOffset(ch == " " and 24 or 50, 80), BackgroundTransparency = 1,
			Font = Enum.Font.GothamBlack, Text = ch, TextSize = 30, TextTransparency = 1,
			TextColor3 = (i <= 4) and C.Cyan or C.White, ZIndex = 12, LayoutOrder = i, Parent = holder,
		})
		table.insert(letters, l)
	end
	for _, l in ipairs(letters) do
		tween(l, 0.4, { TextTransparency = 0, TextSize = 70 }, Enum.EasingStyle.Back)
		task.wait(0.14)
	end

	local line = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 55),
		Size = UDim2.fromOffset(0, 3), BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 11, Parent = screen,
	}, { corner(2) })
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, C.Blue),
			ColorSequenceKeypoint.new(0.5, C.Cyan),
			ColorSequenceKeypoint.new(1, C.Blue),
		}), Parent = line,
	})
	tween(line, 0.9, { Size = UDim2.fromOffset(300, 3) }, Enum.EasingStyle.Quart)

	local loading = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.5, 70),
		Size = UDim2.fromOffset(300, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham,
		Text = "Carregando script...", TextSize = 13, TextColor3 = Color3.fromRGB(140, 160, 195),
		TextTransparency = 1, ZIndex = 11, Parent = screen,
	})
	tween(loading, 0.6, { TextTransparency = 0 })

	task.wait(2.2)
	for _, l in ipairs(letters) do tween(l, 0.5, { TextTransparency = 1 }) end
	tween(line, 0.5, { BackgroundTransparency = 1 })
	tween(loading, 0.5, { TextTransparency = 1 })
	tween(screen, 0.8, { BackgroundTransparency = 1 })
	tween(blur, 0.8, { Size = 0 })
	task.wait(0.9)
	blur:Destroy()
	keyGui:Destroy()
	if onDone then onDone()
		end -- fecha showApexScreen

-- ============ SUCESSO / ERRO ============
local function playSuccess()
	alive = false
	tween(content, 0.3, { GroupTransparency = 1 })
	tween(glowStroke, 0.3, { Transparency = 0.6 })
	strokeGrad.Color = ColorSequence.new(C.Success or C.Green)
	glowGrad.Color = ColorSequence.new(C.Success or C.Green)
	task.wait(0.35)

	local circle = create("Frame", {
		AnchorPoint = ANCHOR, Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromOffset(0, 0), BackgroundColor3 = C.Green, ZIndex = 6, Parent = main,
	}, { corner(100) })
	local check = create("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBlack,
		Text = "✓", TextColor3 = C.White, TextSize = 1, ZIndex = 7, Parent = circle,
	})
	tween(circle, 0.5, { Size = UDim2.fromOffset(90, 90) }, Enum.EasingStyle.Back)
	tween(check, 0.5, { TextSize = 58 }, Enum.EasingStyle.Back)
	task.wait(0.5)

	local msg = create("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.45, 60),
		Size = UDim2.fromOffset(300, 24), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
		Text = "Key válida!", TextColor3 = C.Green, TextSize = 17, TextTransparency = 1, ZIndex = 6, Parent = main,
	})
	tween(msg, 0.4, { TextTransparency = 0 })
	task.wait(1.3)

	tween(keyScale, 0.5, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
	tween(dim, 0.5, { BackgroundTransparency = 1 })
	task.wait(0.55)
	root.Visible = false
	showApexScreen()
end

local function playError()
	status.Text = "Key inválida. Tente novamente."
	tween(fieldStroke, 0.15, { Color = C.Red, Transparency = 0 })
	local base = field.Position
	for i = 1, 6 do
		local d = (i % 2 == 0) and 9 or -9
		tween(field, 0.04, { Position = base + UDim2.fromOffset(d, 0) }).Completed:Wait()
	end
	tween(field, 0.05, { Position = base })
	task.wait(1.2)
	tween(fieldStroke, 0.3, { Color = Color3.fromRGB(0, 120, 220), Transparency = 0.2 })
	status.Text = ""
end

local busy = false
local function checkKey()
	if busy then return end
	busy = true
	if box.Text == KEY then
		playSuccess()
	else
		playError()
		busy = false
	end
end

btn.MouseButton1Click:Connect(checkKey)

-- ============ O QUE RODA QUANDO ACERTA A KEY ============
local function onSuccess()
	-- Painel v4 é criado AQUI.
	-- (as variáveis Players, TweenService, camera, etc. já estão no escopo de cima)
	
	local old2 = playerGui:FindFirstChild("ApexHub")
	if old2 then old2:Destroy() end

	local guiPanel = create("ScreenGui", {
		Name = "ApexHub", ResetOnSpawn = false, IgnoreGuiInset = true,
		DisplayOrder = 100, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = playerGui,
	})

	local FULL = UDim2.fromOffset(560, 340)
	local HDR = 48
	local WTR = 0.22

	local function baseSc()
		local v = camera.ViewportSize
		return math.clamp(math.min(v.X / 600, v.Y / 380), 0.55, 1)
	end

	-- notificações
	local notificationsOn = true
	local toastBox = create("Frame", {
		Name = "Toasts", Size = UDim2.fromOffset(230, 320),
		AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -14, 1, -14),
		BackgroundTransparency = 1, ZIndex = 60, Parent = guiPanel,
	}, {
		create("UIListLayout", {
			Padding = UDim.new(0, 8),
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		}),
	})

	local function notify(iconName, title, text, duration)
		if not notificationsOn then return end
		duration = duration or 3
		local holder = create("Frame", { Size = UDim2.new(1, 0, 0, 58), BackgroundTransparency = 1, Parent = toastBox })
		local toast = create("CanvasGroup", {
			Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(260, 0),
			BackgroundColor3 = C.Panel, Parent = holder,
		}, {
			corner(12),
			create("UIStroke", { Color = theme.Accent, Thickness = 1.2, Transparency = 0.35 }),
		})
		local iconBox = create("Frame", {
			Size = UDim2.fromOffset(34, 34), Position = UDim2.fromOffset(10, 10),
			BackgroundColor3 = C.Element, Parent = toast,
		}, { corner(17) })
		placeIcon(newIcon(iconName, 16, theme.Light), iconBox)
		label({
			Size = UDim2.new(1, -62, 0, 18), Position = UDim2.fromOffset(54, 8),
			Text = title, Font = Enum.Font.GothamBold, TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = toast,
		})
		label({
			Size = UDim2.new(1, -62, 0, 18), Position = UDim2.fromOffset(54, 27),
			Text = text, TextColor3 = C.Sub, TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = toast,
		})
		local bar = create("Frame", {
			Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
			BackgroundColor3 = theme.Accent, BorderSizePixel = 0, Parent = toast,
		})
		tween(toast, 0.5, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)
		tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)
		task.delay(duration, function()
			tween(toast, 0.4, { Position = UDim2.fromOffset(260, 0) })
			task.wait(0.4)
			tween(holder, 0.25, { Size = UDim2.new(1, 0, 0, 0) }).Completed:Wait()
			holder:Destroy()
		end)
	end

	-- janela principal
	local mainPanel = create("CanvasGroup", {
		Name = "Main", Size = FULL, Position = CENTER, AnchorPoint = ANCHOR,
		BackgroundColor3 = C.Bg, BackgroundTransparency = WTR,
		GroupTransparency = 1, Visible = false, Parent = guiPanel,
	}, { corner(16) })

	local pScale = create("UIScale", { Scale = baseSc() * 0.85, Parent = mainPanel })
	create("UIGradient", { Color = ColorSequence.new(C.Bg2, C.Bg), Rotation = 60, Parent = mainPanel })

	local fx = create("Frame", {
		Name = "Particles", Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 0, Parent = mainPanel,
	})
	local particles = {}
	for i = 1, 32 do
		local size = math.random(2, 6)
		local f = create("Frame", {
			Size = UDim2.fromOffset(size, size), BackgroundColor3 = theme.Light,
			BackgroundTransparency = 0.35 + (size / 6) * 0.5, BorderSizePixel = 0, Parent = fx,
		}, { corner(6) })
		particles[i] = { f = f, x = math.random(), y = math.random(), speed = math.random(15, 55) / 1000, phase = math.random() * 6 }
	end
	for i = 1, 5 do
		local size = math.random(14, 26)
		local f = create("Frame", {
			Size = UDim2.fromOffset(size, size), BackgroundColor3 = theme.Accent,
			BackgroundTransparency = 0.92, BorderSizePixel = 0, Parent = fx,
		}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		table.insert(particles, { f = f, x = math.random(), y = math.random(), speed = math.random(8, 20) / 1000, phase = math.random() * 6 })
	end
	bindTheme(function(a, l)
		for idx, p in ipairs(particles) do
			p.f.BackgroundColor3 = (idx > 32) and a or l
		end
	end)

	local pStroke = create("UIStroke", { Thickness = 2, Color = C.White, Parent = mainPanel })
	local pStrokeGrad = create("UIGradient", { Parent = pStroke })
	themedGradient(pStrokeGrad, borderBuild)
	spin(pStrokeGrad, 60)

	-- header
	local header = create("Frame", {
		Name = "Header", Size = UDim2.new(1, 0, 0, HDR),
		BackgroundColor3 = C.Panel, BackgroundTransparency = 0.35,
		BorderSizePixel = 0, ZIndex = 3, Parent = mainPanel,
	})

	local logo2 = create("Frame", {
		Size = UDim2.fromOffset(30, 30), Position = UDim2.fromOffset(12, 9),
		BackgroundColor3 = C.White, ZIndex = 4, Parent = header,
	}, { corner(9) })
	local logo2Grad = create("UIGradient", { Rotation = 45, Parent = logo2 })
	themedGradient(logo2Grad, diagBuild)
	spin(logo2Grad, 90)
	label({ Size = UDim2.fromScale(1, 1), Text = "A", Font = Enum.Font.GothamBlack, TextSize = 17, ZIndex = 5, Parent = logo2 })

	local titleLabel = label({
		Size = UDim2.fromOffset(96, 48), Position = UDim2.fromOffset(50, 0),
		Text = NAME, Font = Enum.Font.GothamBlack, TextSize = 15,
		TextColor3 = C.White, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = header,
	})
	local titleGrad = create("UIGradient", { Rotation = 0, Parent = titleLabel })
	themedGradient(titleGrad, function(a, l)
		return ColorSequence.new({ ColorSequenceKeypoint.new(0, C.White), ColorSequenceKeypoint.new(1, l) })
	end)

	local verBadge = create("Frame", {
		Size = UDim2.fromOffset(38, 18), Position = UDim2.fromOffset(148, 15),
		BackgroundColor3 = C.Element, ZIndex = 4, Parent = header,
	}, { corner(9) })
	label({ Size = UDim2.fromScale(1, 1), Text = VERSION, TextSize = 10, TextColor3 = C.Sub, ZIndex = 5, Parent = verBadge })

	local statusPill = create("Frame", {
		Size = UDim2.fromOffset(62, 20), Position = UDim2.fromOffset(192, 14),
		BackgroundColor3 = C.Element, ZIndex = 4, Parent = header,
	}, { corner(10) })
	local statusDot = create("Frame", {
		Size = UDim2.fromOffset(7, 7), Position = UDim2.fromOffset(8, 7),
		BackgroundColor3 = C.Sub, ZIndex = 5, Parent = statusPill,
	}, { corner(4) })
	local statusText = label({
		Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(19, 0),
		Text = "Idle", TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5, Parent = statusPill,
	})
	local function setStatus(text, color)
		statusText.Text = text
		tween(statusDot, 0.25, { BackgroundColor3 = color or C.Sub })
	end

	local perfPill = create("Frame", {
		Size = UDim2.fromOffset(92, 20), Position = UDim2.fromOffset(260, 14),
		BackgroundColor3 = C.Element, ZIndex = 4, Parent = header,
	}, { corner(10) })
	local perfText = label({
		Size = UDim2.fromScale(1, 1), Text = "-- FPS · --ms", TextSize = 10,
		TextColor3 = C.Sub, ZIndex = 5, Parent = perfPill,
	})

	-- busca
	local searchBox = create("TextBox", {
		Size = UDim2.fromOffset(124, 26), Position = UDim2.new(1, -196, 0, 11),
		BackgroundColor3 = C.Element, PlaceholderText = "Buscar...", PlaceholderColor3 = C.Sub,
		Text = "", TextColor3 = C.Text, Font = Enum.Font.Gotham, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 4, Parent = header,
	}, { corner(13), create("UIPadding", { PaddingLeft = UDim.new(0, 28) }) })
	local searchIcon = newIcon("search", 13, C.Sub)
	placeIcon(searchIcon, searchBox, 0, -14, 0.5, 0)
	searchIcon.frame.ZIndex = 5
	local searchStroke = create("UIStroke", { Thickness = 1, Transparency = 1, Color = theme.Light, Parent = searchBox })
	paint(searchStroke, "Color", "Light")
	searchBox.Focused:Connect(function()
		tween(searchStroke, 0.25, { Transparency = 0 })
		tintIcon(searchIcon, theme.Light, 0.25)
	end)
	searchBox.FocusLost:Connect(function()
		tween(searchStroke, 0.25, { Transparency = 1 })
		tintIcon(searchIcon, C.Sub, 0.25)
	end)

	local function headerButton(iconName, xOffset)
		local b = create("TextButton", {
			Size = UDim2.fromOffset(26, 26), Position = UDim2.new(1, xOffset, 0, 11),
			BackgroundColor3 = C.Element, Text = "", AutoButtonColor = false, ZIndex = 4, Parent = header,
		}, { corner(13) })
		placeIcon(newIcon(iconName, 12, C.Text), b)
		b.MouseEnter:Connect(function() tween(b, 0.15, { BackgroundColor3 = theme.Accent }) end)
		b.MouseLeave:Connect(function() tween(b, 0.15, { BackgroundColor3 = C.Element }) end)
		return b
	end
	local minimizeBtn = headerButton("minus", -64)
	local closeBtn = headerButton("close", -34)

	local accentLine = create("Frame", {
		Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2),
		BackgroundColor3 = C.White, BorderSizePixel = 0, ZIndex = 4, Parent = header,
	})
	local lineGrad2 = create("UIGradient", { Parent = accentLine })
	themedGradient(lineGrad2, lineBuild)

	-- corpo
	local body = create("Frame", {
		Name = "Body", Size = UDim2.new(1, 0, 1, -HDR),
		Position = UDim2.fromOffset(0, HDR), BackgroundTransparency = 1, Parent = mainPanel,
	})

	local sidebar = create("Frame", {
		Name = "Sidebar", Size = UDim2.new(0, 46, 1, -16), Position = UDim2.fromOffset(8, 8),
		BackgroundColor3 = C.Panel, BackgroundTransparency = 0.3, Parent = body,
	}, { corner(23) })
	local sideStroke = create("UIStroke", { Thickness = 1, Transparency = 0.55, Parent = sidebar })
	paint(sideStroke, "Color", "Accent")

	local ring = create("Frame", {
		Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(4, 6),
		BackgroundColor3 = C.Element, Visible = false, ZIndex = 1, Parent = sidebar,
	}, { corner(19) })
	local ringStroke = create("UIStroke", { Thickness = 1.8, Parent = ring })
	paint(ringStroke, "Color", "Light")

	local avatar = create("ImageLabel", {
		Size = UDim2.fromOffset(34, 34), Position = UDim2.new(0.5, -17, 1, -42),
		BackgroundColor3 = C.Element, ZIndex = 2, Parent = sidebar,
	}, { corner(17) })
	local avatarStroke = create("UIStroke", { Thickness = 1.5, Parent = avatar })
	paint(avatarStroke, "Color", "Accent")
	loadAvatar(avatar)

	local content = create("Frame", {
		Size = UDim2.new(1, -62, 1, 0), Position = UDim2.fromOffset(62, 0),
		BackgroundTransparency = 1, ClipsDescendants = true, Parent = body,
	})
	local pageTitle = label({
		Size = UDim2.new(1, -24, 0, 22), Position = UDim2.fromOffset(12, 6),
		Text = "", Font = Enum.Font.GothamBold, TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = content,
	})
	local pageSub = label({
		Size = UDim2.new(1, -24, 0, 14), Position = UDim2.fromOffset(12, 29),
		Text = "", TextColor3 = C.Sub, TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left, Parent = content,
	})

	local function ripple(btn, pos)
		local s = pScale.Scale
		local rel = (Vector2.new(pos.X, pos.Y) - btn.AbsolutePosition) / s
		local d = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) / s * 2.4
		local r = create("Frame", {
			AnchorPoint = ANCHOR, Position = UDim2.fromOffset(rel.X, rel.Y),
			Size = UDim2.fromOffset(0, 0), BackgroundColor3 = C.White,
			BackgroundTransparency = 0.7, ZIndex = 6, Parent = btn,
		}, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
		tween(r, 0.55, { Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1 }).Completed:Connect(function()
			r:Destroy()
		end)
	end

	local elements = {}
	local tabs = {}
	local currentTab
	local particlesEnabled = true
	local ROW_TRANSPARENCY = 0.25

	local function makeRow(parent, name, height)
		local row = create("Frame", {
			Name = name, Size = UDim2.new(1, 0, 0, height or 40),
			BackgroundColor3 = C.Element, BackgroundTransparency = ROW_TRANSPARENCY, Parent = parent,
		}, { corner(10) })
		table.insert(elements, { row = row, name = name:lower() })
		label({
			Size = UDim2.new(1, -110, 1, 0), Position = UDim2.fromOffset(12, 0),
			Text = name, TextXAlignment = Enum.TextXAlignment.Left, Parent = row,
		})
		row.MouseEnter:Connect(function() tween(row, 0.15, { BackgroundColor3 = C.ElementHover }) end)
		row.MouseLeave:Connect(function() tween(row, 0.15, { BackgroundColor3 = C.Element }) end)
		return row
	end

	local function addSection(parent, text)
		local boxSec = create("Frame", { Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, Parent = parent })
		local dot = newIcon("dot", 8, theme.Light)
		placeIcon(dot, boxSec, 0, 4, 0.5, 0)
		bindTheme(function(a, l, instant) tintIcon(dot, l, (not instant) and 0.4 or nil) end)
		local l = label({
			Size = UDim2.new(1, -14, 1, 0), Position = UDim2.fromOffset(14, 0), Text = text:upper(),
			TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Left, Parent = boxSec,
		})
		paint(l, "TextColor3", "Light")
	end

	local function addInfo(parent, text, height)
		label({
			Size = UDim2.new(1, 0, 0, height or 30), Text = text, TextColor3 = C.Sub, TextSize = 12,
			TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, Parent = parent,
		})
	end

	local function addToggle(parent, name, default, callback)
		local row = makeRow(parent, name)
		local state = default
		local track = create("Frame", {
			Size = UDim2.fromOffset(42, 22), Position = UDim2.new(1, -54, 0.5, -11),
			BackgroundColor3 = state and theme.Accent or C.Off, Parent = row,
		}, { corner(11) })
		local knob = create("Frame", {
			Size = UDim2.fromOffset(16, 16),
			Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3),
			BackgroundColor3 = C.White, Parent = track,
		}, { corner(8) })
		bindTheme(function(a, l, instant)
			if state then
				if instant then track.BackgroundColor3 = a else tween(track, 0.4, { BackgroundColor3 = a }) end
			end
		end)
		local hit = create("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Parent = row })
		hit.MouseButton1Click:Connect(function()
			state = not state
			tween(track, 0.2, { BackgroundColor3 = state and theme.Accent or C.Off })
			tween(knob, 0.3, { Position = state and UDim2.fromOffset(23, 3) or UDim2.fromOffset(3, 3) }, Enum.EasingStyle.Back)
			knob.Size = UDim2.fromOffset(20, 14)
			tween(knob, 0.3, { Size = UDim2.fromOffset(16, 16) }, Enum.EasingStyle.Back)
			callback(state)
		end)
	end

	local function addSelector(parent, name, options, callback)
		local row = makeRow(parent, name)
		local index = 1
		local btn2 = create("TextButton", {
			Size = UDim2.fromOffset(96, 26), Position = UDim2.new(1, -106, 0.5, -13),
			BackgroundColor3 = C.Off, Text = options[1], TextColor3 = C.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium,
			TextSize = 11, AutoButtonColor = false, Parent = row,
		}, { corner(13), create("UIPadding", { PaddingLeft = UDim.new(0, 11) }) })
		local arrow = newIcon("chevdown", 11, C.Sub)
		placeIcon(arrow, btn2, 1, -9, 0.5, 0)
		btn2.MouseButton1Click:Connect(function()
			index = index % #options + 1
			btn2.Text = options[index]
			btn2.Size = UDim2.fromOffset(88, 23)
			tween(btn2, 0.25, { Size = UDim2.fromOffset(96, 26) }, Enum.EasingStyle.Back)
			callback(options[index])
		end)
	end

	local function addButton(parent, name, buttonText, callback, color)
		local row = makeRow(parent, name)
		local b = create("CanvasGroup", {
			Size = UDim2.fromOffset(76, 26), Position = UDim2.new(1, -88, 0.5, -13),
			BackgroundColor3 = color or theme.Accent, Parent = row,
		}, { corner(13) })
		if not color then paint(b, "BackgroundColor3", "Accent") end
		local hit = create("TextButton", {
			Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = buttonText,
			TextColor3 = C.White, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, Parent = b,
		})
		hit.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				ripple(b, input.Position)
			end
		end)
		hit.MouseButton1Click:Connect(function()
			b.Size = UDim2.fromOffset(68, 23)
			tween(b, 0.3, { Size = UDim2.fromOffset(76, 26) }, Enum.EasingStyle.Back)
			callback()
		end)
	end

	local function addSlider(parent, name, min, max, default, callback)
		local row = makeRow(parent, name, 54)
		local nameLabel = row:FindFirstChildOfClass("TextLabel")
		nameLabel.Size = UDim2.new(1, -90, 0, 32)
		local valueLabel = label({
			Size = UDim2.fromOffset(60, 32), Position = UDim2.new(1, -72, 0, 0),
			Text = tostring(default), TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = row,
		})
		paint(valueLabel, "TextColor3", "Light")

		local track = create("Frame", {
			Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 1, -17),
			BackgroundColor3 = C.Off, Parent = row,
		}, { corner(3) })
		local fill = create("Frame", {
			Size = UDim2.fromScale((default - min) / (max - min), 1),
			BackgroundColor3 = theme.Accent, Parent = track,
		}, { corner(3) })
		paint(fill, "BackgroundColor3", "Accent")
		local knob = create("Frame", {
			Size = UDim2.fromOffset(16, 16), AnchorPoint = ANCHOR, Position = UDim2.fromScale(1, 0.5),
			BackgroundColor3 = C.White, ZIndex = 2, Parent = fill,
		}, { corner(8) })
		local knobStroke = create("UIStroke", { Thickness = 2, Parent = knob })
		paint(knobStroke, "Color", "Accent")

		local hit = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 1, -28),
			BackgroundTransparency = 1, Text = "", Parent = row,
		})

		local dragging, last = false, default
		local function update(x)
			local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.
