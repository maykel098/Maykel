--[[
    BLOXBURG AUTO FARM - Compatible Delta Exploit
    Versión corregida para móvil
]]

-- ESPERAR A QUE CARGUE TODO
repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
repeat task.wait() until player
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()

repeat task.wait() until character:FindFirstChild("Humanoid")
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════
-- CONFIG
-- ══════════════════════════════════
local CONFIG = {
    farming   = false,
    currentJob = nil,
    autoSprint = true,
    antiAFK    = true,
    sprintSpeed = 28,
}

local COLORS = {
    bg       = Color3.fromRGB(18, 18, 28),
    bgSecond = Color3.fromRGB(28, 28, 45),
    accent   = Color3.fromRGB(99, 102, 241),
    green    = Color3.fromRGB(34, 197, 94),
    red      = Color3.fromRGB(239, 68, 68),
    yellow   = Color3.fromRGB(234, 179, 8),
    text     = Color3.fromRGB(240, 240, 255),
    subtext  = Color3.fromRGB(150, 150, 180),
    border   = Color3.fromRGB(55, 55, 85),
}

-- ══════════════════════════════════
-- CREAR SCREENGUI (sin CoreGui)
-- ══════════════════════════════════
-- Eliminar GUI anterior si existe
local oldGui = playerGui:FindFirstChild("BBFarmDelta")
if oldGui then oldGui:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BBFarmDelta"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.AlwaysOnTop
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- ══════════════════════════════════
-- SISTEMA DE ARRASTRE PC + MÓVIL
-- ══════════════════════════════════
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
        end
    end)

    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ══════════════════════════════════
-- VENTANA PRINCIPAL
-- ══════════════════════════════════
local mainFrame = Instance.new("Frame")
mainFrame.Name       = "Main"
mainFrame.Size       = UDim2.new(0, 310, 0, 480)
mainFrame.Position   = UDim2.new(0.5, -155, 0.5, -240)
mainFrame.BackgroundColor3 = COLORS.bg
mainFrame.BorderSizePixel  = 0
mainFrame.ZIndex     = 10
mainFrame.ClipsDescendants = true
mainFrame.Parent     = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color     = COLORS.border
stroke.Thickness = 1.5

-- ══════════════════════════════════
-- BARRA TÍTULO
-- ══════════════════════════════════
local titleBar = Instance.new("Frame")
titleBar.Size  = UDim2.new(1, 0, 0, 46)
titleBar.BackgroundColor3 = COLORS.bgSecond
titleBar.BorderSizePixel  = 0
titleBar.ZIndex = 11
titleBar.Parent = mainFrame

local tCornerA = Instance.new("UICorner", titleBar)
tCornerA.CornerRadius = UDim.new(0, 12)

-- Parche esquinas bajas
local patch = Instance.new("Frame", titleBar)
patch.Size = UDim2.new(1, 0, 0.5, 0)
patch.Position = UDim2.new(0, 0, 0.5, 0)
patch.BackgroundColor3 = COLORS.bgSecond
patch.BorderSizePixel  = 0
patch.ZIndex = 11

-- Icono
local ico = Instance.new("TextLabel", titleBar)
ico.Size  = UDim2.new(0, 26, 0, 26)
ico.Position = UDim2.new(0, 12, 0.5, -13)
ico.BackgroundColor3 = COLORS.accent
ico.Text  = "🏘"
ico.TextScaled = true
ico.Font  = Enum.Font.GothamBold
ico.TextColor3 = Color3.fromRGB(255,255,255)
ico.ZIndex = 12
Instance.new("UICorner", ico).CornerRadius = UDim.new(0, 6)

-- Título texto
local titleLbl = Instance.new("TextLabel", titleBar)
titleLbl.Size     = UDim2.new(1, -100, 1, 0)
titleLbl.Position = UDim2.new(0, 46, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.Text     = "Bloxburg AutoFarm"
titleLbl.TextColor3 = COLORS.text
titleLbl.Font     = Enum.Font.GothamBold
titleLbl.TextSize = 14
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex   = 12

-- Botón X - ESQUINA SUPERIOR DERECHA
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size     = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = COLORS.red
closeBtn.Text     = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.Font     = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex   = 13
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)

-- ══════════════════════════════════
-- STATUS BAR
-- ══════════════════════════════════
local statusBar = Instance.new("Frame", mainFrame)
statusBar.Size  = UDim2.new(1, -16, 0, 36)
statusBar.Position = UDim2.new(0, 8, 0, 52)
statusBar.BackgroundColor3 = COLORS.bgSecond
statusBar.BorderSizePixel  = 0
statusBar.ZIndex = 11
Instance.new("UICorner", statusBar).CornerRadius = UDim.new(0, 8)

local statusDot = Instance.new("Frame", statusBar)
statusDot.Size  = UDim2.new(0, 9, 0, 9)
statusDot.Position = UDim2.new(0, 11, 0.5, -4)
statusDot.BackgroundColor3 = COLORS.red
statusDot.BorderSizePixel  = 0
statusDot.ZIndex = 12
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

local statusLbl = Instance.new("TextLabel", statusBar)
statusLbl.Size  = UDim2.new(1, -30, 1, 0)
statusLbl.Position = UDim2.new(0, 28, 0, 0)
statusLbl.BackgroundTransparency = 1
statusLbl.Text  = "Inactivo — selecciona un trabajo"
statusLbl.TextColor3 = COLORS.subtext
statusLbl.Font  = Enum.Font.Gotham
statusLbl.TextSize = 11
statusLbl.TextXAlignment = Enum.TextXAlignment.Left
statusLbl.ZIndex = 12

local function setStatus(txt, col)
    statusLbl.Text = txt
    statusDot.BackgroundColor3 = col or COLORS.yellow
end

-- ══════════════════════════════════
-- SCROLL FRAME
-- ══════════════════════════════════
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size  = UDim2.new(1, -14, 1, -98)
scroll.Position = UDim2.new(0, 7, 0, 94)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = COLORS.accent
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ZIndex = 11

local uiList = Instance.new("UIListLayout", scroll)
uiList.Padding = UDim.new(0, 6)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

local uiPad = Instance.new("UIPadding", scroll)
uiPad.PaddingTop    = UDim.new(0, 4)
uiPad.PaddingBottom = UDim.new(0, 8)
uiPad.PaddingLeft   = UDim.new(0, 2)
uiPad.PaddingRight  = UDim.new(0, 2)

-- ══════════════════════════════════
-- HELPERS UI
-- ══════════════════════════════════
local function sep(txt)
    local f = Instance.new("Frame", scroll)
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    f.ZIndex = 12
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1,0,0,1)
    line.Position = UDim2.new(0,0,0.5,0)
    line.BackgroundColor3 = COLORS.border
    line.BorderSizePixel = 0
    line.ZIndex = 12
    local tl = Instance.new("TextLabel", f)
    tl.Size = UDim2.new(0, 110, 1, 0)
    tl.Position = UDim2.new(0.5, -55, 0, 0)
    tl.BackgroundColor3 = COLORS.bg
    tl.Text = "  "..txt.."  "
    tl.TextColor3 = COLORS.accent
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 10
    tl.BorderSizePixel = 0
    tl.ZIndex = 13
end

local jobToggles = {}

local function createJobBtn(label, icon, key, cb)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 44)
    btn.BackgroundColor3 = COLORS.bgSecond
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local bs = Instance.new("UIStroke", btn)
    bs.Color = COLORS.border
    bs.Thickness = 1

    local ic = Instance.new("TextLabel", btn)
    ic.Size = UDim2.new(0, 28, 1, 0)
    ic.Position = UDim2.new(0, 10, 0, 0)
    ic.BackgroundTransparency = 1
    ic.Text = icon
    ic.TextScaled = true
    ic.ZIndex = 13

    local nl = Instance.new("TextLabel", btn)
    nl.Size = UDim2.new(1, -90, 1, 0)
    nl.Position = UDim2.new(0, 44, 0, 0)
    nl.BackgroundTransparency = 1
    nl.Text = label
    nl.TextColor3 = COLORS.text
    nl.Font = Enum.Font.Gotham
    nl.TextSize = 13
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.ZIndex = 13

    local togBg = Instance.new("Frame", btn)
    togBg.Size = UDim2.new(0, 34, 0, 19)
    togBg.Position = UDim2.new(1, -44, 0.5, -9)
    togBg.BackgroundColor3 = COLORS.border
    togBg.BorderSizePixel = 0
    togBg.ZIndex = 13
    Instance.new("UICorner", togBg).CornerRadius = UDim.new(1, 0)

    local togDot = Instance.new("Frame", togBg)
    togDot.Size = UDim2.new(0, 13, 0, 13)
    togDot.Position = UDim2.new(0, 3, 0.5, -6)
    togDot.BackgroundColor3 = COLORS.subtext
    togDot.BorderSizePixel = 0
    togDot.ZIndex = 14
    Instance.new("UICorner", togDot).CornerRadius = UDim.new(1, 0)

    local active = false

    local function setActive(v)
        active = v
        local col = v and COLORS.green or COLORS.border
        local pos = v and UDim2.new(0,18,0.5,-6) or UDim2.new(0,3,0.5,-6)
        TweenService:Create(togBg,  TweenInfo.new(0.2), {BackgroundColor3 = col}):Play()
        TweenService:Create(togDot, TweenInfo.new(0.2), {Position = pos}):Play()
        TweenService:Create(bs,     TweenInfo.new(0.2), {Color = v and COLORS.green or COLORS.border}):Play()
    end

    btn.MouseButton1Click:Connect(function()
        active = not active
        if active then
            -- desactivar los demás
            for k, fn in pairs(jobToggles) do
                if k ~= key then fn(false) end
            end
        end
        setActive(active)
        cb(active)
    end)

    jobToggles[key] = setActive
    return btn
end

-- ══════════════════════════════════
-- LÓGICA FARM
-- ══════════════════════════════════
local farmThread = nil

local function stopFarm()
    CONFIG.farming = false
    CONFIG.currentJob = nil
    if farmThread then
        task.cancel(farmThread)
        farmThread = nil
    end
    setStatus("Inactivo — selecciona un trabajo", COLORS.red)
end

local function findPart(names, maxDist)
    maxDist = maxDist or 60
    local best, bestD = nil, maxDist
    for _, n in ipairs(names) do
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find(n:lower()) then
                local d = (rootPart.Position - obj.Position).Magnitude
                if d < bestD then best, bestD = obj, d end
            end
        end
    end
    return best
end

local function tryInteract(part)
    if not part then return end
    for _, pp in ipairs(part:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            pcall(fireproximityprompt, pp)
            return
        end
    end
    for _, cd in ipairs(part:GetDescendants()) do
        if cd:IsA("ClickDetector") then
            pcall(fireclickdetector, cd)
            return
        end
    end
    -- También intentar en el padre
    for _, pp in ipairs(part.Parent:GetDescendants()) do
        if pp:IsA("ProximityPrompt") then
            pcall(fireproximityprompt, pp)
            return
        end
    end
end

local function goTo(pos)
    if not humanoid or humanoid.Health <= 0 then return false end
    humanoid:MoveTo(pos)
    local done = false
    local conn = humanoid.MoveToFinished:Connect(function(r) done = r end)
    local t = 0
    while not done and t < 8 do
        task.wait(0.1); t += 0.1
    end
    conn:Disconnect()
    return done
end

-- Remotes helper
local function fireRemote(...)
    local names = {...}
    for _, rs in ipairs({
        game.ReplicatedStorage,
        game.ReplicatedStorage:FindFirstChild("RemoteEvents") or Instance.new("Folder"),
        game.ReplicatedStorage:FindFirstChild("Remotes") or Instance.new("Folder"),
    }) do
        for _, name in ipairs(names) do
            local r = rs:FindFirstChild(name, true)
            if r and r:IsA("RemoteEvent") then
                pcall(function() r:FireServer() end)
            end
        end
    end
end

-- ══════════════════════════════════
-- DEFINICIÓN DE TRABAJOS
-- ══════════════════════════════════
local JOBS = {
    Cajero = function()
        while CONFIG.farming do
            pcall(function()
                local p = findPart({"Register","Cashier","Counter","Till"})
                if p then goTo(p.Position); tryInteract(p) end
                fireRemote("CashierAction","ScanItem","ProcessPayment")
            end)
            task.wait(0.8)
        end
    end,

    Pizzero = function()
        while CONFIG.farming do
            pcall(function()
                local dough = findPart({"Dough","PizzaStation","Flatten"})
                local oven  = findPart({"Oven","PizzaOven"})
                local cut   = findPart({"Cut","Slice","CutStation"})
                local box   = findPart({"Box","PizzaBox","Deliver"})
                if dough then goTo(dough.Position); tryInteract(dough); task.wait(0.4) end
                if oven  then goTo(oven.Position);  tryInteract(oven);  task.wait(1.0) end
                if cut   then goTo(cut.Position);   tryInteract(cut);   task.wait(0.4) end
                if box   then goTo(box.Position);   tryInteract(box);   task.wait(0.3) end
                fireRemote("PizzaAction","MakePizza","DeliverPizza")
            end)
            task.wait(0.5)
        end
    end,

    Estilista = function()
        while CONFIG.farming do
            pcall(function()
                local chair = findPart({"StylistChair","SalonChair","HairChair","Styling"})
                if chair then goTo(chair.Position); tryInteract(chair); task.wait(0.8) end
                fireRemote("StylistAction","CutHair","StyleHair")
            end)
            task.wait(1.0)
        end
    end,

    Conserje = function()
        while CONFIG.farming do
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        local n = obj.Name:lower()
                        if n:find("stain") or n:find("dirt") or n:find("spill") or n:find("trash") then
                            local d = (rootPart.Position - obj.Position).Magnitude
                            if d < 80 then
                                goTo(obj.Position)
                                tryInteract(obj)
                                task.wait(0.2)
                            end
                        end
                    end
                end
                fireRemote("JanitorAction","CleanFloor","MopFloor")
            end)
            task.wait(0.5)
        end
    end,

    Docente = function()
        while CONFIG.farming do
            pcall(function()
                local board = findPart({"Board","Whiteboard","Blackboard","Chalkboard"})
                local desk  = findPart({"TeacherDesk","Podium","Lectern"})
                if board then goTo(board.Position); tryInteract(board); task.wait(0.5) end
                if desk  then goTo(desk.Position);  tryInteract(desk);  task.wait(0.3) end
                fireRemote("TeacherAction","TeachLesson","GradeWork")
            end)
            task.wait(1.2)
        end
    end,

    Leñador = function()
        while CONFIG.farming do
            pcall(function()
                local tree = findPart({"Tree","Trunk","TreeStump","Birch","Oak","Pine"})
                if tree then
                    goTo(tree.Position)
                    tryInteract(tree)
                    task.wait(1.2)
                    local drop = findPart({"WoodDrop","Sawmill","LogPile","Depot"})
                    if drop then goTo(drop.Position); tryInteract(drop); task.wait(0.3) end
                end
                fireRemote("LumberjackAction","ChopTree","SellWood")
            end)
            task.wait(0.5)
        end
    end,

    Vendedor = function()
        while CONFIG.farming do
            pcall(function()
                local stall = findPart({"Stall","Stand","Vendor","Kiosk","Shop"})
                if stall then goTo(stall.Position); tryInteract(stall); task.wait(0.6) end
                fireRemote("SellerAction","SellItem","CompleteTransaction")
            end)
            task.wait(0.8)
        end
    end,

    Minero = function()
        while CONFIG.farming do
            pcall(function()
                local rock = findPart({"Rock","Ore","Coal","Crystal","MineWall"})
                if rock then
                    goTo(rock.Position)
                    tryInteract(rock)
                    task.wait(1.0)
                    local dep = findPart({"Deposit","MineCart","OreCart","Chest"})
                    if dep then goTo(dep.Position); tryInteract(dep); task.wait(0.3) end
                end
                fireRemote("MinerAction","MineRock","DepositOre")
            end)
            task.wait(0.5)
        end
    end,

    Cadete = function()
        while CONFIG.farming do
            pcall(function()
                local pkg = findPart({"Package","Parcel","Box","Delivery"})
                if pkg then
                    goTo(pkg.Position); tryInteract(pkg); task.wait(0.5)
                    local dst = findPart({"DeliveryPoint","Dropoff","Destination","Mailbox"})
                    if dst then goTo(dst.Position); tryInteract(dst); task.wait(0.3) end
                end
                fireRemote("CadeteAction","PickupPackage","DeliverPackage")
            end)
            task.wait(0.5)
        end
    end,

    Repositor = function()
        while CONFIG.farming do
            pcall(function()
                local stock = findPart({"Stockroom","Stock","Backroom","StorageShelf"})
                local shelf = findPart({"EmptyShelf","DisplayShelf","Shelf","Rack"})
                if stock then goTo(stock.Position); tryInteract(stock); task.wait(0.5) end
                if shelf then goTo(shelf.Position); tryInteract(shelf); task.wait(0.5) end
                fireRemote("StockerAction","RestockShelf","FillShelf")
            end)
            task.wait(0.5)
        end
    end,

    Taxista = function()
        while CONFIG.farming do
            pcall(function()
                local taxi = findPart({"TaxiSpawn","TaxiStand","CarPark","Taxi"})
                if taxi then goTo(taxi.Position); tryInteract(taxi); task.wait(0.5) end
                local pax = findPart({"Passenger","Customer","Rider"})
                if pax then goTo(pax.Position); tryInteract(pax); task.wait(0.5) end
                fireRemote("TaxiAction","PickupPassenger","DropoffPassenger")
            end)
            task.wait(1.5)
        end
    end,

    Pescador = function()
        while CONFIG.farming do
            pcall(function()
                local spot = findPart({"FishingSpot","Pier","Dock","FishingArea","Water"})
                if spot then
                    goTo(spot.Position); tryInteract(spot); task.wait(2.5)
                end
                local sell = findPart({"FishSell","FishMarket","FishCounter"})
                if sell then goTo(sell.Position); tryInteract(sell); task.wait(0.4) end
                fireRemote("FishermanAction","CastRod","SellFish")
            end)
            task.wait(0.5)
        end
    end,
}

-- ══════════════════════════════════
-- INICIAR TRABAJO
-- ══════════════════════════════════
local function startJob(key)
    stopFarm()
    CONFIG.farming = true
    CONFIG.currentJob = key
    setStatus("Trabajando: " .. key, COLORS.green)
    farmThread = task.spawn(function()
        if JOBS[key] then JOBS[key]() end
    end)
end

-- ══════════════════════════════════
-- AGREGAR BOTONES
-- ══════════════════════════════════
sep("TRABAJOS")

local jobDefs = {
    {"Cajero",    "💰", "Cajero"},
    {"Pizzero",   "🍕", "Pizzero"},
    {"Estilista", "✂️", "Estilista"},
    {"Conserje",  "🧹", "Conserje"},
    {"Docente",   "📚", "Docente"},
    {"Leñador",   "🪓", "Leñador"},
    {"Vendedor",  "🛒", "Vendedor"},
    {"Minero",    "⛏️", "Minero"},
    {"Cadete",    "📦", "Cadete"},
    {"Repositor", "🏪", "Repositor"},
    {"Taxista",   "🚕", "Taxista"},
    {"Pescador",  "🎣", "Pescador"},
}

for _, jd in ipairs(jobDefs) do
    createJobBtn(jd[1], jd[2], jd[3], function(active)
        if active then startJob(jd[3]) else stopFarm() end
    end)
end

sep("OPCIONES")

-- Toggle genérico
local function createOpt(lbl, icon, def, cb)
    local row = Instance.new("Frame", scroll)
    row.Size = UDim2.new(1, 0, 0, 40)
    row.BackgroundColor3 = COLORS.bgSecond
    row.BorderSizePixel  = 0
    row.ZIndex = 12
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local tx = Instance.new("TextLabel", row)
    tx.Size = UDim2.new(1, -54, 1, 0)
    tx.Position = UDim2.new(0, 36, 0, 0)
    tx.BackgroundTransparency = 1
    tx.Text = icon.."  "..lbl
    tx.TextColor3 = COLORS.text
    tx.Font = Enum.Font.Gotham
    tx.TextSize = 12
    tx.TextXAlignment = Enum.TextXAlignment.Left
    tx.ZIndex = 13

    local tb = Instance.new("TextButton", row)
    tb.Size = UDim2.new(0, 34, 0, 19)
    tb.Position = UDim2.new(1, -44, 0.5, -9)
    tb.BackgroundColor3 = def and COLORS.green or COLORS.border
    tb.Text = ""
    tb.BorderSizePixel = 0
    tb.ZIndex = 13
    tb.AutoButtonColor = false
    Instance.new("UICorner", tb).CornerRadius = UDim.new(1, 0)

    local td = Instance.new("Frame", tb)
    td.Size = UDim2.new(0,13,0,13)
    td.Position = def and UDim2.new(0,18,0.5,-6) or UDim2.new(0,3,0.5,-6)
    td.BackgroundColor3 = Color3.fromRGB(255,255,255)
    td.BorderSizePixel  = 0
    td.ZIndex = 14
    Instance.new("UICorner", td).CornerRadius = UDim.new(1, 0)

    local val = def
    tb.MouseButton1Click:Connect(function()
        val = not val
        TweenService:Create(tb, TweenInfo.new(0.2), {BackgroundColor3 = val and COLORS.green or COLORS.border}):Play()
        TweenService:Create(td, TweenInfo.new(0.2), {Position = val and UDim2.new(0,18,0.5,-6) or UDim2.new(0,3,0.5,-6)}):Play()
        cb(val)
    end)
end

createOpt("Auto Sprint", "🏃", true, function(v)
    CONFIG.autoSprint = v
end)

createOpt("Anti-AFK", "💤", true, function(v)
    CONFIG.antiAFK = v
end)

-- ══════════════════════════════════
-- CÍRCULO FLOTANTE
-- ══════════════════════════════════
local circle = Instance.new("TextButton", screenGui)
circle.Name  = "FloatBtn"
circle.Size  = UDim2.new(0, 54, 0, 54)
circle.Position = UDim2.new(1, -74, 0.5, -27)
circle.BackgroundColor3 = COLORS.accent
circle.Text  = "🏘"
circle.TextScaled = true
circle.Font  = Enum.Font.GothamBold
circle.BorderSizePixel = 0
circle.ZIndex = 20
circle.Visible = false
circle.AutoButtonColor = false
Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

local cStroke = Instance.new("UIStroke", circle)
cStroke.Color = Color3.fromRGB(130, 133, 255)
cStroke.Thickness = 2.5

makeDraggable(circle)

-- Pulso animado
task.spawn(function()
    while true do
        if circle.Visible then
            TweenService:Create(cStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 5}):Play()
            task.wait(0.9)
            TweenService:Create(cStroke, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Thickness = 2.5}):Play()
            task.wait(0.9)
        else
            task.wait(0.5)
        end
    end
end)

-- ══════════════════════════════════
-- HIDE / SHOW ANIMADO
-- ══════════════════════════════════
local origPos = mainFrame.Position
local origSize = mainFrame.Size

local function hideMain()
    TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(
            origPos.X.Scale, origPos.X.Offset + 155,
            origPos.Y.Scale, origPos.Y.Offset + 240
        )
    }):Play()
    task.wait(0.26)
    mainFrame.Visible = false
    circle.Visible    = true
end

local function showMain()
    mainFrame.Visible = true
    mainFrame.Size    = UDim2.new(0,0,0,0)
    mainFrame.Position = UDim2.new(
        origPos.X.Scale, origPos.X.Offset + 155,
        origPos.Y.Scale, origPos.Y.Offset + 240
    )
    TweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size     = origSize,
        Position = origPos
    }):Play()
    circle.Visible = false
end

closeBtn.MouseButton1Click:Connect(hideMain)
circle.MouseButton1Click:Connect(showMain)

-- ══════════════════════════════════
-- ARRASTRE MAIN (por titleBar)
-- ══════════════════════════════════
makeDraggable(mainFrame, titleBar)

-- ══════════════════════════════════
-- SISTEMAS PASIVOS
-- ══════════════════════════════════

-- Auto Sprint loop
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if CONFIG.autoSprint and humanoid and humanoid.Health > 0 then
                humanoid.WalkSpeed = CONFIG.sprintSpeed
            end
        end)
    end
end)

-- Anti-AFK
task.spawn(function()
    while true do
        task.wait(60)
        if CONFIG.antiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0), CFrame.new())
                task.wait(0.1)
                vu:Button2Up(Vector2.new(0,0), CFrame.new())
            end)
        end
    end
end)

-- Recargar referencias tras muerte
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid  = char:WaitForChild("Humanoid")
    rootPart  = char:WaitForChild("HumanoidRootPart")
    if CONFIG.farming and CONFIG.currentJob then
        task.wait(2.5)
        setStatus("Reiniciando " .. CONFIG.currentJob .. "...", COLORS.yellow)
        startJob(CONFIG.currentJob)
    end
end)

-- Animación de entrada
mainFrame.Size     = UDim2.new(0,0,0,0)
mainFrame.Position = UDim2.new(0.5,0,0.5,0)
task.wait(0.05)
TweenService:Create(mainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size     = UDim2.new(0,310,0,480),
    Position = UDim2.new(0.5,-155,0.5,-240)
}):Play()

print("[BBFarm] ✅ Script cargado — Delta compatible")
