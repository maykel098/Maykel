repeat task.wait(0.5) until game:IsLoaded() and game.Players.LocalPlayer
task.wait(3)

local Players     = game:GetService("Players")
local TweenService= game:GetService("TweenService")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")

local plr  = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum  = char:WaitForChild("Humanoid")
local root = char:WaitForChild("HumanoidRootPart")

-- ▸ gethui() es lo que Delta usa para bypassear restricciones de GUI
local function getContainer()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local sg = Instance.new("ScreenGui")
        syn.protect_gui(sg)
        sg.Parent = game.CoreGui
        return sg
    end
    return plr.PlayerGui
end

-- Limpiar GUI anterior
pcall(function()
    for _, g in ipairs(getContainer():GetChildren()) do
        if g.Name == "BBFarm" then g:Destroy() end
    end
end)

local CONFIG = {
    farming    = false,
    currentJob = nil,
    autoSprint = true,
    antiAFK    = true,
    speed      = 26,
}

local C = {
    bg    = Color3.fromRGB(15,15,25),
    bg2   = Color3.fromRGB(24,24,40),
    acc   = Color3.fromRGB(99,102,241),
    green = Color3.fromRGB(34,197,94),
    red   = Color3.fromRGB(239,68,68),
    yel   = Color3.fromRGB(234,179,8),
    txt   = Color3.fromRGB(235,235,255),
    sub   = Color3.fromRGB(140,140,175),
    brd   = Color3.fromRGB(50,50,80),
}

-- ══════════════════════════════════
-- SCREENGUI
-- ══════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name             = "BBFarm"
sg.ResetOnSpawn     = false
sg.ZIndexBehavior   = Enum.ZIndexBehavior.AlwaysOnTop
sg.DisplayOrder     = 9999
sg.IgnoreGuiInset   = true

pcall(function()
    if gethui then
        sg.Parent = gethui()
    else
        sg.Parent = plr.PlayerGui
    end
end)
if not sg.Parent then sg.Parent = plr.PlayerGui end

-- ══════════════════════════════════
-- ARRASTRE UNIVERSAL
-- ══════════════════════════════════
local function drag(frame, handle)
    handle = handle or frame
    local dragging, dStart, fStart = false, nil, nil

    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dStart   = i.Position
            fStart   = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (
            i.UserInputType == Enum.UserInputType.MouseMovement or
            i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dStart
            frame.Position = UDim2.new(
                fStart.X.Scale, fStart.X.Offset + d.X,
                fStart.Y.Scale, fStart.Y.Offset + d.Y)
        end
    end)
end

-- ══════════════════════════════════
-- MAIN FRAME
-- ══════════════════════════════════
local mf = Instance.new("Frame", sg)
mf.Name               = "Main"
mf.Size               = UDim2.new(0,308,0,490)
mf.Position           = UDim2.new(0.5,-154,0.5,-245)
mf.BackgroundColor3   = C.bg
mf.BorderSizePixel    = 0
mf.ZIndex             = 5
mf.ClipsDescendants   = true
Instance.new("UICorner", mf).CornerRadius = UDim.new(0,12)
local mfS = Instance.new("UIStroke", mf)
mfS.Color = C.brd; mfS.Thickness = 1.5

-- TÍTULO
local tb = Instance.new("Frame", mf)
tb.Size = UDim2.new(1,0,0,46)
tb.BackgroundColor3 = C.bg2
tb.BorderSizePixel  = 0
tb.ZIndex = 6
Instance.new("UICorner", tb).CornerRadius = UDim.new(0,12)
local tbp = Instance.new("Frame", tb) -- parche borde inferior
tbp.Size = UDim2.new(1,0,0.5,0)
tbp.Position = UDim2.new(0,0,0.5,0)
tbp.BackgroundColor3 = C.bg2
tbp.BorderSizePixel  = 0
tbp.ZIndex = 6

local icoL = Instance.new("TextLabel", tb)
icoL.Size = UDim2.new(0,26,0,26)
icoL.Position = UDim2.new(0,11,0.5,-13)
icoL.BackgroundColor3 = C.acc
icoL.Text = "🏘"; icoL.TextScaled = true
icoL.Font = Enum.Font.GothamBold
icoL.ZIndex = 7
Instance.new("UICorner", icoL).CornerRadius = UDim.new(0,6)

local titL = Instance.new("TextLabel", tb)
titL.Size = UDim2.new(1,-90,1,0)
titL.Position = UDim2.new(0,44,0,0)
titL.BackgroundTransparency = 1
titL.Text = "Bloxburg AutoFarm"
titL.TextColor3 = C.txt
titL.Font = Enum.Font.GothamBold
titL.TextSize = 14
titL.TextXAlignment = Enum.TextXAlignment.Left
titL.ZIndex = 7

-- BOTÓN X
local xBtn = Instance.new("TextButton", tb)
xBtn.Size = UDim2.new(0,27,0,27)
xBtn.Position = UDim2.new(1,-37,0.5,-13)
xBtn.BackgroundColor3 = C.red
xBtn.Text = "✕"
xBtn.TextColor3 = Color3.new(1,1,1)
xBtn.Font = Enum.Font.GothamBold
xBtn.TextSize = 12
xBtn.BorderSizePixel = 0
xBtn.ZIndex = 8
xBtn.AutoButtonColor = false
Instance.new("UICorner", xBtn).CornerRadius = UDim.new(0,7)

-- STATUS
local stBar = Instance.new("Frame", mf)
stBar.Size = UDim2.new(1,-14,0,34)
stBar.Position = UDim2.new(0,7,0,50)
stBar.BackgroundColor3 = C.bg2
stBar.BorderSizePixel  = 0
stBar.ZIndex = 6
Instance.new("UICorner", stBar).CornerRadius = UDim.new(0,8)

local stDot = Instance.new("Frame", stBar)
stDot.Size = UDim2.new(0,8,0,8)
stDot.Position = UDim2.new(0,10,0.5,-4)
stDot.BackgroundColor3 = C.red
stDot.BorderSizePixel  = 0
stDot.ZIndex = 7
Instance.new("UICorner", stDot).CornerRadius = UDim.new(1,0)

local stLbl = Instance.new("TextLabel", stBar)
stLbl.Size = UDim2.new(1,-26,1,0)
stLbl.Position = UDim2.new(0,24,0,0)
stLbl.BackgroundTransparency = 1
stLbl.Text = "Inactivo — elige un trabajo"
stLbl.TextColor3 = C.sub
stLbl.Font = Enum.Font.Gotham
stLbl.TextSize = 11
stLbl.TextXAlignment = Enum.TextXAlignment.Left
stLbl.ZIndex = 7

local function setSt(t,c)
    stLbl.Text = t
    stDot.BackgroundColor3 = c or C.yel
end

-- SCROLL
local sf = Instance.new("ScrollingFrame", mf)
sf.Size = UDim2.new(1,-12,1,-92)
sf.Position = UDim2.new(0,6,0,88)
sf.BackgroundTransparency = 1
sf.BorderSizePixel = 0
sf.ScrollBarThickness = 3
sf.ScrollBarImageColor3 = C.acc
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.CanvasSize = UDim2.new(0,0,0,0)
sf.ZIndex = 6
local ll = Instance.new("UIListLayout", sf)
ll.Padding = UDim.new(0,5)
local lp = Instance.new("UIPadding", sf)
lp.PaddingTop=UDim.new(0,4); lp.PaddingBottom=UDim.new(0,8)
lp.PaddingLeft=UDim.new(0,2); lp.PaddingRight=UDim.new(0,2)

-- ══════════════════════════════════
-- UI HELPERS
-- ══════════════════════════════════
local function mkSep(t)
    local f = Instance.new("Frame", sf)
    f.Size = UDim2.new(1,0,0,20); f.BackgroundTransparency=1; f.ZIndex=7
    local ln = Instance.new("Frame", f)
    ln.Size=UDim2.new(1,0,0,1); ln.Position=UDim2.new(0,0,0.5,0)
    ln.BackgroundColor3=C.brd; ln.BorderSizePixel=0; ln.ZIndex=7
    local tl = Instance.new("TextLabel", f)
    tl.Size=UDim2.new(0,100,1,0); tl.Position=UDim2.new(0.5,-50,0,0)
    tl.BackgroundColor3=C.bg; tl.Text="  "..t.."  "
    tl.TextColor3=C.acc; tl.Font=Enum.Font.GothamBold
    tl.TextSize=10; tl.BorderSizePixel=0; tl.ZIndex=8
end

local jobToggles = {}

local function mkJob(name, icon, key, cb)
    local btn = Instance.new("TextButton", sf)
    btn.Size=UDim2.new(1,0,0,43); btn.BackgroundColor3=C.bg2
    btn.Text=""; btn.BorderSizePixel=0; btn.ZIndex=7; btn.AutoButtonColor=false
    Instance.new("UICorner", btn).CornerRadius=UDim.new(0,8)
    local bs = Instance.new("UIStroke", btn); bs.Color=C.brd; bs.Thickness=1

    local ic=Instance.new("TextLabel",btn)
    ic.Size=UDim2.new(0,26,1,0); ic.Position=UDim2.new(0,9,0,0)
    ic.BackgroundTransparency=1; ic.Text=icon; ic.TextScaled=true; ic.ZIndex=8

    local nl=Instance.new("TextLabel",btn)
    nl.Size=UDim2.new(1,-80,1,0); nl.Position=UDim2.new(0,41,0,0)
    nl.BackgroundTransparency=1; nl.Text=name; nl.TextColor3=C.txt
    nl.Font=Enum.Font.Gotham; nl.TextSize=13
    nl.TextXAlignment=Enum.TextXAlignment.Left; nl.ZIndex=8

    local tg=Instance.new("Frame",btn)
    tg.Size=UDim2.new(0,33,0,18); tg.Position=UDim2.new(1,-42,0.5,-9)
    tg.BackgroundColor3=C.brd; tg.BorderSizePixel=0; tg.ZIndex=8
    Instance.new("UICorner",tg).CornerRadius=UDim.new(1,0)

    local td=Instance.new("Frame",tg)
    td.Size=UDim2.new(0,12,0,12); td.Position=UDim2.new(0,3,0.5,-6)
    td.BackgroundColor3=C.sub; td.BorderSizePixel=0; td.ZIndex=9
    Instance.new("UICorner",td).CornerRadius=UDim.new(1,0)

    local on=false
    local function setOn(v)
        on=v
        TweenService:Create(tg,TweenInfo.new(0.2),{BackgroundColor3=v and C.green or C.brd}):Play()
        TweenService:Create(td,TweenInfo.new(0.2),{
            Position=v and UDim2.new(0,18,0.5,-6) or UDim2.new(0,3,0.5,-6),
            BackgroundColor3=v and Color3.new(1,1,1) or C.sub
        }):Play()
        TweenService:Create(bs,TweenInfo.new(0.2),{Color=v and C.green or C.brd}):Play()
    end
    btn.MouseButton1Click:Connect(function()
        on=not on
        if on then for k,fn in pairs(jobToggles) do if k~=key then fn(false) end end end
        setOn(on); cb(on)
    end)
    jobToggles[key]=setOn
end

local function mkOpt(name,icon,def,cb)
    local row=Instance.new("Frame",sf)
    row.Size=UDim2.new(1,0,0,40); row.BackgroundColor3=C.bg2
    row.BorderSizePixel=0; row.ZIndex=7
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local tx=Instance.new("TextLabel",row)
    tx.Size=UDim2.new(1,-52,1,0); tx.Position=UDim2.new(0,34,0,0)
    tx.BackgroundTransparency=1; tx.Text=icon.."  "..name
    tx.TextColor3=C.txt; tx.Font=Enum.Font.Gotham; tx.TextSize=12
    tx.TextXAlignment=Enum.TextXAlignment.Left; tx.ZIndex=8

    local tb2=Instance.new("TextButton",row)
    tb2.Size=UDim2.new(0,33,0,18); tb2.Position=UDim2.new(1,-42,0.5,-9)
    tb2.BackgroundColor3=def and C.green or C.brd
    tb2.Text=""; tb2.BorderSizePixel=0; tb2.ZIndex=8; tb2.AutoButtonColor=false
    Instance.new("UICorner",tb2).CornerRadius=UDim.new(1,0)

    local td2=Instance.new("Frame",tb2)
    td2.Size=UDim2.new(0,12,0,12)
    td2.Position=def and UDim2.new(0,18,0.5,-6) or UDim2.new(0,3,0.5,-6)
    td2.BackgroundColor3=Color3.new(1,1,1); td2.BorderSizePixel=0; td2.ZIndex=9
    Instance.new("UICorner",td2).CornerRadius=UDim.new(1,0)

    local v=def
    tb2.MouseButton1Click:Connect(function()
        v=not v
        TweenService:Create(tb2,TweenInfo.new(0.2),{BackgroundColor3=v and C.green or C.brd}):Play()
        TweenService:Create(td2,TweenInfo.new(0.2),{Position=v and UDim2.new(0,18,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
        cb(v)
    end)
end

-- ══════════════════════════════════
-- LÓGICA FARM
-- ══════════════════════════════════
local farmThread = nil

local function stopFarm()
    CONFIG.farming = false
    CONFIG.currentJob = nil
    if farmThread then task.cancel(farmThread); farmThread=nil end
    setSt("Inactivo — elige un trabajo", C.red)
end

local function findPart(names, dist)
    dist = dist or 70
    local best, bd = nil, dist
    for _,n in ipairs(names) do
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") and o.Name:lower():find(n:lower()) then
                local d=(root.Position-o.Position).Magnitude
                if d<bd then best,bd=o,d end
            end
        end
    end
    return best
end

local function interact(p)
    if not p then return end
    for _,c in ipairs(p:GetDescendants()) do
        if c:IsA("ProximityPrompt") then pcall(fireproximityprompt,c); return end
    end
    for _,c in ipairs(p:GetDescendants()) do
        if c:IsA("ClickDetector") then pcall(fireclickdetector,c); return end
    end
    if p.Parent then
        for _,c in ipairs(p.Parent:GetDescendants()) do
            if c:IsA("ProximityPrompt") then pcall(fireproximityprompt,c); return end
        end
    end
end

local function goTo(pos)
    if not hum or hum.Health<=0 then return end
    hum:MoveTo(pos)
    local t=0
    while t<7 do
        task.wait(0.15); t=t+0.15
        if (root.Position - pos).Magnitude < 5 then break end
    end
end

local JOBS={
    Cajero=function()
        while CONFIG.farming do pcall(function()
            local p=findPart({"Register","Cashier","Counter","Till","Cash"})
            if p then goTo(p.Position); interact(p) end
            task.wait(0.8)
        end) end
    end,
    Pizzero=function()
        while CONFIG.farming do pcall(function()
            local a=findPart({"Dough","Flatten","PizzaStation"})
            local b=findPart({"Oven","PizzaOven","Bake"})
            local c=findPart({"Cut","Slice"})
            local d=findPart({"Box","PizzaBox","Deliver"})
            if a then goTo(a.Position); interact(a); task.wait(0.4) end
            if b then goTo(b.Position); interact(b); task.wait(1.0) end
            if c then goTo(c.Position); interact(c); task.wait(0.4) end
            if d then goTo(d.Position); interact(d); task.wait(0.3) end
            task.wait(0.4)
        end) end
    end,
    Estilista=function()
        while CONFIG.farming do pcall(function()
            local p=findPart({"StylistChair","SalonChair","HairChair","Styling","Salon"})
            if p then goTo(p.Position); interact(p); task.wait(0.9) end
            task.wait(0.8)
        end) end
    end,
    Conserje=function()
        while CONFIG.farming do pcall(function()
            for _,o in ipairs(workspace:GetDescendants()) do
                if o:IsA("BasePart") then
                    local n=o.Name:lower()
                    if n:find("stain") or n:find("dirt") or n:find("spill") or n:find("trash") or n:find("mess") then
                        if (root.Position-o.Position).Magnitude<90 then
                            goTo(o.Position); interact(o); task.wait(0.2)
                        end
                    end
                end
            end
            task.wait(0.5)
        end) end
    end,
    Docente=function()
        while CONFIG.farming do pcall(function()
            local a=findPart({"Board","Whiteboard","Blackboard","Chalkboard"})
            local b=findPart({"TeacherDesk","Podium","Lectern"})
            if a then goTo(a.Position); interact(a); task.wait(0.6) end
            if b then goTo(b.Position); interact(b); task.wait(0.4) end
            task.wait(1.0)
        end) end
    end,
    Leñador=function()
        while CONFIG.farming do pcall(function()
            local t=findPart({"Tree","Trunk","Birch","Oak","Pine","Log"})
            if t then
                goTo(t.Position); interact(t); task.wait(1.2)
                local d=findPart({"Sawmill","WoodDrop","LogPile","Depot"})
                if d then goTo(d.Position); interact(d); task.wait(0.3) end
            end
            task.wait(0.5)
        end) end
    end,
    Vendedor=function()
        while CONFIG.farming do pcall(function()
            local p=findPart({"Stall","Stand","Vendor","Kiosk","Shop"})
            if p then goTo(p.Position); interact(p); task.wait(0.7) end
            task.wait(0.7)
        end) end
    end,
    Minero=function()
        while CONFIG.farming do pcall(function()
            local r=findPart({"Rock","Ore","Coal","Crystal","MineWall","Gem"})
            if r then
                goTo(r.Position); interact(r); task.wait(1.0)
                local d=findPart({"Deposit","Cart","OreBox","Chest"})
                if d then goTo(d.Position); interact(d); task.wait(0.3) end
            end
            task.wait(0.5)
        end) end
    end,
    Cadete=function()
        while CONFIG.farming do pcall(function()
            local p=findPart({"Package","Parcel","Box","Delivery","Mail"})
            if p then
                goTo(p.Position); interact(p); task.wait(0.5)
                local d=findPart({"Dropoff","Destination","Mailbox","DeliveryPoint"})
                if d then goTo(d.Position); interact(d); task.wait(0.3) end
            end
            task.wait(0.5)
        end) end
    end,
    Repositor=function()
        while CONFIG.farming do pcall(function()
            local a=findPart({"Stockroom","Backroom","Stock","Storage"})
            local b=findPart({"EmptyShelf","Shelf","Rack","Display"})
            if a then goTo(a.Position); interact(a); task.wait(0.5) end
            if b then goTo(b.Position); interact(b); task.wait(0.5) end
            task.wait(0.4)
        end) end
    end,
    Taxista=function()
        while CONFIG.farming do pcall(function()
            local t=findPart({"TaxiSpawn","TaxiStand","Taxi","CarSpawn"})
            if t then goTo(t.Position); interact(t); task.wait(0.5) end
            local p=findPart({"Passenger","Customer","Rider"})
            if p then goTo(p.Position); interact(p); task.wait(0.5) end
            task.wait(1.5)
        end) end
    end,
    Pescador=function()
        while CONFIG.farming do pcall(function()
            local s=findPart({"FishingSpot","Pier","Dock","FishZone"})
            if s then goTo(s.Position); interact(s); task.wait(2.5) end
            local m=findPart({"FishSell","FishMarket","Market","FishCounter"})
            if m then goTo(m.Position); interact(m); task.wait(0.4) end
            task.wait(0.4)
        end) end
    end,
}

local function startJob(key)
    stopFarm()
    CONFIG.farming=true; CONFIG.currentJob=key
    setSt("Trabajando: "..key, C.green)
    farmThread=task.spawn(function()
        if JOBS[key] then JOBS[key]() end
    end)
end

-- ══════════════════════════════════
-- BOTONES
-- ══════════════════════════════════
mkSep("TRABAJOS")
local jobs={
    {"Cajero","💰"},{"Pizzero","🍕"},{"Estilista","✂️"},
    {"Conserje","🧹"},{"Docente","📚"},{"Leñador","🪓"},
    {"Vendedor","🛒"},{"Minero","⛏️"},{"Cadete","📦"},
    {"Repositor","🏪"},{"Taxista","🚕"},{"Pescador","🎣"},
}
for _,j in ipairs(jobs) do
    mkJob(j[1],j[2],j[1],function(on)
        if on then startJob(j[1]) else stopFarm() end
    end)
end

mkSep("OPCIONES")
mkOpt("Auto Sprint","🏃",true,function(v) CONFIG.autoSprint=v end)
mkOpt("Anti-AFK","💤",true,function(v) CONFIG.antiAFK=v end)

-- ══════════════════════════════════
-- CÍRCULO FLOTANTE
-- ══════════════════════════════════
local circle=Instance.new("TextButton",sg)
circle.Size=UDim2.new(0,52,0,52)
circle.Position=UDim2.new(1,-70,0.5,-26)
circle.BackgroundColor3=C.acc
circle.Text="🏘"; circle.TextScaled=true
circle.Font=Enum.Font.GothamBold
circle.BorderSizePixel=0; circle.ZIndex=20
circle.Visible=false; circle.AutoButtonColor=false
Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)

local cSt=Instance.new("UIStroke",circle)
cSt.Color=Color3.fromRGB(130,133,255); cSt.Thickness=2.5

drag(circle)

task.spawn(function()
    while true do
        if circle.Visible then
            TweenService:Create(cSt,TweenInfo.new(0.85,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Thickness=5}):Play()
            task.wait(0.9)
            TweenService:Create(cSt,TweenInfo.new(0.85,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Thickness=2.5}):Play()
            task.wait(0.9)
        else
            task.wait(0.5)
        end
    end
end)

-- HIDE / SHOW
local oPos=mf.Position
local oSz=mf.Size

local function hideGui()
    TweenService:Create(mf,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.In),{
        Size=UDim2.new(0,0,0,0),
        Position=UDim2.new(oPos.X.Scale,oPos.X.Offset+154,oPos.Y.Scale,oPos.Y.Offset+245)
    }):Play()
    task.wait(0.23); mf.Visible=false; circle.Visible=true
end

local function showGui()
    mf.Visible=true
    mf.Size=UDim2.new(0,0,0,0)
    mf.Position=UDim2.new(oPos.X.Scale,oPos.X.Offset+154,oPos.Y.Scale,oPos.Y.Offset+245)
    TweenService:Create(mf,TweenInfo.new(0.27,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=oSz, Position=oPos
    }):Play()
    circle.Visible=false
end

xBtn.MouseButton1Click:Connect(hideGui)
circle.MouseButton1Click:Connect(showGui)
drag(mf, tb)

-- ══════════════════════════════════
-- SISTEMAS PASIVOS
-- ══════════════════════════════════
task.spawn(function()
    while true do task.wait(0.5) pcall(function()
        if CONFIG.autoSprint and hum and hum.Health>0 then
            hum.WalkSpeed=CONFIG.speed
        end
    end) end
end)

task.spawn(function()
    while true do task.wait(55) pcall(function()
        if CONFIG.antiAFK then
            local vu=game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0),CFrame.new())
            task.wait(0.1)
            vu:Button2Up(Vector2.new(0,0),CFrame.new())
        end
    end) end
end)

plr.CharacterAdded:Connect(function(c)
    char=c; hum=c:WaitForChild("Humanoid"); root=c:WaitForChild("HumanoidRootPart")
    if CONFIG.farming and CONFIG.currentJob then
        task.wait(3); startJob(CONFIG.currentJob)
    end
end)

-- Animación entrada
mf.Size=UDim2.new(0,0,0,0)
mf.Position=UDim2.new(0.5,0,0.5,0)
task.wait(0.1)
TweenService:Create(mf,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Size=UDim2.new(0,308,0,490),
    Position=UDim2.new(0.5,-154,0.5,-245)
}):Play()

print("[BBFarm] GUI cargado correctamente ✅")
