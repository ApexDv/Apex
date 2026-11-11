local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local CoreGui      = game:GetService("CoreGui")

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
	Red=Color3.fromRGB(255,100,110), Green=Color3.fromRGB(85, 255, 127),
	Blue=Color3.fromRGB(80,160,255), Purple=Color3.fromRGB(175,95,255),
	Gold=Color3.fromRGB(255,215,0),
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
local ord=setmetatable({},{__index=function() return 0 end})
local spinners={}
local function spin(g,speed) spinners[#spinners+1]={g,speed}; return g end
local function particles(parent,n)
	for _=1,n do
		local s=math.random(3,7)
		local p=new("Frame",{Size=UDim2.fromOffset(s,s),Position=UDim2.new(math.random(),0,1.05,0),
			BackgroundColor3=T.G1,BackgroundTransparency=1,BorderSizePixel=0},parent)
		corner(p,"pill")
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
local function iconCoin(ic)
	local coin=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1},ic)
	corner(coin,"pill")
	local rs=new("UIStroke",{Thickness=2.5,Color=T.Gold,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},coin)
	local inner=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(6,6),BackgroundColor3=T.Gold,BorderSizePixel=0},coin)
	corner(inner,"pill")
	return function(c) rs.Color=c; inner.BackgroundColor3=c end
end
local function iconGear(ic)
	local ring=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1},ic)
	corner(ring,"pill")
	local rs=new("UIStroke",{Thickness=2.2,Color=T.Sub,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},ring)
	local teeth={}
	for i=0,7 do
		local a=math.rad(i*45)
		local t=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,math.sin(a)*8,0.5,-math.cos(a)*8),Size=UDim2.fromOffset(4,4),Rotation=i*45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic)
		corner(t,1); teeth[#teeth+1]=t
	end
	return function(c) rs.Color=c; for _,t in ipairs(teeth) do t.BackgroundColor3=c end end
end
local gui = new("ScreenGui",{
	Name="ApexHub", ResetOnSpawn=false,
	ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true
})
if not pcall(function() gui.Parent = CoreGui end) then
	gui.Parent = lp:WaitForChild("PlayerGui")
end
gui.DisplayOrder = 999

local toastHolder = new("Frame",{
	AnchorPoint=Vector2.new(0.5,0), Position=UDim2.new(0.5,0,0,20),
	Size=UDim2.fromOffset(320,0), BackgroundTransparency=1
}, gui)
new("UIListLayout",{Padding=UDim.new(0,8),HorizontalAlignment=Enum.HorizontalAlignment.Center},toastHolder)

local function toast(opts)
	local box=new("Frame",{Size=UDim2.fromOffset(320,60),BackgroundColor3=T.Card,BorderSizePixel=0},toastHolder)
	corner(box,12); stroke(box,opts.Color or T.G1,1.5)
	local acc=new("Frame",{Size=UDim2.fromOffset(4,40),Position=UDim2.fromOffset(10,10),BackgroundColor3=opts.Color or T.G1,BorderSizePixel=0},box)
	corner(acc,"pill")
	label(box,{Size=UDim2.new(1,-30,0,18),Position=UDim2.fromOffset(24,8),Text=opts.Title or "Info",Font=F.GothamBold,TextSize=13,TextColor3=opts.Color or T.G1})
	label(box,{Size=UDim2.new(1,-30,0,28),Position=UDim2.fromOffset(24,26),Text=opts.Body or "",TextSize=11,TextColor3=T.Sub,TextWrapped=true})
	local sc=new("UIScale",{Scale=0},box)
	tween(sc,0.35,{Scale=1},BACK)
	task.delay(opts.Duration or 3,function()
		tween(sc,0.25,{Scale=0},BACK,Enum.EasingDirection.In)
		task.wait(0.3); box:Destroy()
	end)
end

local function primary(parent,props)
	local b=new("TextButton",props,parent)
	b.BackgroundColor3=Color3.new(1,1,1); b.AutoButtonColor=false
	corner(b,"pill"); spin(gradient(b,ACCENT,20),40); juice(b,1.04)
	return b
end
local function fitScale()
	local cam = workspace.CurrentCamera
	if not cam then return 1 end
	local vp = cam.ViewportSize
	return math.min(vp.X/1000, vp.Y/650) * 0.95
end

local rootSc = Instance.new("UIScale")
local root = new("Frame",{
	AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.fromScale(0.5,0.5),
	Size=UDim2.fromOffset(880,520), BackgroundColor3=T.Bg, BorderSizePixel=0,
	Visible=false, ClipsDescendants=true
}, gui)
rootSc.Parent = root; rootSc.Scale = 1
corner(root,16); stroke(root,T.Stroke,1.5)

local header = new("Frame",{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1},root)
local logoLbl = label(header,{Size=UDim2.fromOffset(120,28),Position=UDim2.fromOffset(20,13),Text="APEX HUB",Font=F.GothamBlack,TextSize=20,TextColor3=T.Text})
gradient(logoLbl,ACCENT,0)
label(header,{Size=UDim2.fromOffset(200,16),Position=UDim2.fromOffset(20,34),Text="premium • v2.0",TextSize=11,TextColor3=T.Sub})

local statusDot = new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-80,0.5,0),Size=UDim2.fromOffset(8,8),BackgroundColor3=T.Green,BorderSizePixel=0},header)
corner(statusDot,"pill"); loop(statusDot,0.9,{BackgroundTransparency=0.65})

local minBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-20,0.5,0),Size=UDim2.fromOffset(26,26),
	BackgroundColor3=T.Row,Text="—",Font=F.GothamBold,TextSize=16,TextColor3=T.Text,AutoButtonColor=false},header)
corner(minBtn,"pill"); juice(minBtn,1.15)
draggable(header,root)

local rail = new("Frame",{Size=UDim2.new(0,170,1,-54),Position=UDim2.fromOffset(0,54),BackgroundTransparency=1},root)
new("UIListLayout",{Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Center},rail)
new("UIPadding",{PaddingTop=UDim.new(0,10)},rail)

local pagesFrame = new("Frame",{Size=UDim2.new(1,-170,1,-54),Position=UDim2.fromOffset(170,54),BackgroundTransparency=1},root)
local pages = {}
local tabs = {}
local tabOrder = {}

local function addTab(name, subtitle, iconFn)
	local page = new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},pagesFrame)
	new("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)},page)
	label(page,{Size=UDim2.new(1,0,0,22),Text=name,Font=F.GothamBold,TextSize=16,TextColor3=T.Text})
	label(page,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,22),Text=subtitle,TextSize=11,TextColor3=T.Sub})
	local content = new("Frame",{Size=UDim2.new(1,0,1,-46),Position=UDim2.fromOffset(0,46),BackgroundTransparency=1},page)
	pages[name] = page
	pages[name].Content = content

	local btn = new("TextButton",{Size=UDim2.new(1,-12,0,40),BackgroundColor3=T.Rail,Text="",AutoButtonColor=false},rail)
	corner(btn,10); stroke(btn,T.Stroke,1)
	local ic = new("Frame",{Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(12,10),BackgroundTransparency=1},btn)
	local setIconColor = iconFn(ic)
	local txt = label(btn,{Size=UDim2.new(1,-48,0,40),Position=UDim2.fromOffset(42,0),Text=name,Font=F.GothamBold,TextSize=13})
	setIconColor(T.Sub)
	tabs[name] = {Btn=btn, Page=page, SetIcon=setIconColor, Text=txt}

	btn.Activated:Connect(function()
		for n,t in pairs(tabs) do
			local active = (n == name)
			tween(t.Btn,0.2,{BackgroundColor3= active and T.Row or T.Rail})
			t.SetIcon(active and T.G1 or T.Sub)
			t.Text.TextColor3 = active and T.G1 or T.Text
			t.Page.Visible = active
		end
	end)
	tabOrder[#tabOrder+1] = name
end

local function row(parent, page, text, height)
	height = height or 44
	local r = new("Frame",{Size = UDim2.new(1, 0, 0, height),BackgroundColor3 = T.Row, BorderSizePixel = 0}, parent)
	corner(r,10); stroke(r)
	local l = label(r,{Size=UDim2.new(1,-100,0,height),Position=UDim2.fromOffset(12,0),Text=text,Font=F.GothamBold,TextSize=13})
	return r, l
end

local function card(parent, side, title)
	local c = new("Frame",{
		Size = UDim2.new(0.5, -6, 1, 0),
		Position = side=="Left" and UDim2.new(0,0,0,0) or UDim2.new(0.5,6,0,0),
		BackgroundColor3 = T.Card, BorderSizePixel = 0, ClipsDescendants = true
	}, parent)
	corner(c,12); stroke(c)
	label(c,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(12,8),Text=title,Font=F.GothamBold,TextSize=13,TextColor3=T.G1})
	local inner = new("Frame",{Size=UDim2.new(1,-16,1,-46),Position=UDim2.fromOffset(8,42),BackgroundTransparency=1},c)
	new("UIListLayout",{Padding=UDim.new(0,6)},inner)
	c.Inner = inner
	return c
end

local function addInfo(c, page, title, val)
	local r = new("Frame",{Size=UDim2.new(1,0,0,40),BackgroundColor3=T.Row,BorderSizePixel=0},c.Inner)
	corner(r,8); stroke(r)
	label(r,{Size=UDim2.new(1,-16,0,16),Position=UDim2.fromOffset(10,6),Text=title,TextSize=11,TextColor3=T.Sub})
	local v = label(r,{Size=UDim2.new(1,-16,0,18),Position=UDim2.fromOffset(10,20),Text=val,Font=F.GothamBold,TextSize=14,TextColor3=T.Text})
	return v
end
local function addToggle(c,page,text,default,cb)
	local r=row(c.Inner,c,text)
	local track=new("TextButton",{Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},r)
	corner(track,"pill"); local ts=stroke(track,T.Stroke,1)
	local knob=new("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),BackgroundColor3=T.Sub,BorderSizePixel=0},track); corner(knob,"pill")
	local on=false
	local function set(v,silent)
		on=v; tween(track,0.2,{BackgroundColor3=v and T.G2 or T.Row}); tween(ts,0.2,{Color=v and T.G1 or T.Stroke})
		tween(knob,0.28,{Position=v and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3),BackgroundColor3=v and Color3.new(1,1,1) or T.Sub},BACK)
		if not silent then task.spawn(function() pcall(cb,v) end) end
	end
	track.Activated:Connect(function() set(not on) end)
	if default then set(true,true) end
	return set
end

local function addButton(c,page,text,cb)
	local r=row(c.Inner,c,text,52)
	local lbl=r:FindFirstChildOfClass("TextLabel"); if lbl then lbl:Destroy() end
	local b=primary(r,{Size=UDim2.new(1,-24,0,36),Position=UDim2.fromOffset(12,9),Text=text,Font=F.GothamBlack,TextSize=12,TextColor3=T.Bg})
	b.Activated:Connect(function() task.spawn(function() pcall(cb) end) end); return b
end

local function addSlider(c,page,text,min,max,default,cb)
	local r,l=row(c.Inner,c,text,56)
	if l then l.Size=UDim2.new(1,-80,0,32) end
	local val=label(r,{Size=UDim2.fromOffset(56,32),Position=UDim2.new(1,-72,0,0),Text=tostring(default),Font=F.GothamBold,TextColor3=T.G1,TextXAlignment=RIGHT})
	local bar=new("TextButton",{Size=UDim2.new(1,-32,0,10),Position=UDim2.new(0,16,0,38),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},r); corner(bar,"pill")
	local fill=new("Frame",{Size=UDim2.fromScale((default-min)/(max-min),1),BackgroundColor3=Color3.new(1,1,1)},bar)
	corner(fill,"pill"); gradient(fill,ACCENT,0)
	local knob=new("Frame",{Size=UDim2.fromOffset(18,18),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(1,0,0.5,0),BackgroundColor3=Color3.new(1,1,1)},fill)
	corner(knob,"pill"); stroke(knob,T.G2,2); local ks=new("UIScale",{Scale=1},knob)
	local function setValue(v) v=math.clamp(v,min,max); fill.Size=UDim2.fromScale((v-min)/(max-min),1); val.Text=tostring(v); return v end
	local dragging=false
	local function update(x) local a=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); task.spawn(function() pcall(cb,setValue(math.floor(min+(max-min)*a+0.5))) end) end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; update(i.Position.X); tween(ks,0.15,{Scale=1.3},BACK)
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; tween(ks,0.2,{Scale=1},BACK) end end)
		end
	end)
	UIS.InputChanged:Connect(function(i) if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end end)
	return function(v,silent) v=setValue(v); if not silent then task.spawn(function() pcall(cb,v) end) end end
end
addTab("Coin",   "Farm de moedas MM2", iconCoin)
addTab("Config", "Ajustes do painel", iconGear)

local pCoin = pages["Coin"].Content
local pCfg  = pages["Config"].Content

_G.farmRunning = false
_G.farmInterval = 0.5

local function getCoinsContainer()
	local found = workspace:FindFirstChild("CoinContainer")
	if found then return found end
	for _,v in ipairs(workspace:GetChildren()) do
		if v.Name == "CoinContainer" or v:FindFirstChild("CoinContainer") then
			return v:FindFirstChild("CoinContainer") or v
		end
	end
	return nil
end

local function getNearestCoin(hrp)
	local container = getCoinsContainer()
	if not container or not hrp then return nil end
	local nearest, dist = nil, math.huge
	for _,coin in ipairs(container:GetChildren()) do
		local part = coin:IsA("BasePart") and coin or coin:FindFirstChildWhichIsA("BasePart")
		if part and part.Transparency < 0.9 and part.Parent then
			local d = (hrp.Position - part.Position).Magnitude
			if d < dist then dist = d; nearest = part end
		end
	end
	return nearest
end

local cCoinL = card(pCoin,"Left","Auto Farm")

addToggle(cCoinL,pCoin,"Ativar Farm",false,function(on)
	_G.farmRunning = on
	if on then
		toast({Title="Farm MM2",Body="Ativado!",Color=T.Gold,Duration=2})
		task.spawn(function()
			while _G.farmRunning do
				local char = lp.Character
				local hrp = char and char:FindFirstChild("HumanoidRootPart")
				if hrp then
					local coin = getNearestCoin(hrp)
					if coin then
						pcall(function()
							hrp.CFrame = coin.CFrame + Vector3.new(0,2,0)
						end)
					end
				end
				task.wait(_G.farmInterval)
			end
		end)
	else
		toast({Title="Farm MM2",Body="Desativado",Color=T.Red,Duration=2})
	end
end)

addSlider(cCoinL,pCoin,"Intervalo (s)",1,10,1,function(v)
	_G.farmInterval = v
end)

addButton(cCoinL,pCoin,"Coletar Agora",function()
	local char = lp.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local coin = getNearestCoin(hrp)
		if coin then
			pcall(function() hrp.CFrame = coin.CFrame + Vector3.new(0,2,0) end)
			toast({Title="Coleta",Body="Moeda coletada!",Color=T.Gold,Duration=2})
		else
			toast({Title="Coleta",Body="Nenhuma moeda próxima",Color=T.Red,Duration=2})
		end
	else
		toast({Title="Coleta",Body="Personagem não encontrado",Color=T.Red,Duration=2})
	end
end)

local cCoinR = card(pCoin,"Right","Status")
local coinLbl  = addInfo(cCoinR,pCoin,"Moedas no Mapa","0")
local statusLbl = addInfo(cCoinR,pCoin,"Status","Parado")

task.spawn(function()
	while true do
		task.wait(1)
		pcall(function()
			if statusLbl and statusLbl.Parent then
				statusLbl.Text = _G.farmRunning and "Farmando..." or "Parado"
			end
			if coinLbl and coinLbl.Parent then
				local container = getCoinsContainer()
				coinLbl.Text = container and tostring(#container:GetChildren()) or "0"
			end
		end)
	end
end)

local cCfgL = card(pCfg,"Left","Painel")
local closeBtn = addButton(cCfgL,pCfg,"Fechar Painel",function() end)
addToggle(cCfgL,pCfg,"Salvar Config",true,function() end)

local cCfgR = card(pCfg,"Right","Sobre")
addInfo(cCfgR,pCfg,"Versão","2.0")
addInfo(cCfgR,pCfg,"Jogo","MM2")
addInfo(cCfgR,pCfg,"Autor","Apex Hub")
local fabSc = Instance.new("UIScale")
local fab = new("TextButton",{
	AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-24,1,-24),
	Size=UDim2.fromOffset(58,58), BackgroundColor3=Color3.new(1,1,1),
	Text="A", Font=F.GothamBlack, TextSize=26, TextColor3=T.Bg,
	AutoButtonColor=false, Visible=false
}, gui)
corner(fab,"pill"); stroke(fab,T.G1,2); spin(gradient(fab,ACCENT,45),60)
fabSc.Parent = fab; juice(fab,1.1)

local open=false
local function setOpen(v)
	open=v
	if v then
		root.Visible=true; rootSc.Scale=0
		tween(rootSc,0.55,{Scale=fitScale()},BACK)
		for i,n in ipairs(tabOrder) do
			local b=tabs[n].Btn; local sc=b:FindFirstChildOfClass("UIScale")
			if sc then sc.Scale=0; task.delay(0.2+(i-1)*0.07,function() tween(sc,0.4,{Scale=1},BACK) end) end
		end
	else
		tween(rootSc,0.25,{Scale=0},BACK,Enum.EasingDirection.In)
		task.delay(0.27,function() if not open then root.Visible=false end end)
	end
end

local fabStart
fab.InputBegan:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fabStart=fab.AbsolutePosition end
end)
fab.InputEnded:Connect(function()
	if fabStart and(fab.AbsolutePosition-fabStart).Magnitude<6 then setOpen(not open) end; fabStart=nil
end)
minBtn.Activated:Connect(function() setOpen(false) end)
if closeBtn then closeBtn.Activated:Connect(function() setOpen(false) end) end

for n,t in pairs(tabs) do
	local active = (n=="Coin")
	t.Btn.BackgroundColor3 = active and T.Row or T.Rail
	t.SetIcon(active and T.G1 or T.Sub)
	t.Text.TextColor3 = active and T.G1 or T.Text
	t.Page.Visible = active
end

RunService.RenderStepped:Connect(function(dt)
	for _,s in ipairs(spinners) do
		if s[1] and s[1].Parent then s[1].Rotation = (s[1].Rotation + s[2]*dt) % 360 end
	end
end)

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
		Text="A P E X   H U B   M M 2",Font=F.GothamBold,TextSize=18,TextColor3=T.Sub,TextTransparency=1,ZIndex=151},box)
	local bestSc=new("UIScale",{Scale=0.6},best)

	task.spawn(function()
		for i,p in ipairs(parts) do
			task.delay((i-1)*0.2,function()
				tween(p[1],0.5,{TextTransparency=0})
				TweenService:Create(p[2],TweenInfo.new(0.8,BACK,Enum.EasingDirection.Out),{Scale=1}):Play()
			end)
		end
		task.wait(1.2); tween(line,0.8,{Size=UDim2.fromOffset(300,3)}); tween(best,0.8,{TextTransparency=0})
		TweenService:Create(bestSc,TweenInfo.new(0.8,BACK,Enum.EasingDirection.Out),{Scale=1}):Play()
		task.wait(2.0)
		for _,p in ipairs(parts) do tween(p[1],0.6,{TextTransparency=1}) end
		tween(best,0.6,{TextTransparency=1}); tween(line,0.6,{Size=UDim2.fromOffset(0,3)})
		task.wait(0.5); tween(splash,0.6,{BackgroundTransparency=1}); sg.Enabled=false
		task.wait(0.6); splash:Destroy(); fabSc.Scale=0; fab.Visible=true
		TweenService:Create(fabSc,TweenInfo.new(0.6,BACK,Enum.EasingDirection.Out),{Scale=1}):Play()
		task.wait(0.4); setOpen(true)
	end)
end

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

	label(box,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,90),Text="APEX HUB MM2",Font=F.GothamBlack,TextSize=21,TextXAlignment=CENTER})
	label(box,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,117),Text="Digite sua key para continuar",TextSize=12,TextColor3=T.Sub,TextXAlignment=CENTER})

	local inWrap=new("Frame",{Size=UDim2.new(1,-48,0,44),Position=UDim2.fromOffset(24,146),BackgroundColor3=T.Row},box); corner(inWrap,"pill")
	local inStroke=stroke(inWrap,T.Stroke,1.5)
	local input=new("TextBox",{Size=UDim2.new(1,-24,1,0),Position=UDim2.fromOffset(24,0),BackgroundTransparency=1,Text="",PlaceholderText="Cole ou digite a key",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=F.GothamBold,TextSize=14,ClearTextOnFocus=false,TextXAlignment=LEFT},inWrap)

	local verificado = false
	local function checkKey()
		if verificado then return end
		if (input.Text:gsub("%s+","")):lower() == KEY then
			verificado = true
			tween(inStroke,0.2,{Color=T.G1})
			task.wait(0.3)
			tween(boxSc,0.4,{Scale=0},BACK,Enum.EasingDirection.In)
			tween(gate,0.4,{BackgroundTransparency=1}); task.wait(0.45); gate:Destroy(); runIntro()
		end
	end
	input:GetPropertyChangedSignal("Text"):Connect(function()
		if (input.Text:gsub("%s+","")):lower() == KEY then checkKey() end
	end)
end

runGate()
