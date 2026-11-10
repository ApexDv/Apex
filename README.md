local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local PPS = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local KEY = "apex"
local lp = Players.LocalPlayer
local F = Enum.Font
local LEFT, CENTER, RIGHT = Enum.TextXAlignment.Left, Enum.TextXAlignment.Center, Enum.TextXAlignment.Right
local BACK, SINE = Enum.EasingStyle.Back, Enum.EasingStyle.Sine

local T = {
	Bg=Color3.fromRGB(5,8,18), Rail=Color3.fromRGB(8,13,27), Card=Color3.fromRGB(12,20,38),
	Row=Color3.fromRGB(18,30,52), Stroke=Color3.fromRGB(32,55,90),
	G1=Color3.fromRGB(65,165,255), G2=Color3.fromRGB(20,95,220),
	Text=Color3.fromRGB(235,255,242), Sub=Color3.fromRGB(135,175,220),
	Red=Color3.fromRGB(255,100,110), Orange=Color3.fromRGB(255,160,50),
	Blue=Color3.fromRGB(80,160,255), Purple=Color3.fromRGB(175,95,255),
	Gold=Color3.fromRGB(255,195,55),
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

local function chev(parent,tx,ty,dir,col,L,th)
	L=L or 8; th=th or 2.5; local d=L/2*0.7071; local bars={}
	local function bar(cx,cy,rot)
		local b=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(cx,cy),Size=UDim2.fromOffset(L,th),Rotation=rot,BackgroundColor3=col,BorderSizePixel=0},parent)
		corner(b,"pill"); bars[#bars+1]=b
	end
	if dir=="right" then bar(tx-d,ty-d,45); bar(tx-d,ty+d,-45) else bar(tx-d,ty-d,45); bar(tx+d,ty-d,-45) end
	return bars
end
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

local RARITIES={
	{Name="Comum",Color=Color3.fromRGB(175,175,182)},
	{Name="Raro",Color=Color3.fromRGB(70,150,255)},
	{Name="Épico",Color=Color3.fromRGB(175,95,255)},
	{Name="Lendário",Color=Color3.fromRGB(255,195,55)},
	{Name="Mítico",Color=Color3.fromRGB(255,75,115)},
	{Name="Cósmico",Color=Color3.fromRGB(80,230,255)},
	{Name="Secreto",Color=Color3.fromRGB(235,235,240)},
	{Name="Eternal",Color=Color3.fromRGB(255,135,45)},
	{Name="Divino",Color=Color3.fromRGB(255,245,170)},
}
local RCOLOR,ALIAS={},{}
for _,r in ipairs(RARITIES) do RCOLOR[r.Name:lower()]=r.Color end
ALIAS={common="Comum",rare="Raro",epic="Épico",legendary="Lendário",mythic="Mítico",cosmic="Cósmico",secret="Secreto",eternal="Eternal",divine="Divino"}
local function rarityColor(name)
	local l=tostring(name or ""):lower()
	return RCOLOR[l] or RCOLOR[(ALIAS[l] or ""):lower()] or T.Sub
end
local function tint(c,k) return c:Lerp(Color3.new(0,0,0),k) end
local function money(v)
	if type(v)~="number" then return tostring(v or "") end
	for _,u in ipairs({{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
		if v>=u[1] then return string.format("$%.2f%s/s",v/u[1],u[2]) end
	end
	return string.format("$%d/s",math.floor(v+0.5))
end

local Panel={
	Hooks={onSelect=function() end,onGo=function() end,onStop=function() end,onMode=function() end,onTeleportGo=function() end,onAntiGuard=function() end,onRarity=function() end,onAutoStart=function() end,onAutoStop=function() end,onSpeedToggle=function() end,onSpeed=function() end,onRefreshEggs=function() end},
	State={Mode="Fast Tween",TpGo=true,Selected=nil,Rarities={},Auto=false,AntiGuard=false,SpeedOn=false,Speed=16},
	Eggs={},
}
local function hook(name,...) local f=Panel.Hooks[name]; if type(f)=="function" then task.spawn(f,...) end end
function Panel.getSelectedRarities()
	local list={}
	for _,r in ipairs(RARITIES) do if Panel.State.Rarities[r.Name] then list[#list+1]=r.Name end end
	return list
end

local parentGui=(gethui and gethui()) or CoreGui
local old=parentGui:FindFirstChild("APEXHub"); if old then old:Destroy() end
local gui=new("ScreenGui",{Name="APEXHub",ResetOnSpawn=false,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true},parentGui)

local spinConn
spinConn=RunService.RenderStepped:Connect(function(dt)
	if not gui.Parent then spinConn:Disconnect(); return end
	for _,s in ipairs(spinners) do s[1].Rotation=(s[1].Rotation+s[2]*dt)%360 end
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
local ICONS={success="✓",info="i",warn="!",error="✕",egg="🥚",speed="⚡"}

local function toast(opts)
	toastCount+=1
	local dur=opts.Duration or 5; local col=opts.Color or T.G1; local title=opts.Title or ""; local body=opts.Body or ""; local icon=opts.Icon or "i"; local lo=toastCount
	local holder=new("Frame",{Size=UDim2.fromOffset(310,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,LayoutOrder=lo},toastLayer)
	local card=new("Frame",{Size=UDim2.fromOffset(310,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=Color3.fromRGB(10,16,12),Position=UDim2.fromOffset(330,0),ClipsDescendants=false},holder)
	corner(card,16); stroke(card,col,1.5,0.15)
	local gloss=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.94},card); corner(gloss,16)
	local bar=new("Frame",{Size=UDim2.new(0,3,1,-20),Position=UDim2.fromOffset(10,10),BackgroundColor3=col,BorderSizePixel=0},card); corner(bar,"pill")
	local barGlow=new("Frame",{Size=UDim2.new(0,12,1,-20),Position=UDim2.fromOffset(4,10),BackgroundColor3=col,BackgroundTransparency=0.75,BorderSizePixel=0},card); corner(barGlow,"pill")
	local iconCircle=new("Frame",{Size=UDim2.fromOffset(32,32),Position=UDim2.fromOffset(20,10),BackgroundColor3=col:Lerp(Color3.new(0,0,0),0.6)},card)
	corner(iconCircle,"pill"); stroke(iconCircle,col,1.5,0.3)
	new("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text=icon,Font=F.GothamBlack,TextSize=14,TextColor3=col,TextXAlignment=CENTER,TextYAlignment=Enum.TextYAlignment.Center},iconCircle)
	new("TextLabel",{Size=UDim2.new(1,-80,0,18),Position=UDim2.fromOffset(60,10),BackgroundTransparency=1,Text=title,Font=F.GothamBlack,TextSize=12,TextColor3=T.Text,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=LEFT},card)
	if body~="" then new("TextLabel",{Size=UDim2.new(1,-80,0,14),Position=UDim2.fromOffset(60,30),BackgroundTransparency=1,Text=body,Font=F.GothamBold,TextSize=10,TextColor3=T.Sub,TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=LEFT},card) end
	new("Frame",{Size=UDim2.new(1,0,0,8),BackgroundTransparency=1,LayoutOrder=99},card)
	local progTrack=new("Frame",{Size=UDim2.new(1,-24,0,2),Position=UDim2.new(0,12,1,-6),BackgroundColor3=Color3.fromRGB(30,42,34),BorderSizePixel=0},card); corner(progTrack,"pill")
	local prog=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=col,BorderSizePixel=0},progTrack); corner(prog,"pill"); gradient(prog,ACCENT,0); tween(prog,dur,{Size=UDim2.fromScale(0,1)},Enum.EasingStyle.Linear)
	tween(card,0.4,{Position=UDim2.fromOffset(0,0)},BACK)
	task.delay(dur,function() if not holder.Parent then return end; tween(card,0.3,{Position=UDim2.fromOffset(330,0)},Enum.EasingStyle.Quad,Enum.EasingDirection.In); task.wait(0.35); holder:Destroy() end)
end

function Panel.notify(info,duration)
	info=info or {}; local rc=rarityColor(info.RarityName)
	toast({Title="GO: "..tostring(info.Name or "?"),Body="Raridade: "..tostring(info.RarityName or "?").."  •  "..money(info.Value),Color=rc,Icon=ICONS.egg,Duration=duration or 6})
end
local function notifyOk(t,b) toast({Title=t,Body=b or "",Color=T.G1,Icon=ICONS.success,Duration=4}) end
local function notifyInfo(t,b) toast({Title=t,Body=b or "",Color=T.Blue,Icon=ICONS.info,Duration=4}) end
local function notifyWarn(t,b) toast({Title=t,Body=b or "",Color=T.Orange,Icon=ICONS.warn,Duration=5}) end
local function notifyErr(t,b) toast({Title=t,Body=b or "",Color=T.Red,Icon=ICONS.error,Duration=6}) end

local AH={Enabled=false,Busy=false,ratio=0,label="",onComplete=nil,onProgress=nil}
local AH_ROUTE={Vector3.new(500.62,241.28,-366.64),Vector3.new(504.45,155.80,-366.35),Vector3.new(508.30,70.28,-366.03),Vector3.new(513.86,70.28,-366.25),Vector3.new(519.43,70.28,-366.47),Vector3.new(524.32,70.28,-366.59),Vector3.new(529.22,70.28,-366.71),Vector3.new(538.01,70.28,-365.55),Vector3.new(546.80,70.28,-364.40)}

local ahOverlay
local function showAntiHitOverlay(onFinish)
	if ahOverlay and ahOverlay.Parent then ahOverlay:Destroy() end
	local over=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.fromRGB(3,8,5),BackgroundTransparency=0.08,ZIndex=250},gui)
	ahOverlay=over; particles(over,16)
	local box=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(360,220),BackgroundColor3=Color3.new(1,1,1),ZIndex=251},over)
	corner(box,22); gradient(box,ColorSequence.new(Color3.fromRGB(10,20,14),Color3.fromRGB(4,8,6)),60)
	local bs=stroke(box,Color3.new(1,1,1),2,0.08)
	spin(gradient(bs,ColorSequence.new({ColorSequenceKeypoint.new(0,T.G1),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,35,75)),ColorSequenceKeypoint.new(1,T.G2)}),30),60)
	local boxSc=new("UIScale",{Scale=0},box); tween(boxSc,0.5,{Scale=1},BACK)
	local shieldFrame=new("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,16),Size=UDim2.fromOffset(56,56),BackgroundColor3=Color3.new(1,1,1),ZIndex=252},box)
	corner(shieldFrame,14); spin(gradient(shieldFrame,ACCENT,45),80)
	new("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="🛡️",TextSize=28,Font=F.GothamBlack,ZIndex=253},shieldFrame)
	local shieldSc=new("UIScale",{Scale=1},shieldFrame); loop(shieldSc,1.1,{Scale=1.08})
	new("TextLabel",{Size=UDim2.new(1,0,0,22),Position=UDim2.fromOffset(0,80),BackgroundTransparency=1,Text="ANTI HIT",Font=F.GothamBlack,TextSize=20,TextColor3=T.G1,TextXAlignment=CENTER,ZIndex=252},box)
	new("TextLabel",{Size=UDim2.new(1,-24,0,14),Position=UDim2.fromOffset(12,104),BackgroundTransparency=1,Text="Rota segura ativada",Font=F.GothamBold,TextSize=11,TextColor3=T.Sub,TextXAlignment=CENTER,ZIndex=252},box)
	local stepLbl=new("TextLabel",{Size=UDim2.new(1,-24,0,14),Position=UDim2.fromOffset(12,120),BackgroundTransparency=1,Text="iniciando...",Font=F.GothamBold,TextSize=10,TextColor3=T.Sub,TextXAlignment=CENTER,ZIndex=252},box)
	local dotsFrame=new("Frame",{Size=UDim2.fromOffset(200,10),AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,142),BackgroundTransparency=1,ZIndex=252},box)
	new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,6),HorizontalAlignment=Enum.HorizontalAlignment.Center,VerticalAlignment=Enum.VerticalAlignment.Center},dotsFrame)
	local dots={}
	for i=1,#AH_ROUTE do local d=new("Frame",{Size=UDim2.fromOffset(10,10),BackgroundColor3=T.Row,BorderSizePixel=0},dotsFrame); corner(d,"pill"); stroke(d,T.Stroke,1); dots[i]=d end
	local barTrack=new("Frame",{AnchorPoint=Vector2.new(0.5,0),Position=UDim2.new(0.5,0,0,166),Size=UDim2.fromOffset(290,4),BackgroundColor3=T.Row,BorderSizePixel=0,ZIndex=252},box)
	corner(barTrack,"pill")
	local barFill=new("Frame",{Size=UDim2.fromScale(0,1),BackgroundColor3=Color3.new(1,1,1)},barTrack); corner(barFill,"pill"); gradient(barFill,ACCENT,0)
	AH.onProgress=function(ratio,lbl)
		local step=math.round(ratio*#AH_ROUTE)
		stepLbl.Text=lbl or ("step "..step.."/"..#AH_ROUTE)
		tween(barFill,0.12,{Size=UDim2.fromScale(ratio,1)},Enum.EasingStyle.Linear)
		for i=1,#dots do if i<=step then tween(dots[i],0.15,{BackgroundColor3=T.G1}) else tween(dots[i],0.15,{BackgroundColor3=T.Row}) end end
	end
	AH.onComplete=function(reached)
		local flashCol=reached and T.G1 or T.Red
		local flash=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=flashCol,BackgroundTransparency=0.6,ZIndex=255},box); corner(flash,22)
		tween(flash,0.4,{BackgroundTransparency=1},Enum.EasingStyle.Linear)
		task.delay(0.6,function()
			tween(boxSc,0.3,{Scale=0},BACK,Enum.EasingDirection.In); tween(over,0.4,{BackgroundTransparency=1})
			task.wait(0.45); over:Destroy(); ahOverlay=nil
			if AH.Enabled then notifyOk("Anti Hit","Zona segura alcançada") else notifyWarn("Anti Hit","Rota interrompida") end
			if onFinish then onFinish(reached) end
		end)
	end
end
local function runAntiHitRoute()
	local char=lp.Character; if not char or not char.Parent then return false end
	local total=#AH_ROUTE
	for i,pos in ipairs(AH_ROUTE) do
		if not AH.Enabled then return false end
		char:PivotTo(CFrame.new(pos))
		if AH.onProgress then local lbl=(i==total) and "zona segura" or ("step "..i.."/"..total); task.spawn(AH.onProgress,i/total,lbl) end
		if i<total then RunService.Heartbeat:Wait() end
	end
	return true
end
function AH.set(on) AH.Enabled=on and true or false end
function AH.trigger()
	if not AH.Enabled or AH.Busy then return end
	AH.Busy=true; showAntiHitOverlay()
	task.spawn(function() local ok=runAntiHitRoute(); AH.Busy=false; if AH.onComplete then task.spawn(AH.onComplete,ok) end end)
end
PPS.PromptTriggered:Connect(function(_,triggeredBy) if triggeredBy~=lp then return end; AH.trigger() end)

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
local verPill=new("Frame",{Size=UDim2.fromOffset(42,22),Position=UDim2.fromOffset(236,11),BackgroundColor3=T.Row},header)
corner(verPill,"pill"); stroke(verPill,T.Stroke,1)
label(verPill,{Size=UDim2.fromScale(1,1),Text="v3.0",Font=F.GothamBold,TextSize=10,TextColor3=T.Sub,TextXAlignment=CENTER})
local statusPill=new("Frame",{Size=UDim2.fromOffset(90,22),Position=UDim2.fromOffset(284,11),BackgroundColor3=T.Row},header)
corner(statusPill,"pill"); stroke(statusPill,T.Stroke,1)
local statusDot=new("Frame",{Size=UDim2.fromOffset(8,8),Position=UDim2.fromOffset(10,7),BackgroundColor3=T.Sub,BorderSizePixel=0},statusPill); corner(statusDot,"pill")
local statusText=label(statusPill,{Size=UDim2.new(1,-26,1,0),Position=UDim2.fromOffset(24,0),Text="Idle",Font=F.GothamBold,TextSize=10,TextTruncate=Enum.TextTruncate.AtEnd})
local minBtn=new("TextButton",{Size=UDim2.fromOffset(30,30),Position=UDim2.new(1,-38,0,7),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},header)
corner(minBtn,"pill"); stroke(minBtn,T.Stroke,1); juice(minBtn,1.08)
local minBar=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(12,3),BackgroundColor3=T.G1,BorderSizePixel=0},minBtn); corner(minBar,"pill")
local searchWrap=new("Frame",{Size=UDim2.fromOffset(150,28),Position=UDim2.new(1,-198,0,8),BackgroundColor3=T.Row},header); corner(searchWrap,"pill")
local searchStroke=stroke(searchWrap,T.Stroke,1)
local searchBox=new("TextBox",{Size=UDim2.new(1,-36,1,0),Position=UDim2.fromOffset(32,0),BackgroundTransparency=1,Text="",PlaceholderText="Buscar...",PlaceholderColor3=T.Sub,TextColor3=T.Text,Font=F.Gotham,TextSize=12,ClearTextOnFocus=false,TextXAlignment=LEFT},searchWrap)
do
	local lens=new("Frame",{Size=UDim2.fromOffset(11,11),Position=UDim2.fromOffset(10,7),BackgroundTransparency=1},searchWrap)
	corner(lens,"pill"); new("UIStroke",{Color=T.G1,Thickness=2,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},lens)
	local hd=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(22,20),Size=UDim2.fromOffset(6,2.5),Rotation=45,BackgroundColor3=T.G1,BorderSizePixel=0},searchWrap); corner(hd,"pill")
end
searchBox.Focused:Connect(function() tween(searchStroke,0.2,{Color=T.G1}) end)
searchBox.FocusLost:Connect(function() tween(searchStroke,0.2,{Color=T.Stroke}) end)

local rail=new("Frame",{Size=UDim2.new(0,52,1,-74),Position=UDim2.fromOffset(10,64),BackgroundColor3=T.Rail,BackgroundTransparency=0.3},main)
corner(rail,18); stroke(rail,T.Stroke,1)
local tabIndicator=new("Frame",{Size=UDim2.fromOffset(40,40),Position=UDim2.fromOffset(6,10),BackgroundColor3=Color3.new(1,1,1),ZIndex=1},rail)
corner(tabIndicator,14); spin(gradient(tabIndicator,ACCENT,45),60)
local tabHolder=new("Frame",{Size=UDim2.new(1,0,1,-70),Position=UDim2.fromOffset(0,10),BackgroundTransparency=1,ZIndex=2},rail)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center},tabHolder)
local avatar=new("ImageLabel",{Size=UDim2.fromOffset(34,34),Position=UDim2.new(0.5,-17,1,-44),BackgroundColor3=T.Row},rail)
corner(avatar,"pill"); stroke(avatar,T.G2,2)
task.spawn(function() pcall(function() avatar.Image=Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end) end)

local content=new("Frame",{Size=UDim2.new(1,-80,1,-74),Position=UDim2.fromOffset(70,64),BackgroundTransparency=1},main)
local pageTitle=label(content,{Size=UDim2.new(1,-12,0,26),Position=UDim2.fromOffset(6,0),Text="",Font=F.GothamBlack,TextSize=20})
local pageSub=label(content,{Size=UDim2.new(1,-12,0,14),Position=UDim2.fromOffset(6,26),Text="",TextSize=11,TextColor3=T.Sub})
local pageHolder=new("Frame",{Size=UDim2.new(1,0,1,-48),Position=UDim2.fromOffset(0,48),BackgroundTransparency=1},content)

local pages,tabs,tabOrder,current={},{},{},nil
local eggRows={}

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

local function card(page,side,title)
	local col=page[side]
	local c=new("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.Card,LayoutOrder=nxt(col),BackgroundTransparency=0.4},col)
	corner(c,18); stroke(c,T.Stroke,1)
	new("UIScale",{Name="Pop"},c); new("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder},c)
	new("UIPadding",{PaddingBottom=UDim.new(0,8)},c); page.Cards[#page.Cards+1]=c
	local h=new("Frame",{Size=UDim2.new(1,0,0,36),BackgroundTransparency=1,LayoutOrder=0},c)
	local dot=new("Frame",{Size=UDim2.fromOffset(8,8),Position=UDim2.fromOffset(16,14),BackgroundColor3=T.G1,BorderSizePixel=0},h); corner(dot,"pill"); loop(dot,1.4,{BackgroundTransparency=0.6})
	local hl=label(h,{Size=UDim2.new(1,-44,1,0),Position=UDim2.fromOffset(32,0),Text=title:upper(),Font=F.GothamBold,TextSize=11})
	return c,hl
end

local function row(c,page,name,height)
	local r=new("Frame",{Name=name,Size=UDim2.new(1,0,0,height or 40),BackgroundTransparency=1,LayoutOrder=nxt(c)},c)
	local ln=new("Frame",{Size=UDim2.new(1,-28,0,2),Position=UDim2.fromOffset(14,0),BackgroundColor3=T.Stroke,BorderSizePixel=0},r); corner(ln,"pill")
	local l=label(r,{Size=UDim2.new(1,-130,1,0),Position=UDim2.fromOffset(16,0),Text=name,TextTruncate=Enum.TextTruncate.AtEnd})
	page.Rows[#page.Rows+1]=r; return r,l
end

local function addToggle(c,page,text,default,cb)
	local r=row(c,page,text)
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

local menuFrame,menuCatcher
local function closeMenu()
	if not menuFrame then return end
	local f,c=menuFrame,menuCatcher; menuFrame,menuCatcher=nil,nil
	if c then c:Destroy() end
	tween(f:FindFirstChildOfClass("UIScale"),0.12,{Scale=0.85})
	task.delay(0.12,function() f:Destroy() end)
end
local function openMenu(anchor,options,cur,cb)
	closeMenu()
	menuCatcher=new("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",ZIndex=89},gui)
	menuCatcher.Activated:Connect(closeMenu)
	local f=new("Frame",{Position=UDim2.fromOffset(anchor.AbsolutePosition.X,anchor.AbsolutePosition.Y+anchor.AbsoluteSize.Y+4),Size=UDim2.fromOffset(math.max(anchor.AbsoluteSize.X,120),#options*32+10),BackgroundColor3=T.Rail,ZIndex=90},gui)
	corner(f,14); stroke(f,T.G2,1.5,0.2)
	local sc=new("UIScale",{Scale=0.8},f); tween(sc,0.25,{Scale=1},BACK); menuFrame=f
	for i,o in ipairs(options) do
		local sel=(o==cur)
		local b=new("TextButton",{Size=UDim2.new(1,-10,0,28),Position=UDim2.fromOffset(5,5+(i-1)*32),BackgroundColor3=sel and T.G2 or T.Row,Text=o,Font=F.GothamBold,TextSize=12,TextColor3=sel and T.Bg or T.Text,AutoButtonColor=false},f)
		corner(b,"pill"); juice(b,1.03)
		b.Activated:Connect(function() closeMenu(); task.spawn(cb,o) end)
	end
end

local function addSelect(c,page,text,options,default,cb)
	local r=row(c,page,text); local cur=default
	local b=new("TextButton",{Size=UDim2.fromOffset(112,28),Position=UDim2.new(1,-126,0.5,-14),BackgroundColor3=T.Row,Text="",AutoButtonColor=false},r)
	corner(b,"pill"); stroke(b,T.Stroke,1); juice(b,1.04)
	local bl=label(b,{Size=UDim2.new(1,-32,1,0),Position=UDim2.fromOffset(12,0),Text=default,Font=F.GothamBold,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd})
	chev(b,98,14,"down",T.G1,6,2)
	b.Activated:Connect(function() openMenu(b,options,cur,function(o) cur=o; bl.Text=o; cb(o) end) end)
	return function(v) cur=v; bl.Text=v end
end

local function addInfo(c,page,title,value)
	local r,l=row(c,page,title); l.Size=UDim2.fromOffset(70,40)
	return label(r,{Size=UDim2.new(1,-100,1,0),Position=UDim2.fromOffset(86,0),Text=value,Font=F.GothamBold,TextColor3=T.G1,TextXAlignment=RIGHT,TextTruncate=Enum.TextTruncate.AtEnd})
end

local function addSlider(c,page,text,min,max,default,cb)
	local r,l=row(c,page,text,56); l.Size=UDim2.new(1,-80,0,32)
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

local function primary(parent,props)
	local b=new("TextButton",props,parent)
	b.BackgroundColor3=Color3.new(1,1,1); b.AutoButtonColor=false
	corner(b,"pill"); spin(gradient(b,ACCENT,20),40); juice(b,1.04)
	return b
end
local function addButton(c,page,text,cb)
	local r=row(c,page,text,52); r:FindFirstChildOfClass("TextLabel"):Destroy()
	local b=primary(r,{Size=UDim2.new(1,-24,0,36),Position=UDim2.fromOffset(12,9),Text=text,Font=F.GothamBlack,TextSize=12,TextColor3=T.Bg})
	b.Activated:Connect(function() task.spawn(cb) end); return b
end
local function controlRow(c,page,leftText,rightText,onLeft,onRight)
	local r=row(c,page,leftText.."/"..rightText,54); r:FindFirstChildOfClass("TextLabel"):Destroy()
	local l=primary(r,{Size=UDim2.new(0.5,-16,0,38),Position=UDim2.fromOffset(12,10),Text=leftText,Font=F.GothamBlack,TextSize=13,TextColor3=T.Bg})
	local rt=new("TextButton",{Size=UDim2.new(0.5,-16,0,38),Position=UDim2.new(0.5,4,0,10),BackgroundColor3=Color3.new(1,1,1),Text=rightText,Font=F.GothamBlack,TextSize=13,TextColor3=Color3.fromRGB(255,235,235),AutoButtonColor=false},r)
	corner(rt,"pill"); spin(gradient(rt,ColorSequence.new(Color3.fromRGB(215,55,65),Color3.fromRGB(115,20,30)),20),-40)
	juice(rt,1.04); l.Activated:Connect(onLeft); rt.Activated:Connect(onRight)
	return l,rt
end

local function addTab(name,subtitle,icon)
	local page=newPage(name); local idx=#tabOrder+1; table.insert(tabOrder,name)
	local b=new("TextButton",{Size=UDim2.fromOffset(40,40),BackgroundTransparency=1,Text="",AutoButtonColor=false,LayoutOrder=idx},tabHolder)
	corner(b,14); juice(b,1.08)
	local ic=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1},b)
	local setIcon=icon(ic); tabs[name]={Btn=b,SetIcon=setIcon}
	tabs[name].Select=function()
		closeMenu()
		for n,t in pairs(tabs) do local act=(n==name); pages[n].Scroll.Visible=act; t.SetIcon(act and T.Bg or T.Sub) end
		tween(tabIndicator,0.4,{Position=UDim2.fromOffset(6,10+(idx-1)*46)},BACK)
		current=name; pageTitle.Text=name; pageSub.Text=subtitle
		pageTitle.TextTransparency=1; pageTitle.Position=UDim2.fromOffset(6,8)
		tween(pageTitle,0.35,{TextTransparency=0,Position=UDim2.fromOffset(6,0)},BACK)
		searchBox.Text=""
		for i,c in ipairs(page.Cards) do
			local pop=c:FindFirstChild("Pop")
			if pop then pop.Scale=0.88; task.delay((i-1)*0.07,function() tween(pop,0.45,{Scale=1},BACK) end) end
		end
	end
	b.Activated:Connect(tabs[name].Select); return page
end

loop(statusDot,0.9,{BackgroundTransparency=0.65})
local statusInfo
function Panel.setStatus(text,pill)
	if statusInfo then statusInfo.Text=tostring(text) end
	if pill then statusText.Text=tostring(pill); statusDot.BackgroundColor3=(pill=="Idle") and T.Sub or T.G1 end
end

local pAlvo=addTab("Alvo","Escolha o ovo e o modo",iconTarget)
local cA=card(pAlvo,"Left","Alvo")
addSelect(cA,pAlvo,"Modo de movimento",{"Fast Tween","Tween","Walk"},"Fast Tween",function(m) Panel.State.Mode=m; hook("onMode",m) end)
addToggle(cA,pAlvo,"Teleporte na ida",true,function(on) Panel.State.TpGo=on; hook("onTeleportGo",on) end)
local antiSet=addToggle(cA,pAlvo,"Anti Hit",false,function(on) Panel.State.AntiGuard=on; AH.set(on); Panel.setStatus("Anti Hit: "..(on and "ligado" or "desligado")); hook("onAntiGuard",on) end)
function Panel.setAntiGuard(on) Panel.State.AntiGuard=on and true or false; antiSet(Panel.State.AntiGuard,true); AH.set(on) end
statusInfo=addInfo(cA,pAlvo,"Status","Pronto")
controlRow(cA,pAlvo,"GO","STOP",function()
	local uid=Panel.State.Selected
	if not uid then Panel.setStatus("Selecione um ovo primeiro!"); notifyWarn("Nenhum ovo","Selecione um ovo na lista antes de GO"); return end
	local info
	for _,e in ipairs(Panel.Eggs) do if e.Uid==uid then info=e end end
	Panel.setStatus("GO: "..(info and info.Name or "?"),"GO"); Panel.notify(info,8); hook("onGo",uid,info)
end,function() Panel.setStatus("Parado.","Idle"); hook("onStop") end)

local cE,eggHeader=card(pAlvo,"Right","Ovos disponíveis")
do
	local refreshRow=new("Frame",{Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,LayoutOrder=nxt(cE)},cE)
	local refreshBtn=new("TextButton",{Size=UDim2.new(1,-16,0,28),Position=UDim2.fromOffset(8,5),BackgroundColor3=T.Row,Text="⟳  Atualizar Ovos",Font=F.GothamBold,TextSize=11,TextColor3=T.G1,AutoButtonColor=false},refreshRow)
	corner(refreshBtn,10); stroke(refreshBtn,T.G2,1,0.3); juice(refreshBtn,1.04)
	refreshBtn.Activated:Connect(function() notifyInfo("Atualizando ovos","Buscando lista atualizada..."); hook("onRefreshEggs") end)
end
local eggHolder=new("Frame",{Size=UDim2.new(1,0,0,210),BackgroundTransparency=1,LayoutOrder=nxt(cE)},cE)
local eggScroll=new("ScrollingFrame",{Size=UDim2.new(1,-16,1,-4),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=T.G2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},eggHolder)
corner(eggScroll,14)
new("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},eggScroll)
new("UIPadding",{PaddingTop=UDim.new(0,3),PaddingLeft=UDim.new(0,3),PaddingRight=UDim.new(0,6),PaddingBottom=UDim.new(0,4)},eggScroll)

local function styleEggs()
	for uid,r in pairs(eggRows) do
		local sel=(uid==Panel.State.Selected)
		local st=r:FindFirstChildOfClass("UIStroke")
		if st then tween(st,0.2,{Thickness=sel and 2 or 1,Color=sel and T.G1 or T.Stroke}) end
		tween(r,0.2,{BackgroundColor3=sel and Color3.fromRGB(18,48,32) or T.Row})
	end
end

local function refreshEggs()
	for _,r in pairs(eggRows) do r:Destroy() end; table.clear(eggRows)
	for i,e in ipairs(Panel.Eggs) do
		local rc=rarityColor(e.RarityName)
		local r=new("Frame",{Name=tostring(e.Name).." "..tostring(e.RarityName or ""),Size=UDim2.new(1,0,0,54),BackgroundColor3=T.Row,LayoutOrder=i},eggScroll)
		corner(r,14); stroke(r,T.Stroke,1)
		local pop=new("UIScale",{Scale=0.85},r)
		task.delay((i-1)*0.04,function() tween(pop,0.3,{Scale=1},BACK) end)
		local iconSize=36
		local iconFrame=new("Frame",{Size=UDim2.fromOffset(iconSize,iconSize),Position=UDim2.fromOffset(9,9),BackgroundColor3=tint(rc,0.72),BorderSizePixel=0},r)
		corner(iconFrame,"pill"); stroke(iconFrame,rc,1.5,0.3)
		local hasIcon=tostring(e.Icon or "")~="" and tostring(e.Icon or ""):find("rbxassetid")
		if hasIcon then
			new("ImageLabel",{Size=UDim2.fromOffset(iconSize-4,iconSize-4),AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),BackgroundTransparency=1,Image=tostring(e.Icon),ScaleType=Enum.ScaleType.Fit},iconFrame)
		else
			label(iconFrame,{Size=UDim2.fromScale(1,1),Text=(tostring(e.Name):match(utf8.charpattern) or "?"):upper(),Font=F.GothamBlack,TextSize=15,TextColor3=rc,TextXAlignment=CENTER,TextYAlignment=Enum.TextYAlignment.Center})
		end
		label(r,{Size=UDim2.new(1,-iconSize-18,0,17),Position=UDim2.fromOffset(iconSize+14,8),Text=tostring(e.Name),Font=F.GothamBold,TextSize=11,TextTruncate=Enum.TextTruncate.AtEnd})
		label(r,{Size=UDim2.new(1,-iconSize-1
