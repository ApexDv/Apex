--// ========== APEX HUB - PARTE 1: BASE ==========
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
local function nxt(parent) ord[parent]=ord[parent]+1; return ord[parent] end
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
--// ========== PARTE 2: ÍCONES ==========
local function iconTarget(ic)
	local egg=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(14,18),BackgroundTransparency=1},ic)
	corner(egg, UDim.new(0.5,0))
	local rs=new("UIStroke",{Thickness=2,Color=T.Sub,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},egg)
	return function(c) rs.Color=c end
end

local function iconCoin(ic)
	local coin=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(18,18),BackgroundTransparency=1},ic)
	corner(coin,"pill")
	local rs=new("UIStroke",{Thickness=2.5,Color=T.Gold,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},coin) -- CORRIGIDO
	local inner=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(6,6),BackgroundColor3=T.Gold,BorderSizePixel=0},coin)
	corner(inner,"pill")
	return function(c) rs.Color=c; inner.BackgroundColor3=c end
end

local function iconSpeed(ic)
	local p1=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,-2,0.5,0),Size=UDim2.fromOffset(4,12),Rotation=30,BackgroundColor3=T.Sub,BorderSizePixel=0},ic); corner(p1,"pill")
	local p2=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,4,0.5,0),Size=UDim2.fromOffset(4,10),Rotation=30,BackgroundColor3=T.Sub,BorderSizePixel=0},ic); corner(p2,"pill")
	return function(c) p1.BackgroundColor3=c; p2.BackgroundColor3=c end
end

local function iconLag(ic)
	local shield=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1},ic)
	corner(shield,"pill")
	local rs=new("UIStroke",{Thickness=2,Color=T.Sub,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},shield)
	local check1=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(10,12),Size=UDim2.fromOffset(6,2),Rotation=45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic); corner(check1,"pill")
	local check2=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(14,9),Size=UDim2.fromOffset(10,2),Rotation=-45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic); corner(check2,"pill")
	return function(c) rs.Color=c; check1.BackgroundColor3=c; check2.BackgroundColor3=c end
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

local function iconAuto(ic) -- NOVO: ícone de estrela (raridade)
	local star=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(16,16),BackgroundTransparency=1},ic)
	corner(star,"pill")
	local rs=new("UIStroke",{Thickness=2,Color=T.Sub,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},star)
	local bars={}
	for i=0,3 do
		local b=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(2,16),Rotation=i*45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic)
		corner(b,"pill"); bars[#bars+1]=b
	end
	return function(c) rs.Color=c; for _,b in ipairs(bars) do b.BackgroundColor3=c end end
end
--// ========== PARTE 4: JANELA PRINCIPAL ==========
local function fitScale()
	local vp = workspace.CurrentCamera.ViewportSize
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
gradient(new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.97,BorderSizePixel=0},root),
	ColorSequence.new(T.Bg,Color3.fromRGB(10,20,45)),90)

-- Header
local header = new("Frame",{Size=UDim2.new(1,0,0,54),BackgroundTransparency=1},root)
label(header,{Size=UDim2.fromOffset(120,28),Position=UDim2.fromOffset(20,13),Text="APEX HUB",Font=F.GothamBlack,TextSize=20,TextColor3=T.Text})
gradient(header:FindFirstChildWhichIsA("TextLabel"),ACCENT,0)
label(header,{Size=UDim2.fromOffset(200,16),Position=UDim2.fromOffset(20,34),Text="premium • v2.0",TextSize=11,TextColor3=T.Sub})

local statusDot = new("Frame",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-80,0.5,0),Size=UDim2.fromOffset(8,8),BackgroundColor3=T.Green,BorderSizePixel=0},header)
corner(statusDot,"pill")
loop(statusDot,0.9,{BackgroundTransparency=0.65})

local minBtn = new("TextButton",{AnchorPoint=Vector2.new(1,0.5),Position=UDim2.new(1,-20,0.5,0),Size=UDim2.fromOffset(26,26),
	BackgroundColor3=T.Row,Text="—",Font=F.GothamBold,TextSize=16,TextColor3=T.Text,AutoButtonColor=false},header)
corner(minBtn,"pill"); juice(minBtn,1.15)

draggable(header,root)

-- Rail (menu lateral)
local rail = new("Frame",{Size=UDim2.fromOffset(170,1),Position=UDim2.new(0,0,0,54),BackgroundTransparency=1},root)
rail.Size = UDim2.new(0,170,1,-54)
local railList = new("UIListLayout",{Padding=UDim.new(0,4),HorizontalAlignment=Enum.HorizontalAlignment.Center},rail)
new("UIPadding",{PaddingTop=UDim.new(0,10)},rail)

-- Pages
local pagesFrame = new("Frame",{Size=UDim2.new(1,-170,1,-54),Position=UDim2.fromOffset(170,54),BackgroundTransparency=1},root)
local pages = {}
local tabs = {}
local tabOrder = {}

local function addTab(name, subtitle, iconFn)
	local page = new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false},pagesFrame)
	pages[name] = page
	new("UIPadding",{PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14),PaddingTop=UDim.new(0,12),PaddingBottom=UDim.new(0,12)},page)
	local titleLbl = label(page,{Size=UDim2.new(1,0,0,22),Text=name,Font=F.GothamBold,TextSize=16,TextColor3=T.Text})
	local subLbl = label(page,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,22),Text=subtitle,TextSize=11,TextColor3=T.Sub})
	local contentY = 46
	local content = new("Frame",{Size=UDim2.new(1,0,1,-contentY),Position=UDim2.fromOffset(0,contentY),BackgroundTransparency=1},page)
	new("UIListLayout",{Padding=UDim.new(0,6)},content)
	page:SetAttribute("Content",nil)
	pages[name] = page
	pages[name].Content = content

	-- botão do rail
	local btn = new("TextButton",{Size=UDim2.new(1,-12,0,40),BackgroundColor3=T.Rail,Text="",AutoButtonColor=false},rail)
	corner(btn,10); stroke(btn,T.Stroke,1)
	local ic = new("Frame",{Size=UDim2.fromOffset(20,20),Position=UDim2.fromOffset(12,10),BackgroundTransparency=1},btn)
	local setIconColor = iconFn(ic)
	local txt = label(btn,{Size=UDim2.new(1,-48,0,40),Position=UDim2.fromOffset(42,0),Text=name,Font=F.GothamBold,TextSize=13})
	setIconColor(T.Sub)
	tabs[name] = {Btn=btn, Page=page, SetIcon=setIconColor, Text=txt}

	local function select()
		for n,t in pairs(tabs) do
			local active = (n == name)
			tween(t.Btn,0.2,{BackgroundColor3= active and T.Row or T.Rail})
			t.SetIcon(active and T.G1 or T.Sub)
			t.Text.TextColor3 = active and T.G1 or T.Text
			t.Page.Visible = active
		end
	end
	btn.Activated:Connect(select)
	tabOrder[#tabOrder+1] = name
	return select
end

local function selectTab(name) tabs[name].Btn:ActivatedFire() end -- fallback
local function row(parent, page, text, height)
	height = height or 44
	local r = new("Frame",{
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = T.Row, BorderSizePixel = 0
	}, parent)
	corner(r,10); stroke(r)
	local l = label(r,{Size=UDim2.new(1,-100,0,height),Position=UDim2.fromOffset(12,0),
		Text=text,Font=F.GothamBold,TextSize=13})
	return r, l
end

local function card(parent, side, title)
	local c = new("Frame",{
		Size = UDim2.new(0.5, -6, 1, 0),
		Position = side=="Left" and UDim2.new(0,0,0,0) or UDim2.new(0.5,6,0,0),
		BackgroundColor3 = T.Card, BorderSizePixel = 0,
		ClipsDescendants = true
	}, parent)
	corner(c,12); stroke(c)
	label(c,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(12,8),Text=title,Font=F.GothamBold,TextSize=13,TextColor3=T.G1})
	local inner = new("Frame",{Size=UDim2.new(1,-16,1,-42),Position=UDim2.fromOffset(8,38),BackgroundTransparency=1},c)
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
--// ========== PARTE 5: CONTROLES ==========
local function addToggle(c,page,text,default,cb)
	local r=row(c.Inner,c,text)
	local track=new("TextButton",{Size=UDim2.fromOffset(44,24),Position=UDim2.new(1,-58,0.5,-12),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},r)
	corner(track,"pill"); local ts=stroke(track,T.Stroke,1)
	local knob=new("Frame",{Size=UDim2.fromOffset(18,18),Position=UDim2.fromOffset(3,3),BackgroundColor3=T.Sub,BorderSizePixel=0},track); corner(knob,"pill")
	local on=false
	local function set(v,silent)
		on=v; tween(track,0.2,{BackgroundColor3=v and T.G2 or T.Row}); tween(ts,0.2,{Color=v and T.G1 or T.Stroke})
		tween(knob,0.28,{Position=v and UDim2.fromOffset(23,3) or UDim2.fromOffset(3,3),BackgroundColor3=v and Color3.new(1,1,1) or T.Sub},BACK)
		if not silent then task.spawn(cb,v) end
	end
	track.Activated:Connect(function() set(not on) end)
	if default then set(true,true) end
	return set
end

local function addButton(c,page,text,cb)
	local r=row(c.Inner,c,text,52); r:FindFirstChildOfClass("TextLabel"):Destroy()
	local b=primary(r,{Size=UDim2.new(1,-24,0,36),Position=UDim2.fromOffset(12,9),Text=text,Font=F.GothamBlack,TextSize=12,TextColor3=T.Bg})
	b.Activated:Connect(function() task.spawn(cb) end); return b
end

local function addSlider(c,page,text,min,max,default,cb)
	local r,l=row(c.Inner,c,text,56); l.Size=UDim2.new(1,-80,0,32)
	local val=label(r,{Size=UDim2.fromOffset(56,32),Position=UDim2.new(1,-72,0,0),Text=tostring(default),Font=F.GothamBold,TextColor3=T.G1,TextXAlignment=RIGHT})
	local bar=new("TextButton",{Size=UDim2.new(1,-32,0,10),Position=UDim2.new(0,16,0,38),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},r); corner(bar,"pill")
	local fill=new("Frame",{Size=UDim2.fromScale((default-min)/(max-min),1),BackgroundColor3=Color3.new(1,1,1)},bar)
	corner(fill,"pill"); gradient(fill,ACCENT,0)
	local knob=new("Frame",{Size=UDim2.fromOffset(18,18),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(1,0,0.5,0),BackgroundColor3=Color3.new(1,1,1)},fill)
	corner(knob,"pill"); stroke(knob,T.G2,2); local ks=new("UIScale",{Scale=1},knob)
	local function setValue(v) v=math.clamp(v,min,max); fill.Size=UDim2.fromScale((v-min)/(max-min),1); val.Text=tostring(v); return v end
	local dragging=false
	local function update(x) local a=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1); task.spawn(cb,setValue(math.floor(min+(max-min)*a+0.5))) end
	bar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; update(i.Position.X); tween(ks,0.15,{Scale=1.3},BACK)
			i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false; tween(ks,0.2,{Scale=1},BACK) end end)
		end
	end)
	UIS.InputChanged:Connect(function(i) if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end end)
	return function(v,silent) v=setValue(v); if not silent then task.spawn(cb,v) end end
end

local function controlRow(c,page,leftText,rightText,onLeft,onRight)
	local r=row(c.Inner,c,leftText.."/"..rightText,54); r:FindFirstChildOfClass("TextLabel"):Destroy()
	local l=new("TextButton",{Size=UDim2.new(0.5,-16,0,38),Position=UDim2.fromOffset(12,10),BackgroundColor3=Color3.fromRGB(20,100,50),Text=leftText,Font=F.GothamBlack,TextSize=13,TextColor3=Color3.new(1,1,1),AutoButtonColor=false},r)
	corner(l,"pill"); gradient(l,ColorSequence.new(Color3.fromRGB(50,255,100),Color3.fromRGB(0,150,50)),20); juice(l,1.04)
	stroke(l,T.Green,1,0.5)
	local rt=new("TextButton",{Size=UDim2.new(0.5,-16,0,38),Position=UDim2.new(0.5,4,0,10),BackgroundColor3=Color3.fromRGB(100,20,20),Text=rightText,Font=F.GothamBlack,TextSize=13,TextColor3=Color3.new(1,1,1),AutoButtonColor=false},r)
	corner(rt,"pill"); gradient(rt,ColorSequence.new(Color3.fromRGB(255,80,80),Color3.fromRGB(150,20,20)),20); juice(rt,1.04)
	stroke(rt,T.Red,1,0.5)
	l.Activated:Connect(onLeft); rt.Activated:Connect(onRight)
	return l,rt
end
--// ========== PARTE 6: ABAS ==========
addTab("Alvo",       "Escolha o ovo e o modo", iconTarget)
addTab("Coin",       "Farm de moedas automático", iconCoin)
addTab("Auto",       "Escolha as raridades alvo", iconAuto)
addTab("Velocidade", "Ajuste de velocidade", iconSpeed)
addTab("Anti-Lag",   "Otimização do jogo", iconLag)
addTab("Config",     "Ajustes do painel", iconGear)

local pAlvo  = pages["Alvo"].Content
local pCoin  = pages["Coin"].Content
local pAuto  = pages["Auto"].Content
local pSpeed = pages["Velocidade"].Content
local pLag   = pages["Anti-Lag"].Content
local pCfg   = pages["Config"].Content

-- Aba Alvo
local cAlvoL = card(pAlvo,"Left","Alvo")
controlRow(cAlvoL,pAlvo,"Ativar","Parar",function()
	toast({Title="Alvo",Body="Ativado",Color=T.Green})
end,function()
	toast({Title="Alvo",Body="Parado",Color=T.Red})
end)
addToggle(cAlvoL,pAlvo,"Auto Target",false,function(on)
	toast({Title="Auto Target",Body=on and "ON" or "OFF",Color=T.G1})
end)

local cAlvoR = card(pAlvo,"Right","Modo")
addToggle(cAlvoR,pAlvo,"Modo Rápido",false,function() end)
addSlider(cAlvoR,pAlvo,"Alcance",10,200,50,function(v) end)

-- Aba Coin
local cCoin = card(pCoin,"Left","Auto Farm")
addToggle(cCoin,pCoin,"Ativar Farm",false,function(on)
	if on then toast({Title="Farm",Body="Farm ativado!",Color=T.Gold,Duration=3}) end
end)
addButton(cCoin,pCoin,"Ir para o Mapa",function()
	toast({Title="Teleporte",Body="Indo para o mapa...",Color=T.G1,Duration=3})
end)

local cCoin2 = card(pCoin,"Right","Status")
local coinLbl = addInfo(cCoin2,pCoin,"Moedas no Banco","0")
task.spawn(function()
	local n = 0
	while true do
		task.wait(2); n = n + math.random(1,5)
		pcall(function() coinLbl.Text = tostring(n) end)
	end
end)

-- Aba Auto
local cAutoL = card(pAuto,"Left","Raridades")
for _, r in ipairs({"Comum","Raro","Épico","Lendário","Mítico"}) do
	addToggle(cAutoL,pAuto,r,false,function() end)
end
local cAutoR = card(pAuto,"Right","Ações")
addButton(cAutoR,pAuto,"Ativar Tudo",function() toast({Title="Auto",Body="Todas ativas",Color=T.G1}) end)
addButton(cAutoR,pAuto,"Desativar Tudo",function() toast({Title="Auto",Body="Todas off",Color=T.Red}) end)

-- Aba Velocidade
local cSpd = card(pSpeed,"Left","Velocidade")
addSlider(cSpd,pSpeed,"Velocidade",16,200,16,function(v) end)
addToggle(cSpd,pSpeed,"Ativar Speed",false,function() end)
local cSpdR = card(pSpeed,"Right","Extra")
addSlider(cSpdR,pSpeed,"Pulo",50,300,50,function() end)
addButton(cSpdR,pSpeed,"Resetar",function() toast({Title="Reset",Body="Valores padrão",Color=T.G1}) end)

-- Aba Anti-Lag
local cLag = card(pLag,"Left","Otimização")
addToggle(cLag,pLag,"Anti-Lag",false,function(on)
	toast({Title="Anti-Lag",Body=on and "Ativado" or "Desativado",Color=T.Green})
end)
addToggle(cLag,pLag,"Reduzir Partículas",false,function() end)
local cLagR = card(pLag,"Right","FPS")
addInfo(cLagR,pLag,"FPS Atual","60")
addButton(cLagR,pLag,"Limpar Cache",function() toast({Title="Cache",Body="Limpo",Color=T.G1}) end)

-- Aba Config
local cCfg = card(pCfg,"Left","Painel")
addButton(cCfg,pCfg,"Fechar Painel",function() -- será ligado ao setOpen depois
end)
addToggle(cCfg,pCfg,"Salvar Config",true,function() end)
local cCfgR = card(pCfg,"Right","Sobre")
addInfo(cCfgR,pCfg,"Versão","2.0")
addInfo(cCfgR,pCfg,"Autor","Apex Hub")
--// ========== PARTE 7: FAB, INTRO, GATE ==========
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
tabs["Alvo"].Btn:ActivatedFire and nil -- ignora
tabs["Alvo"].Btn.Activated:Fire and nil
-- Seleciona primeira aba:
for n,t in pairs(tabs) do
	local active = (n=="Alvo")
	t.Btn.BackgroundColor3 = active and T.Row or T.Rail
	t.SetIcon(active and T.G1 or T.Sub)
	t.Text.TextColor3 = active and T.G1 or T.Text
	t.Page.Visible = active
end

-- Ligar botão "Fechar Painel" da config
for _,b in ipairs(pCfg:GetDescendants()) do
	if b:IsA("TextButton") and b.Text=="Fechar Painel" then
		b.Activated:Connect(function() setOpen(false) end)
	end
end

-- INTRO
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

	label(box,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,90),Text="APEX HUB",Font=F.GothamBlack,TextSize=21,TextXAlignment=CENTER})
	label(box,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,117),Text="Digite sua key para continuar",TextSize=12,TextColor3=T.Sub,TextXAlignment=CENTER})

	local inWrap=new("Frame",{Size=UDim2.new(1,-48,0,44),Position=UDim2.fromOffset(24,146),BackgroundColor3=T.Row},box); corner(inWrap,"pill")
	local inStroke=stroke(inWrap,T.Stroke,1.5)
	local input=new("TextBox",{Size=UDim2.new(1,-64,1,0),Position=UDim2.fromOffset(48,0),BackgroundTransparency=1,Text="",PlaceholderText="Cole ou digite a key",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=F.GothamBold,TextSize=14,ClearTextOnFocus=false,TextXAlignment=LEFT},inWrap)

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

-- Spinner loop global
RunService.RenderStepped:Connect(function(dt)
	for _,s in ipairs(spinners) do
		if s[1] and s[1].Parent then s[1].Rotation = (s[1].Rotation + s[2]*dt) % 360 end
	end
end)

runGate()
print("APEX HUB Premium carregado!")
