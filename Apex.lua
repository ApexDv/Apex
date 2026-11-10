local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local KEY = "apex"
local lp = Players.LocalPlayer
local F = Enum.Font
local LEFT, CENTER = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center
local BACK, SINE = Enum.EasingStyle.Back, Enum.EasingStyle.Sine

local T = {
	Bg=Color3.fromRGB(5,8,18), Rail=Color3.fromRGB(8,13,27), Card=Color3.fromRGB(12,20,38),
	Row=Color3.fromRGB(18,30,52), Stroke=Color3.fromRGB(32,55,90),
	G1=Color3.fromRGB(65,165,255), G2=Color3.fromRGB(20,95,220),
	Text=Color3.fromRGB(235,255,242), Sub=Color3.fromRGB(135,175,220),
	Red=Color3.fromRGB(255,100,110), Orange=Color3.fromRGB(255,160,50),
	Blue=Color3.fromRGB(80,160,255), Purple=Color3.fromRGB(175,95,255),
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
		local p=new("Frame",{Size=UDim2.fromOffset(s,s),Position=UDim2.new(math.random(),0,1.05,0),BackgroundColor3=T.G1,BackgroundTransparency=1,BorderSizePixel=0},parent)
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

local function chev(parent,tx,ty,dir,col,L,th)
	L=L or 8; th=th or 2.5; local d=L/2*0.7071; local bars={}
	local function bar(cx,cy,rot)
		local b=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(cx,cy),Size=UDim2.fromOffset(L,th),Rotation=rot,BackgroundColor3=col,BorderSizePixel=0},parent)
		corner(b,"pill"); bars[#bars+1]=b
	end
	if dir=="right" then bar(tx-d,ty-d,45); bar(tx-d,ty+d,-45) else bar(tx-d,ty-d,45); bar(tx+d,ty-d,-45) end
	return bars
end

-- ÍCONES DAS ABAS
local function iconTarget(ic)
	local ring=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(20,20),BackgroundTransparency=1},ic)
	corner(ring,"pill")
	local rs=new("UIStroke",{Thickness=2,Color=T.Sub,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},ring)
	local dot=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(7,7),BackgroundColor3=T.Sub,BorderSizePixel=0},ic)
	corner(dot,"pill")
	return function(c) rs.Color=c; dot.BackgroundColor3=c end
end
local function iconAuto(ic)
	local a=chev(ic,26,20,"right",T.Sub,9,2.6); local b=chev(ic,18,20,"right",T.Sub,9,2.6)
	return function(c) for _,x in ipairs(a) do x.BackgroundColor3=c end; for _,x in ipairs(b) do x.BackgroundColor3=c end end
end
local function iconSpeed(ic)
	local bars={}
	for i,w in ipairs({18,13,8}) do
		local b=new("Frame",{Size=UDim2.fromOffset(w,3),Position=UDim2.fromOffset(11,12+(i-1)*6),BackgroundColor3=T.Sub,BorderSizePixel=0},ic)
		corner(b,"pill"); bars[i]=b
	end
	return function(c) for _,b in ipairs(bars) do b.BackgroundColor3=c end end
end
local function iconGear(ic)
	local ring=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(12,12),BackgroundTransparency=1},ic)
	corner(ring,"pill")
	local rs=new("UIStroke",{Thickness=2.2,Color=T.Sub,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},ring)
	local teeth={}
	for i=0,7 do
		local a=math.rad(i*45)
		local t=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.new(0.5,math.sin(a)*9,0.5,-math.cos(a)*9),Size=UDim2.fromOffset(4,4),Rotation=i*45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic)
		corner(t,1); teeth[#teeth+1]=t
	end
	return function(c) rs.Color=c; for _,t in ipairs(teeth) do t.BackgroundColor3=c end end
end
local function iconLag(ic)
	for i=1,3 do
		local b=new("Frame",{Size=UDim2.fromOffset(5,6+i*4),Position=UDim2.fromOffset(6+(i-1)*8,24-i*4),BackgroundColor3=T.Sub,BorderSizePixel=0},ic)
		corner(b,2)
	end
	local x1=new("Frame",{Size=UDim2.fromOffset(10,2.5),Position=UDim2.fromOffset(27,10),Rotation=45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic); corner(x1,"pill")
	local x2=new("Frame",{Size=UDim2.fromOffset(10,2.5),Position=UDim2.fromOffset(27,10),Rotation=-45,BackgroundColor3=T.Sub,BorderSizePixel=0},ic); corner(x2,"pill")
	return function(c) for _,ch in ipairs(ic:GetChildren()) do if ch:IsA("Frame") then ch.BackgroundColor3=c end end end
end

local parentGui=(gethui and gethui()) or CoreGui
local old=parentGui:FindFirstChild("APEXHub"); if old then old:Destroy() end
local gui=new("ScreenGui",{Name="APEXHub",ResetOnSpawn=false,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true},parentGui)
local spinConn
spinConn=RunService.RenderStepped:Connect(function(dt)
	if not gui.Parent then spinConn:Disconnect(); return end
	for _,s in ipairs(spinners) do s[1].Rotation=(s[1].Rotation+s[2]*dt)%360 end
end)

local fpsLabel
task.spawn(function()
	local last=os.clock()
	while true do
		RunService.RenderStepped:Wait()
		local now=os.clock()
		local fps=math.floor(1/math.max(now-last,0.001)); last=now
		if fpsLabel then fpsLabel.Text=fps.." FPS"; fpsLabel.TextColor3=fps>=55 and T.G1 or(fps>=30 and T.Orange or T.Red) end
	end
end)

local fab=new("TextButton",{Size=UDim2.fromOffset(52,52),Position=UDim2.new(0,16,0.5,-26),BackgroundColor3=Color3.fromRGB(8,14,10),Text="",AutoButtonColor=false},gui)
corner(fab,"pill"); spin(gradient(fab,ACCENT,45),70)
local fabStroke=stroke(fab,T.G1,2,0.4); loop(fabStroke,1.2,{Transparency=0.85,Thickness=6}); draggable(fab,fab)
local fabSc=new("UIScale",{Scale=1},fab)
local fabAvatar=new("ImageLabel",{Size=UDim2.fromOffset(44,44),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,ScaleType=Enum.ScaleType.Crop},fab)
corner(fabAvatar,"pill")
task.spawn(function() pcall(function() fabAvatar.Image=Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end) end)

local fpsPill=new("Frame",{Size=UDim2.fromOffset(80,20),Position=UDim2.new(0,76,0.5,-10),BackgroundColor3=Color3.fromRGB(8,14,10)},gui)
corner(fpsPill,"pill"); stroke(fpsPill,T.Stroke,1)
fpsLabel=label(fpsPill,{Size=UDim2.fromScale(1,1),TextXAlignment=CENTER,Font=F.GothamBold,TextSize=11,Text="-- FPS"})

local toastLayer=new("Frame",{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,60),Size=UDim2.fromOffset(310,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=70},gui)
new("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Right},toastLayer)
local toastCount=0
local function toast(opts)
	toastCount+=1
	local dur=opts.Duration or 5; local col=opts.Color or T.G1; local title=opts.Title or ""; local body=opts.Body or ""; local lo=toastCount
	local holder=new("Frame",{Size=UDim2.fromOffset(310,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=lo},toastLayer)
	local card=new("Frame",{Size=UDim2.fromOffset(310,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Color3.fromRGB(10,16,12),Position=UDim2.fromOffset(330,0),ClipsDescendants=false},holder)
	corner(card,16); stroke(card,col,1.5,0.15)
	local bar=new("Frame",{Size=UDim2.new(0,3,1,-20),Position=UDim2.fromOffset(10,10),BackgroundColor3=col,BorderSizePixel=0},card); corner(bar,"pill")
	new("TextLabel",{Size=UDim2.new(1,-80,0,18),Position=UDim2.fromOffset(60,10),BackgroundTransparency=1,Text=title,Font=F.GothamBlack,TextSize=12,TextColor3=T.Text,TextXAlignment=LEFT},card)
	if body~="" then new("TextLabel",{Size=UDim2.new(1,-80,0,14),Position=UDim2.fromOffset(60,30),BackgroundTransparency=1,Text=body,Font=F.GothamBold,TextSize=10,TextColor3=T.Sub,TextXAlignment=LEFT},card) end
	local progTrack=new("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.new(0,12,1,-6),BackgroundColor3=Color3.fromRGB(30,42,34),BorderSizePixel=0},card); corner(progTrack,"pill")
	local prog=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=col,BorderSizePixel=0},progTrack); corner(prog,"pill"); gradient(prog,ACCENT,0); tween(prog,dur,{Size=UDim2.fromScale(0,1)},Enum.EasingStyle.Linear)
	tween(card,0.4,{Position=UDim2.fromOffset(0,0)},BACK)
	task.delay(dur,function() if not holder.Parent then return end; tween(card,0.3,{Position=UDim2.fromOffset(330,0)},Enum.EasingStyle.Quad,Enum.EasingDirection.In); task.wait(0.35); holder:Destroy() end)
end
local function notifyOk(t,b) toast({Title=t,Body=b or "",Color=T.G1,Duration=4}) end
local function notifyInfo(t,b) toast({Title=t,Body=b or "",Color=T.Blue,Duration=4}) end
local function notifyWarn(t,b) toast({Title=t,Body=b or "",Color=T.Orange,Duration=5}) end
local W,H=680,390
local root=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(W,H),BackgroundTransparency=1,Visible=false},gui)
local rootSc=new("UIScale",{Scale=0},root)
local function fitScale() local cam=workspace.CurrentCamera; if not cam then return 1 end; local vp=cam.ViewportSize; return math.clamp(math.min((vp.X-24)/W,(vp.Y-24)/H),0.4,1) end
local glow=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,28,1,28),BackgroundColor3=T.G2,BackgroundTransparency=0.9,BorderSizePixel=0},root)
corner(glow,36); loop(glow,1.8,{BackgroundTransparency=0.95})
local main=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),ClipsDescendants=true,BackgroundTransparency=0.35},root)
corner(main,24); gradient(main,ColorSequence.new(Color3.fromRGB(11,20,15),T.Bg),60)
local mainStroke=stroke(main,Color3.new(1,1,1),2,0.1)
spin(gradient(mainStroke,ColorSequence.new({ColorSequenceKeypoint.new(0,T.G1),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,35,75)),ColorSequenceKeypoint.new(1,T.G2)}),30),45)
particles(main,10)

local header=new("Frame",{Size=UDim2.new(1,-20,0,44),Position=UDim2.fromOffset(10,10),BackgroundColor3=T.Rail,BackgroundTransparency=0.3},main)
corner(header,16); stroke(header,T.Stroke,1)
local logo=new("Frame",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(8,7),BackgroundColor3=Color3.new(1,1,1)},header)
corner(logo,10); spin(gradient(logo,ACCENT,45),80)
label(header,{Size=UDim2.fromOffset(84,44),Position=UDim2.fromOffset(46,0),Text="APEX HUB",Font=F.GothamBlack,TextSize=14})
label(header,{Size=UDim2.fromOffset(100,44),Position=UDim2.fromOffset(132,0),Text="/ Steal An Egg",TextSize=11,TextColor3=T.Sub})
local minBtn=new("TextButton",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-38,0,7),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},header)
corner(minBtn,"pill"); stroke(minBtn,T.Stroke,1); juice(minBtn,1.08)
local minBar=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(12,3),BackgroundColor3=T.G1,BorderSizePixel=0},minBtn); corner(minBar,"pill")

local rail=new("Frame",{Size=UDim2.new(0,52,1,-74),Position=UDim2.fromOffset(10,64),BackgroundColor3=T.Rail,BackgroundTransparency=0.3},main)
corner(rail,18); stroke(rail,T.Stroke,1)
local tabIndicator=new("Frame",{Size=UDim2.fromOffset(40,40),Position=UDim2.fromOffset(6,10),BackgroundColor3=Color3.new(1,1,1),ZIndex=1},rail)
corner(tabIndicator,14); spin(gradient(tabIndicator,ACCENT,45),60)
local tabHolder=new("Frame",{Size=UDim2.new(1,0,1,-70),Position=UDim2.fromOffset(0,10),BackgroundTransparency=1,ZIndex=2},rail)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center},tabHolder)

local content=new("Frame",{Size=UDim2.new(1,-80,1,-74),Position=UDim2.fromOffset(70,64),BackgroundTransparency=1},main)
local pageTitle=label(content,{Size=UDim2.new(1,-12,0,26),Position=UDim2.fromOffset(6,0),Text="",Font=F.GothamBlack,TextSize=20})
local pageSub=label(content,{Size=UDim2.new(1,-12,0,14),Position=UDim2.fromOffset(6,26),Text="",TextSize=11,TextColor3=T.Sub})
local pageHolder=new("Frame",{Size=UDim2.new(1,0,1,-48),Position=UDim2.fromOffset(0,48),BackgroundTransparency=1},content)

local pages,tabs,tabOrder,current={},{},{},nil
local function newPage(name)
	local sf=new("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.G2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},pageHolder)
	local cols=new("Frame",{Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},sf)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},cols)
	local function col(i)
		local c=new("Frame",{Size=UDim2.new(0.5,-5,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=i},cols)
		new("UIListLayout",{Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder},c)
		return c
	end
	pages[name]={Scroll=sf,Left=col(1),Right=col(2),Rows={},Cards={}}
	return pages[name]
end
local function addTab(name,subtitle,icon)
	local page=newPage(name); local idx=#tabOrder+1; table.insert(tabOrder,name)
	local b=new("TextButton",{Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=idx},tabHolder)
	corner(b,14); juice(b,1.08)
	local ic=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},b)
	local setIcon=icon(ic); tabs[name]={Btn=b,SetIcon=setIcon}
	tabs[name].Select=function()
		for n,t in pairs(tabs) do local act=(n==name); pages[n].Scroll.Visible=act; t.SetIcon(act and T.Bg or T.Sub) end
		tween(tabIndicator,0.4,{Position=UDim2.fromOffset(6,10+(idx-1)*46)},BACK)
		current=name; pageTitle.Text=name; pageSub.Text=subtitle
		pageTitle.TextTransparency=1; pageTitle.Position=UDim2.fromOffset(6,8)
		tween(pageTitle,0.35,{TextTransparency=0,Position=UDim2.fromOffset(6,0)},BACK)
		for i,c in ipairs(page.Cards) do
			local pop=c:FindFirstChild("Pop")
			if pop then pop.Scale=0.88; task.delay((i-1)*0.07,function() tween(pop,0.45,{Scale=1},BACK) end) end
		end
	end
	b.Activated:Connect(tabs[name].Select); return page
end

local pAlvo = addTab("Alvo","Escolha o ovo e o modo",iconTarget)
local pAuto = addTab("Auto","Escolha as raridades",iconAuto)
local pSpeed = addTab("Velocidade","Ajuste de velocidade",iconSpeed)
local pLag = addTab("Anti-Lag","Otimização",iconLag)
local pCfg = addTab("Config","Ajustes",iconGear)

local open=false
local function setOpen(v)
	open=v
	if v then
		root.Visible=true; rootSc.Scale=0; tween(rootSc,0.55,{Scale=fitScale()},BACK)
		for i,n in ipairs(tabOrder) do
			local b=tabs[n].Btn; local sc=b:FindFirstChildOfClass("UIScale")
			if sc then sc.Scale=0; task.delay(0.2+(i-1)*0.07,function() tween(sc,0.4,{Scale=1},BACK) end) end
		end
	else
		tween(rootSc,0.25,{Scale=0},BACK,Enum.EasingDirection.In); task.delay(0.27,function() if not open then root.Visible=false end end)
	end
end
local fabStart
fab.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fabStart=fab.AbsolutePosition end end)
fab.InputEnded:Connect(function() if fabStart and(fab.AbsolutePosition-fabStart).Magnitude<6 then setOpen(not open) end; fabStart=nil end)
minBtn.Activated:Connect(function() setOpen(false) end)
draggable(header,root)
tabs["Alvo"].Select()

local function runGate()
	fab.Visible=false
	local gate=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.2,BorderSizePixel=0,ZIndex=160,Active=true},gui)
	particles(gate,18)
	local box=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(380,292),BackgroundColor3=Color3.new(1,1,1)},gate)
	corner(box,26); gradient(box,ColorSequence.new(Color3.fromRGB(10,24,48),T.Bg),60)
	local bs=stroke(box,Color3.new(1,1,1),2,0.05)
	spin(gradient(bs,ColorSequence.new({ColorSequenceKeypoint.new(0,T.G1),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,35,75)),ColorSequenceKeypoint.new(1,T.G2)}),30),70)
	local boxSc=new("UIScale",{Scale=0},box); tween(boxSc,0.6,{Scale=1},BACK)
	local gl=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,30,1,30),BackgroundColor3=T.G2,BackgroundTransparency=0.92,BorderSizePixel=0,ZIndex=0},box)
	corner(gl,40); loop(gl,1.6,{BackgroundTransparency=0.97})
	local lg=new("TextLabel",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,22),Size=UDim2.fromOffset(58,58),BackgroundColor3=Color3.new(1,1,1),Text="A",Font=F.GothamBlack,TextSize=32,TextColor3=T.Bg},box)
	corner(lg,20); spin(gradient(lg,ACCENT,45),90); local lgSc=new("UIScale",{Scale=1},lg); loop(lgSc,1.2,{Scale=1.1})
	label(box,{Size=UDim2.new(1,0,0,26),Position=UDim2.fromOffset(0,90),Text="APEX HUB",Font=F.GothamBlack,TextSize=21,TextXAlignment=CENTER})
	label(box,{Size=UDim2.new(1,0,0,16),Position=UDim2.fromOffset(0,117),Text="Digite sua key para continuar",TextSize=12,TextColor3=T.Sub,TextXAlignment=CENTER})
	local inWrap=new("Frame",{Size=UDim2.new(1,-48,0,44),Position=UDim2.fromOffset(24,146),BackgroundColor3=T.Row},box); corner(inWrap,"pill")
	local input=new("TextBox",{Size=UDim2.new(1,-64,1,0),Position=UDim2.fromOffset(48,0),BackgroundTransparency=1,Text="",PlaceholderText="Cole ou digite a key",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=F.GothamBold,TextSize=14,ClearTextOnFocus=false,TextXAlignment=LEFT},inWrap)
	local btn=new("TextButton",{Size=UDim2.new(1,-48,0,44),Position=UDim2.fromOffset(24,224),BackgroundColor3=T.G1,Text="VERIFICAR",Font=F.GothamBlack,TextSize=14,TextColor3=T.Bg,AutoButtonColor=false},box)
	corner(btn,"pill"); juice(btn,1.04)
	btn.Activated:Connect(function()
		if (input.Text:gsub("%s+","")):lower()==KEY then
			gate:Destroy(); fab.Visible=true; setOpen(true); notifyOk("Key válida","Bem-vindo!")
		else
			notifyWarn("Key inválida","Tente novamente")
		end
	end)
end

runGate()
