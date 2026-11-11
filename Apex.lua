local Players         = game:GetService("Players")
local UIS             = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

local KEY = "apex"
local lp  = Players.LocalPlayer
local F   = Enum.Font
local LEFT, CENTER, RIGHT = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
local BACK, SINE = Enum.EasingStyle.Back, Enum.EasingStyle.Sine

local T = {
	Bg=Color3.fromRGB(5,8,18), Rail=Color3.fromRGB(8,13,27), Card=Color3.fromRGB(12,20,38),
	Row=Color3.fromRGB(18,30,52), Stroke=Color3.fromRGB(32,55,90),
	G1=Color3.fromRGB(65,165,255), G2=Color3.fromRGB(20,95,220),
	Text=Color3.fromRGB(235,255,242), Sub=Color3.fromRGB(135,175,220),
	Red=Color3.fromRGB(255,100,110), Orange=Color3.fromRGB(255,160,50),
	Blue=Color3.fromRGB(80,160,255), Purple=Color3.fromRGB(175,95,255),
	Gold=Color3.fromRGB(255,195,55), Green=Color3.fromRGB(80,220,100)
}
local ACCENT = ColorSequence.new(T.G1, T.G2)

local function new(class,props,parent)
	local o=Instance.new(class)
	for k,v in pairs(props or {}) do o[k]=v end
	if parent then o.Parent=parent end
	return o
end
local function corner(o,r) return new("UICorner",{CornerRadius=(r=="pill")and UDim.new(0.5,0)or UDim.new(0,r)},o) end
local function stroke(o,color,th,tr) return new("UIStroke",{Color=color or T.Stroke,Thickness=th or 1,Transparency=tr or 0,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},o) end
local function gradient(o,seq,rot) return new("UIGradient",{Color=seq or ACCENT,Rotation=rot or 45},o) end
local function tween(o,t,props,style,dir)
	local tw=TweenService:Create(o,TweenInfo.new(t,style or Enum.EasingStyle.Quad,dir or Enum.EasingDirection.Out),props)
	tw:Play(); return tw
end
local function loop(o,t,props) TweenService:Create(o,TweenInfo.new(t,SINE,Enum.EasingDirection.InOut,-1,true),props):Play() end
local function label(parent,props)
	local p={BackgroundTransparency=1,Font=F.Gotham,TextSize=12,TextColor3=T.Text,TextXAlignment=LEFT}
	for k,v in pairs(props) do p[k]=v end
	return new("TextLabel",p,parent)
end
local function juice(btn,big)
	local sc=new("UIScale",{Scale=1},btn)
	btn.MouseEnter:Connect(function() tween(sc,0.14,{Scale=big or 1.04}) end)
	btn.MouseLeave:Connect(function() tween(sc,0.14,{Scale=1}) end)
	btn.MouseButton1Down:Connect(function() tween(sc,0.08,{Scale=0.94}) end)
	btn.MouseButton1Up:Connect(function() tween(sc,0.25,{Scale=big or 1.04},BACK) end)
	return sc
end
local function draggable(handle,target)
	local dragging,start,origin
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging,start,origin=true,i.Position,target.Position
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-start
			target.Position=UDim2.new(origin.X.Scale,origin.X.Offset+d.X,origin.Y.Scale,origin.Y.Offset+d.Y)
		end
	end)
end
local spinners={}
local function spin(g,speed) spinners[#spinners+1]={g,speed}; return g end
local particleList={}
local function particles(parent,n)
	for _ = 1,n do
		local s=math.random(3,7)
		local p=new("Frame",{Size=UDim2.fromOffset(s,s),Position=UDim2.new(math.random(),0,1.05,0),
			BackgroundColor3=T.G1,BackgroundTransparency=1,BorderSizePixel=0},parent)
		corner(p,"pill"); particleList[#particleList+1]=p
		task.spawn(function()
			task.wait(math.random()*5)
			while p.Parent do
				local dur=math.random(6,11)
				p.Position=UDim2.new(math.random(),0,1.05,0); p.BackgroundTransparency=1
				tween(p,1.2,{BackgroundTransparency=0.45},Enum.EasingStyle.Linear)
				tween(p,dur,{Position=UDim2.new(p.Position.X.Scale,0,-0.05,0)},Enum.EasingStyle.Linear)
				task.wait(dur-1.2); tween(p,1.2,{BackgroundTransparency=1},Enum.EasingStyle.Linear); task.wait(1.3)
			end
		end)
	end
end

local parentGui=(gethui and gethui()) or CoreGui
local old=parentGui:FindFirstChild("APEXHub"); if old then old:Destroy() end
local gui=new("ScreenGui",{Name="APEXHub",ResetOnSpawn=false,DisplayOrder=100,
	ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true},parentGui)

local spinConn
spinConn=RunService.RenderStepped:Connect(function(dt)
	if not gui.Parent then spinConn:Disconnect(); return end
	for _,s in ipairs(spinners) do s[1].Rotation=(s[1].Rotation+s[2]*dt)%360 end
end)

-- FAB (botão flutuante)
local fab=new("TextButton",{Size=UDim2.fromOffset(52,52),Position=UDim2.new(0,16,0.5,-26),
	BackgroundColor3=Color3.fromRGB(8,14,10),Text="",AutoButtonColor=false,Visible=false},gui)
corner(fab,"pill")
spin(gradient(fab,ACCENT,45),70)
local fabStroke=stroke(fab,T.G1,2,0.4)
loop(fabStroke,1.2,{Transparency=0.85,Thickness=6})
draggable(fab,fab)
local fabSc=new("UIScale",{Scale=1},fab)
local fabAvatar=new("ImageLabel",{Size=UDim2.fromOffset(44,44),AnchorPoint=Vector2.new(0.5,0.5),
	Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Crop},fab)
corner(fabAvatar,"pill")
task.spawn(function()
	pcall(function() fabAvatar.Image=Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
end)

local function fitScale()
	local cam=workspace.CurrentCamera; if not cam then return 1 end
	local vp=cam.ViewportSize
	return math.clamp(math.min((vp.X-24)/460,(vp.Y-24)/220),0.4,1)
end

-- ===================== SPLASH (intro) =====================
local function runIntro()
	fab.Visible=false
	local splash=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,ZIndex=150},gui)
	local sg=gradient(splash,ColorSequence.new(Color3.fromRGB(0,0,0),Color3.fromRGB(5,18,42)),90)
	particles(splash,22)
	local box=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(460,130),BackgroundTransparency=1,ZIndex=151},splash)
	local letters=new("Frame",{Size=UDim2.new(1,0,0,72),BackgroundTransparency=1,ZIndex=151},box)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center,Padding=UDim.new(0,8)},letters)
	local parts={}
	for i,ch in ipairs({"A","P","E","X"}) do
		local l=new("TextLabel",{Size=UDim2.fromOffset(54,72),BackgroundTransparency=1,Text=ch,Font=F.GothamBlack,TextSize=66,TextColor3=Color3.new(1,1,1),TextTransparency=1,ZIndex=152,LayoutOrder=i},letters)
		local sc=new("UIScale",{Scale=2.4},l); gradient(l,ACCENT,90); parts[i]={l,sc}
	end
	local line=new("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,80),Size=UDim2.fromOffset(0,3),BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,ZIndex=151},box)
	corner(line,"pill"); gradient(line,ACCENT,0)
	local best=new("TextLabel",{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,94),BackgroundTransparency=1,
		Text="A P E X   H U B   -   T H E   B E S T",Font=F.GothamBold,TextSize=18,TextColor3=T.Sub,TextTransparency=1,ZIndex=151},box)
	local bestSc=new("UIScale",{Scale=0.6},best)

	task.spawn(function()
		for i,p in ipairs(parts) do
			task.delay((i-1)*0.2,function()
				tween(p[1],0.5,{TextTransparency=0})
				TweenService:Create(p[2],TweenInfo.new(0.8,BACK,Enum.EasingDirection.Out),{Scale=1}):Play()
			end)
		end
		task.wait(1.2)
		tween(line,0.8,{Size=UDim2.fromOffset(300,3)})
		tween(best,0.8,{TextTransparency=0})
		TweenService:Create(bestSc,TweenInfo.new(0.8,BACK,Enum.EasingDirection.Out),{Scale=1}):Play()

		task.wait(2.0)

		for _,p in ipairs(parts) do tween(p[1],0.6,{TextTransparency=1}) end
		tween(best,0.6,{TextTransparency=1}); tween(line,0.6,{Size=UDim2.fromOffset(0,3)})
		task.wait(0.5); tween(splash,0.6,{BackgroundTransparency=1}); sg.Enabled=false
		task.wait(0.6); splash:Destroy(); fabSc.Scale=0; fab.Visible=true
		TweenService:Create(fabSc,TweenInfo.new(0.6,BACK,Enum.EasingDirection.Out),{Scale=1}):Play()
	end)
end

-- ===================== GATE (key) =====================
local function runGate()
	fab.Visible=false
	local gate=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=160,Active=true},gui)
	particles(gate,18)
	local box=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(380,220),BackgroundColor3=Color3.new(1,1,1)},gate)
	corner(box,26); gradient(box,ColorSequence.new(Color3.fromRGB(10,24,48),T.Bg),60)
	local bs=stroke(box,Color3.new(1,1,1),2,0.05)
	spin(gradient(bs,ColorSequence.new({ColorSequenceKeypoint.new(0,T.G1),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,35,75)),ColorSequenceKeypoint.new(1,T.G2)}),30),70)
	local boxSc=new("UIScale",{Scale=0},box); tween(boxSc,0.6,{Scale=math.min(1,fitScale()+0.15)},BACK)

	local gl=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,30,1,30),BackgroundColor3=T.G2,BackgroundTransparency=0.92,BorderSizePixel=0,ZIndex=0},box)
	corner(gl,40); loop(gl,1.6,{BackgroundTransparency=0.97})

	local lg=new("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,22),Size=UDim2.fromOffset(58,58),BackgroundColor3=Color3.new(1,1,1),Text="A",Font=F.GothamBlack,TextSize=32,TextColor3=T.Bg},box)
	corner(lg,20); spin(gradient(lg,ACCENT,45),90); local lgSc=new("UIScale",{Scale=1},lg); loop(lgSc,1.2,{Scale=1.1})

	label(box,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,90),Text="APEX HUB",Font=F.GothamBlack,TextSize=21,TextXAlignment=CENTER})
	label(box,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,117),Text="Digite sua key para continuar",TextSize=12,TextColor3=T.Sub,TextXAlignment=CENTER})

	local inWrap=new("Frame",{Size=UDim2.new(1,-48,0,44),Position=UDim2.fromOffset(24,146),BackgroundColor3=T.Row},box); corner(inWrap,"pill")
	local inStroke=stroke(inWrap,T.Stroke,1.5)
	local input=new("TextBox",{Size=UDim2.new(1,-64,1,0),Position=UDim2.fromOffset(48,0),BackgroundTransparency=1,Text="",PlaceholderText="Cole ou digite a key",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=F.GothamBold,TextSize=14,ClearTextOnFocus=false,TextXAlignment=LEFT},inWrap)

	do
		local sh=new("Frame",{Size=UDim2.fromOffset(10,12),Position=UDim2.fromOffset(19,9),BackgroundTransparency=1},inWrap)
		corner(sh,"pill"); new("UIStroke",{Color=T.G1,Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},sh)
		local bd=new("Frame",{Size=UDim2.fromOffset(16,12),Position=UDim2.fromOffset(16,20),BackgroundColor3=T.G1,BorderSizePixel=0},inWrap); corner(bd,4)
	end

	local function successAnim(cb)
		local flash=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=T.G1,BackgroundTransparency=1,ZIndex=170},box)
		corner(flash,26); tween(flash,0.15,{BackgroundTransparency=0.3}); task.wait(0.1); tween(flash,0.3,{BackgroundTransparency=1})
		local letters={"A","P","E","X"}
		local offsets={Vector2.new(-120,-80),Vector2.new(-40,-100),Vector2.new(40,-100),Vector2.new(120,-80)}
		local lparts={}
		for i,ch in ipairs(letters) do
			local lf=new("TextLabel",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,0,0.5,0),Size=UDim2.fromOffset(44,60),BackgroundTransparency=1,Text=ch,Font=F.GothamBlack,TextSize=52,TextColor3=T.G1,ZIndex=175},gate)
			gradient(lf,ACCENT,90); lparts[#lparts+1]=lf; local sc=new("UIScale",{Scale=1},lf)
			task.delay((i-1)*0.06,function()
				tween(lf,0.55,{Position=UDim2.new(0.5,offsets[i].X,0.5,offsets[i].Y),Rotation=math.random(-180,180),TextTransparency=1},BACK,Enum.EasingDirection.Out)
				tween(sc,0.55,{Scale=2.2},BACK)
			end)
		end
		for _=1,20 do
			local px=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,math.random(-10,10),0.5,math.random(-10,10)),
				Size=UDim2.fromOffset(math.random(5,12),math.random(5,12)),
				BackgroundColor3=math.random()>0.5 and T.G1 or T.G2,BorderSizePixel=0,ZIndex=174},gate)
			corner(px,"pill")
			tween(px,0.7,{Position=UDim2.new(0.5,math.random(-200,200),0.5,math.random(-200,200)),BackgroundTransparency=1,Size=UDim2.fromOffset(math.random(2,5),math.random(2,5))},Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
			task.delay(0.7,function() pcall(function() px:Destroy() end) end)
		end
		task.wait(0.6)
		for _,lf in ipairs(lparts) do pcall(function() lf:Destroy() end) end
		tween(boxSc,0.4,{Scale=0},BACK,Enum.EasingDirection.In)
		tween(gate,0.4,{BackgroundTransparency=1}); task.wait(0.45); gate:Destroy(); cb()
	end

	local verificado = false

	local function checkKey()
		if verificado then return end
		if (input.Text:gsub("%s+","")):lower() == KEY then
			verificado = true
			tween(inStroke,0.2,{Color=T.G1})
			task.wait(0.3)
			successAnim(function() runIntro() end)
		end
	end

	input:GetPropertyChangedSignal("Text"):Connect(function()
		if (input.Text:gsub("%s+","")):lower() == KEY then checkKey() end
	end)

	input.FocusLost:Connect(function(enter)
		tween(inStroke,0.2,{Color=T.Stroke})
		if enter and not verificado and (input.Text:gsub("%s+","")):lower() ~= KEY and input.Text ~= "" then
			tween(inStroke,0.15,{Color=T.Red})
			task.wait(1)
			tween(inStroke,0.3,{Color=T.Stroke})
		end
	end)
end

-- ===================== MENU PRINCIPAL =====================
local statusStates = { Stamina = false, Hunger = false, Thirst = false }
local isMenuOpen = false

-- Loop de Status (Savannah Life)
local function StartStatusLoop()
	task.spawn(function()
		local runService = game:GetService("RunService")
		runService.Heartbeat:Connect(function()
			if not statusStates.Stamina and not statusStates.Hunger and not statusStates.Thirst then return end
			local char = lp.Character
			if not char then return end
			
			local function ProcessObject(obj)
				for attrName, attrValue in pairs(obj:GetAttributes()) do
					if type(attrValue) == "number" then
						local lowerName = string.lower(attrName)
						local maxVal = attrValue < 100 and 100 or (attrValue * 2)
						if statusStates.Stamina and string.find(lowerName, "stamina") then
							obj:SetAttribute(attrName, maxVal)
						elseif statusStates.Hunger and (string.find(lowerName, "hunger") or string.find(lowerName, "food")) then
							obj:SetAttribute(attrName, maxVal)
						elseif statusStates.Thirst and (string.find(lowerName, "thirst") or string.find(lowerName, "water")) then
							obj:SetAttribute(attrName, maxVal)
						end
					end
				end
				for _, v in ipairs(obj:GetDescendants()) do
					if v:IsA("NumberValue") or v:IsA("IntValue") then
						local lowerName = string.lower(v.Name)
						if statusStates.Stamina and string.find(lowerName, "stamina") then
							v.Value = 999999
						elseif statusStates.Hunger and (string.find(lowerName, "hunger") or string.find(lowerName, "food")) then
							v.Value = 999999
						elseif statusStates.Thirst and (string.find(lowerName, "thirst") or string.find(lowerName, "water")) then
							v.Value = 999999
						end
					end
				end
			end
			
			ProcessObject(lp)
			ProcessObject(char)
			local backpack = lp:FindFirstChild("Backpack"); if backpack then ProcessObject(backpack) end
			local playerGui = lp:FindFirstChild("PlayerGui"); if playerGui then ProcessObject(playerGui) end
		end)
	end)
end
StartStatusLoop()

-- Funções para desenhar ícones vetoriais (sem emojis)
local function MakeIcon(parent, iconType)
	local container = new("Frame", {Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1}, parent)
	
	if iconType == "Stamina" then
		-- Ícone de Raio (Lightning)
		local p1 = new("Frame", {Size = UDim2.fromOffset(6, 14), Position = UDim2.fromOffset(10, 2), Rotation = 25, BackgroundColor3 = T.Gold, BorderSizePixel = 0}, container)
		corner(p1, 2)
		local p2 = new("Frame", {Size = UDim2.fromOffset(8, 12), Position = UDim2.fromOffset(6, 8), Rotation = -35, BackgroundColor3 = T.Gold, BorderSizePixel = 0}, container)
		corner(p2, 2)
		
	elseif iconType == "Hunger" then
		-- Ícone de Maçã/Fome (Círculo com cabinho)
		local apple = new("Frame", {Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(3, 4), BackgroundColor3 = T.Red, BorderSizePixel = 0}, container)
		corner(apple, "pill")
		local stem = new("Frame", {Size = UDim2.fromOffset(3, 6), Position = UDim2.fromOffset(11, 0), Rotation = 15, BackgroundColor3 = T.Green, BorderSizePixel = 0}, container)
		corner(stem, 1)
		
	elseif iconType == "Thirst" then
		-- Ícone de Gota (Sede)
		local drop = new("Frame", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(4, 6), BackgroundColor3 = T.Blue, BorderSizePixel = 0}, container)
		corner(drop, "pill")
		local tip = new("Frame", {Size = UDim2.fromOffset(11, 11), Position = UDim2.fromOffset(6.5, 1), Rotation = 45, BackgroundColor3 = T.Blue, BorderSizePixel = 0}, container)
		corner(tip, 2)
	end
	return container
end

-- Cria a Janela Principal
local mainWindow = new("Frame", {
	Size = UDim2.fromOffset(460, 300),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	AnchorPoint = Vector2.new(0.5, 0.5),
	BackgroundColor3 = T.Bg,
	Visible = false,
	ZIndex = 50
}, gui)
corner(mainWindow, 16)
stroke(mainWindow, T.Stroke, 1.5)
draggable(mainWindow, mainWindow)

-- Barra Lateral (Rail) para as abas
local rail = new("Frame", {
	Size = UDim2.new(0, 60, 1, 0),
	BackgroundColor3 = T.Rail,
	ZIndex = 51
}, mainWindow)
corner(rail, 16)

-- Aba Sem Nome (Apenas o ícone de raio nela)
local tabBtn = new("TextButton", {
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.fromOffset(8, 16),
	BackgroundColor3 = T.Row,
	Text = "",
	ZIndex = 52
}, rail)
corner(tabBtn, 10)
juice(tabBtn, 1.08)
-- Ícone vetorial para a aba (Raio)
MakeIcon(tabBtn, "Stamina").Position = UDim2.fromOffset(10, 10)

-- Container de conteúdo
local content = new("Frame", {
	Size = UDim2.new(1, -60, 1, 0),
	Position = UDim2.fromOffset(60, 0),
	BackgroundTransparency = 1,
	ZIndex = 51
}, mainWindow)
new("UIListLayout", {Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, HorizontalAlignment = Enum.HorizontalAlignment.Center}, content)
new("UIPadding", {PaddingTop = UDim.new(0, 20), PaddingLeft = UDim.new(0, 20), PaddingRight = UDim.new(0, 20)}, content)

-- Função de criar um Toggle Customizado
local function CreateToggle(title, iconType, statusKey)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 54),
		BackgroundColor3 = T.Card,
		ZIndex = 52
	}, content)
	corner(row, 12); stroke(row, T.Stroke, 1)
	
	-- Ícone
	MakeIcon(row, iconType).Position = UDim2.fromOffset(16, 15)
	
	-- Texto
	label(row, {
		Size = UDim2.new(1, -120, 1, 0),
		Position = UDim2.fromOffset(52, 0),
		Text = title,
		Font = F.GothamBold,
		TextSize = 14,
		ZIndex = 52
	})
	
	-- Switch / Toggle
	local switchBg = new("TextButton", {
		Size = UDim2.fromOffset(44, 24),
		Position = UDim2.new(1, -60, 0.5, -12),
		BackgroundColor3 = T.Row,
		Text = "",
		ZIndex = 53,
		AutoButtonColor = false
	}, row)
	corner(switchBg, "pill")
	stroke(switchBg, T.Stroke, 1.5)
	
	local knob = new("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = T.Sub,
		ZIndex = 54
	}, switchBg)
	corner(knob, "pill")
	
	local toggled = false
	switchBg.MouseButton1Click:Connect(function()
		toggled = not toggled
		statusStates[statusKey] = toggled
		
		if toggled then
			tween(switchBg, 0.2, {BackgroundColor3 = T.G1})
			tween(switchBg.UIStroke, 0.2, {Color = T.G1})
			tween(knob, 0.2, {Position = UDim2.fromOffset(23, 3), BackgroundColor3 = Color3.new(1,1,1)}, BACK)
		else
			tween(switchBg, 0.2, {BackgroundColor3 = T.Row})
			tween(switchBg.UIStroke, 0.2, {Color = T.Stroke})
			tween(knob, 0.2, {Position = UDim2.fromOffset(3, 3), BackgroundColor3 = T.Sub}, BACK)
		end
	end)
end

-- Adiciona os três Toggles na Aba
CreateToggle("Stamina Infinita", "Stamina", "Stamina")
CreateToggle("Fome Infinita", "Hunger", "Hunger")
CreateToggle("Sede Infinita", "Thirst", "Thirst")

-- Botão de fechar no canto da janela principal
local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(30, 30),
	Position = UDim2.new(1, -40, 0, 10),
	BackgroundColor3 = T.Row,
	Text = "X",
	TextColor3 = T.Red,
	Font = F.GothamBold,
	TextSize = 14,
	ZIndex = 55
}, mainWindow)
corner(closeBtn, 8)
juice(closeBtn, 1.1)

-- Lógica de fechar a janela
closeBtn.MouseButton1Click:Connect(function()
	if not isMenuOpen then return end
	isMenuOpen = false
	
	-- Animação de encolher a janela
	tween(mainWindow, 0.3, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1}, BACK, Enum.EasingDirection.In)
	task.wait(0.3)
	
	-- Reseta o tamanho para quando abrir de novo
	mainWindow.Visible = false
	mainWindow.Size = UDim2.fromOffset(460, 300)
	mainWindow.BackgroundTransparency = 0
	
	-- Traz o FAB de volta
	fab.Visible = true
	fabSc.Scale = 0
	TweenService:Create(fabSc, TweenInfo.new(0.4, BACK, Enum.EasingDirection.Out), {Scale = 1}):Play()
end)

-- Evento de clique no FAB para abrir o Menu Principal
fab.MouseButton1Click:Connect(function()
	if isMenuOpen then return end
	isMenuOpen = true
	
	-- Esconde o FAB
	tween(fabSc, 0.2, {Scale = 0}, BACK, Enum.EasingDirection.In)
	task.wait(0.2)
	fab.Visible = false
	fabSc.Scale = 1
	
	-- Calcula o tamanho adaptado para a tela (igual ao fitScale)
	local vp = workspace.CurrentCamera.ViewportSize
	local targetW = math.clamp(vp.X - 40, 320, 460)
	local targetH = math.clamp(vp.Y - 40, 240, 300)
	
	-- Abre a janela centralizada
	mainWindow.Visible = true
	mainWindow.Size = UDim2.fromOffset(0, 0)
	mainWindow.BackgroundTransparency = 1
	mainWindow.Position = UDim2.new(0.5, 0, 0.5, 0)
	
	-- Animação de expansão
	tween(mainWindow, 0.4, {
		Size = UDim2.fromOffset(targetW, targetH),
		BackgroundTransparency = 0
	}, BACK)
end)

-- Inicia o fluxo do script
runGate()
print("APEX HUB carregado com sucesso!")
