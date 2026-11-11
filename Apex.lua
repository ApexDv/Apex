local Players         = game:GetService("Players")
local UIS             = game:GetService("UserInputService")
local TweenService    = game:GetService("TweenService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local Workspace       = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function primary(parent,props)
	local b=new("TextButton",props,parent)
	b.BackgroundColor3=Color3.new(1,1,1); b.AutoButtonColor=false
	corner(b,"pill"); spin(gradient(b,ACCENT,20),40); juice(b,1.04)
	return b
end

local function chev(parent,tx,ty,dir,col,L,th)
	L=L or 8; th=th or 2.5; local d=L/2*0.7071; local bars={}
	local function bar(cx,cy,rot)
		local b=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(cx,cy),
			Size=UDim2.fromOffset(L,th),Rotation=rot,BackgroundColor3=col,BorderSizePixel=0},parent)
		corner(b,"pill"); bars[#bars+1]=b
	end
	if dir=="right" then bar(tx-d,ty-d,45); bar(tx-d,ty+d,-45)
	else bar(tx-d,ty-d,45); bar(tx+d,ty-d,-45) end
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
local function newPage(name)
	local sf=new("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,
		ScrollBarThickness=3,ScrollBarImageColor3=T.G2,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false},pageHolder)
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

local function addButton(c,page,text,cb)
	local r=row(c,page,text,52); r:FindFirstChildOfClass("TextLabel"):Destroy()
	local b=primary(r,{Size=UDim2.new(1,-24,0,36),Position=UDim2.fromOffset(12,9),Text=text,Font=F.GothamBlack,TextSize=12,TextColor3=T.Bg})
	b.Activated:Connect(function() task.spawn(cb) end); return b
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
local parentGui=(gethui and gethui()) or CoreGui
local old=parentGui:FindFirstChild("APEXHub"); if old then old:Destroy() end
local gui=new("ScreenGui",{Name="APEXHub",ResetOnSpawn=false,DisplayOrder=100,
	ZIndexBehavior=Enum.ZIndexBehavior.Sibling,IgnoreGuiInset=true},parentGui)

local spinConn
spinConn=RunService.RenderStepped:Connect(function(dt)
	if not gui.Parent then spinConn:Disconnect(); return end
	for _,s in ipairs(spinners) do s[1].Rotation=(s[1].Rotation+s[2]*dt)%360 end
end)

local fab=new("TextButton",{Size=UDim2.fromOffset(52,52),Position=UDim2.new(0,16,0.5,-26),
	BackgroundColor3=Color3.fromRGB(8,14,10),Text="",AutoButtonColor=false},gui)
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

local W,H=680,390
local root=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
	Size=UDim2.fromOffset(W,H),BackgroundTransparency=1,Visible=false},gui)
local rootSc=new("UIScale",{Scale=0},root)
local function fitScale()
	local cam=Workspace.CurrentCamera; if not cam then return 1 end
	local vp=cam.ViewportSize
	return math.clamp(math.min((vp.X-24)/W,(vp.Y-24)/H),0.4,1)
end
local glow=new("Frame",{AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),
	Size=UDim2.new(1,28,1,28),BackgroundColor3=T.G2,BackgroundTransparency=0.9,BorderSizePixel=0},root)
corner(glow,36); loop(glow,1.8,{BackgroundTransparency=0.95})
local main=new("Frame",{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
	ClipsDescendants=true,BackgroundTransparency=0.35},root)
corner(main,24)
gradient(main,ColorSequence.new(Color3.fromRGB(11,20,15),T.Bg),60)
local mainStroke=stroke(main,Color3.new(1,1,1),2,0.1)
spin(gradient(mainStroke,ColorSequence.new({
	ColorSequenceKeypoint.new(0,T.G1),ColorSequenceKeypoint.new(0.5,Color3.fromRGB(8,35,75)),
	ColorSequenceKeypoint.new(1,T.G2),}),30),45)
particles(main,10)

local header=new("Frame",{Size=UDim2.new(1,-20,0,44),Position=UDim2.fromOffset(10,10),
	BackgroundColor3=T.Rail,BackgroundTransparency=0.3},main)
corner(header,16); stroke(header,T.Stroke,1)
local logo=new("Frame",{Size=UDim2.fromOffset(30,30),Position=UDim2.fromOffset(8,7),
	BackgroundColor3=Color3.new(1,1,1)},header)
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

local rail=new("Frame",{Size=UDim2.new(0,52,1,-74),Position=UDim2.fromOffset(10,64),BackgroundColor3=T.Rail,BackgroundTransparency=0.3},main)
corner(rail,18); stroke(rail,T.Stroke,1)
local tabIndicator=new("Frame",{Size=UDim2.fromOffset(40,40),Position=UDim2.fromOffset(6,10),BackgroundColor3=Color3.new(1,1,1),ZIndex=1},rail)
corner(tabIndicator,14); spin(gradient(tabIndicator,ACCENT,45),60)
local tabHolder=new("Frame",{Size=UDim2.new(1,0,1,-70),Position=UDim2.fromOffset(0,10),BackgroundTransparency=1,ZIndex=2},rail)
new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,HorizontalAlignment=Enum.HorizontalAlignment.Center},tabHolder)
local avatar=new("ImageLabel",{Size=UDim2.fromOffset(34,34),Position=UDim2.new(0.5,-17,1,-44),BackgroundColor3=T.Row},rail)
corner(avatar,"pill"); stroke(avatar,T.G2,2)
task.spawn(function()
	pcall(function() avatar.Image=Players:GetUserThumbnailAsync(lp.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size100x100) end)
end)

local content=new("Frame",{Size=UDim2.new(1,-80,1,-74),Position=UDim2.fromOffset(70,64),BackgroundTransparency=1},main)
local pageTitle=label(content,{Size=UDim2.new(1,-12,0,26),Position=UDim2.fromOffset(6,0),Text="",Font=F.GothamBlack,TextSize=20})
local pageSub=label(content,{Size=UDim2.new(1,-12,0,14),Position=UDim2.fromOffset(6,26),Text="",TextSize=11,TextColor3=T.Sub})
local pageHolder=new("Frame",{Size=UDim2.new(1,0,1,-48),Position=UDim2.fromOffset(0,48),BackgroundTransparency=1},content)

local pages,tabs,tabOrder,current={},{},{},nil

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
local CurrentTween = nil
local SilentAimConnection = nil

local function EquipTool(toolName)
    local character = lp.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local tool = lp.Backpack:FindFirstChild(toolName)
    if humanoid and tool then humanoid:EquipTool(tool) end
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

local function MoveToCFrame(targetCFrame, speed)
    local character = lp.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if CurrentTween then CurrentTween:Cancel() end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = math.clamp(distance / (speed or 21), 0.15, 5)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    CurrentTween = TweenService:Create(root, tweenInfo, { CFrame = targetCFrame })
    CurrentTween:Play()
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

-- ============ ABA ALVO ============
local pAlvo=addTab("Alvo","Farm e Teleportes",iconTarget)
local cA=card(pAlvo,"Left","Auto Farm")
local isAutoFarm = false
addToggle(cA,pAlvo,"Ativar AutoFarm",false,function(on)
    isAutoFarm = on
    task.spawn(function()
        while isAutoFarm do
            task.wait()
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local container = GetMapContainer("CoinContainer")
                if container then
                    for _, coin in ipairs(container:GetChildren()) do
                        if coin.Name == "Coin_Server" and not coin:GetAttribute("Collected") and coin:FindFirstChild("CoinVisual") then
                            local targetCF = CFrame.new(coin.CoinVisual.Position.X, coin.CoinVisual.Position.Y + 1.5, coin.CoinVisual.Position.Z)
                            MoveToCFrame(targetCF, 1000); break
                        end
                    end
                end
            end
        end
    end)
end)

local cB=card(pAlvo,"Right","Teleportes")
addButton(cB,pAlvo,"Ir para o Mapa",function()
    local spawns = GetMapContainer("Spawns")
    if spawns then for _, desc in ipairs(spawns:GetDescendants()) do if desc:IsA("BasePart") then MoveToCFrame(desc.CFrame * CFrame.new(0, 5, 0), 5000); break end end end
end)
addButton(cB,pAlvo,"Ir para o Lobby",function()
    for _, obj in ipairs(Workspace:GetChildren()) do
        if (obj:IsA("Model") or obj:IsA("Folder")) and string.find(string.lower(obj.Name), "lobby") then
            for _, desc in ipairs(obj:GetDescendants()) do if desc:IsA("SpawnLocation") then MoveToCFrame(CFrame.new(desc.Position + Vector3.new(0, 5, 0)), 5000); return end end
        end
    end
end)

-- ============ ABA AUTO ============
local pAuto=addTab("Auto","Funções de Role",iconAuto)
local cC=card(pAuto,"Left","Xerife")
addToggle(cC,pAuto,"Silent Aim",false,function(on)
    if on then
        task.spawn(function()
            while on do
                task.wait()
                local char = lp.Character
                local gun = char and char:FindFirstChild("Gun")
                local sheriffName = FindPlayerHolding("Gun")
                if gun and sheriffName == lp.Name and not SilentAimConnection then
                    SilentAimConnection = gun.Activated:Connect(function()
                        local murdererName = FindPlayerHolding("Knife")
                        local murdererPlayer = murdererName and Players:FindFirstChild(murdererName)
                        local murdererRoot = murdererPlayer and murdererPlayer.Character and murdererPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if murdererRoot and gun:FindFirstChild("Shoot") then gun.Shoot:FireServer("Shoot", murdererRoot.CFrame) end
                    end)
                elseif not gun and SilentAimConnection then
                    SilentAimConnection:Disconnect(); SilentAimConnection = nil
                end
                if not on and SilentAimConnection then SilentAimConnection:Disconnect(); SilentAimConnection = nil; break end
            end
        end)
    end
end)

local cD=card(pAuto,"Right","Assassino")
addToggle(cD,pAuto,"Kill Aura",false,function(on)
    task.spawn(function()
        while on do
            task.wait()
            local char = lp.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local murdererName = FindPlayerHolding("Knife")
            if root and murdererName == lp.Name then
                EquipTool("Knife")
                local knife = char:FindFirstChild("Knife")
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= lp and player.Character then
                        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetRoot and (targetRoot.Position - root.Position).Magnitude <= 15 then
                            if knife and knife:FindFirstChild("Events") and knife.Events:FindFirstChild("HandleTouched") then
                                knife.Events.HandleTouched:FireServer(targetRoot)
                            end
                        end
                    end
                end
            end
        end
    end)
end)

-- ============ ABA VELOCIDADE ============
local pSpeed=addTab("Velocidade","Ajustes do jogador",iconSpeed)
local cS=card(pSpeed,"Left","Físico")
local isSpeed = false
local speedVal = 16
addToggle(cS,pSpeed,"Ativar Velocidade",false,function(v) isSpeed = v end)
addSlider(cS,pSpeed,"WalkSpeed",16,200,16,function(v) speedVal = v end)

task.spawn(function()
    while true do
        task.wait()
        if isSpeed then
            local h = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = speedVal end
        end
    end
end)

-- ============ ABA ANTI-LAG ============
local pLag=addTab("Anti-Lag","Visuais e Otimização",iconLag)
local cL=card(pLag,"Left","Chams (ESP)")
local isChams = false

addToggle(cL,pLag,"Ativar Chams",false,function(on)
    isChams = on
    task.spawn(function()
        while isChams do
            task.wait()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= lp and player.Character then
                    local highlight = player.Character:FindFirstChild("Highlight") or Instance.new("Highlight", player.Character)
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
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local h = player.Character:FindFirstChild("Highlight")
                if h then h:Destroy() end
            end
        end
    end)
end)

addButton(cL,pLag,"Desligar Renderização 3D",function() RunService:Set3dRenderingEnabled(false) end)
addButton(cL,pLag,"Ligar Renderização 3D",function() RunService:Set3dRenderingEnabled(true) end)

-- ============ ABA CONFIG ============
local pCfg=addTab("Config","Ajustes do painel",iconGear)
local cG=card(pCfg,"Left","Painel")
addButton(cG,pCfg,"Fechar e remover painel",function() gui:Destroy() end)
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
end

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
draggable(header,root)
tabs["Alvo"].Select()

runGate()
print("APEX HUB MM2 carregado!")
