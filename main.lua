--[[
    ╔══════════════════════════════════════╗
    ║    BLOXBURG AUTO FARM - GUI Script   ║
    ║         Compatible Mobile/PC         ║
    ╚══════════════════════════════════════╝
    
    AVISO: Solo para uso educativo/personal.
    Usar en servidores privados reduce riesgos.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ══════════════════════════════════════════
-- CONFIGURACIÓN
-- ══════════════════════════════════════════
local CONFIG = {
    walkSpeed = 22,         -- Velocidad de caminata
    autoSprint = true,      -- Auto sprint
    sprintSpeed = 28,
    farmDelay = 0.1,        -- Delay entre acciones
    antiAFK = true,
    currentJob = nil,
    farming = false,
    guiVisible = true,
}

-- ══════════════════════════════════════════
-- COLORES Y ESTILO
-- ══════════════════════════════════════════
local COLORS = {
    bg        = Color3.fromRGB(18, 18, 28),
    bgSecond  = Color3.fromRGB(26, 26, 40),
    accent    = Color3.fromRGB(99, 102, 241),
    accentHov = Color3.fromRGB(129, 132, 255),
    green     = Color3.fromRGB(34, 197, 94),
    red       = Color3.fromRGB(239, 68, 68),
    yellow    = Color3.fromRGB(234, 179, 8),
    text      = Color3.fromRGB(240, 240, 255),
    subtext   = Color3.fromRGB(160, 160, 190),
    border    = Color3.fromRGB(60, 60, 90),
}

-- ══════════════════════════════════════════
-- CREAR GUI
-- ══════════════════════════════════════════

-- Intentar insertar en CoreGui para mayor prioridad
local screenGui
local success = pcall(function()
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BBAutoFarm"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.AlwaysOnTop
    screenGui.DisplayOrder = 9999
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = game:GetService("CoreGui")
end)

if not success then
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BBAutoFarm"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.AlwaysOnTop
    screenGui.DisplayOrder = 9999
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
end

-- ══════════════════════════════════════════
-- FUNCIÓN DE ARRASTRE (PC + MÓVIL)
-- ══════════════════════════════════════════
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        frame.Position = newPos
    end

    -- PC
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement or
               input.UserInputType == Enum.UserInputType.Touch then
                update(input)
            end
        end
    end)
end

-- ══════════════════════════════════════════
-- VENTANA PRINCIPAL
-- ══════════════════════════════════════════
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 460)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -230)
mainFrame.BackgroundColor3 = COLORS.bg
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 10
mainFrame.Parent = screenGui

-- Sombra
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.ZIndex = 9
shadow.Parent = mainFrame

-- Bordes redondeados
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Borde sutil
local stroke = Instance.new("UIStroke")
stroke.Color = COLORS.border
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- ══════════════════════════════════════════
-- BARRA DE TÍTULO (ARRASTRABLE)
-- ══════════════════════════════════════════
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = COLORS.bgSecond
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 11
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

-- Parche para esquinas inferiores planas
local titlePatch = Instance.new("Frame")
titlePatch.Size = UDim2.new(1, 0, 0.5, 0)
titlePatch.Position = UDim2.new(0, 0, 0.5, 0)
titlePatch.BackgroundColor3 = COLORS.bgSecond
titlePatch.BorderSizePixel = 0
titlePatch.ZIndex = 11
titlePatch.Parent = titleBar

-- Icono decorativo
local titleIcon = Instance.new("TextLabel")
titleIcon.Size = UDim2.new(0, 28, 0, 28)
titleIcon.Position = UDim2.new(0, 14, 0.5, -14)
titleIcon.BackgroundColor3 = COLORS.accent
titleIcon.Text = "🏘"
titleIcon.TextScaled = true
titleIcon.Font = Enum.Font.GothamBold
titleIcon.TextColor3 = Color3.fromRGB(255,255,255)
titleIcon.ZIndex = 12
titleIcon.Parent = titleBar

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 6)
iconCorner.Parent = titleIcon

-- Título
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 52, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Bloxburg Auto Farm"
titleLabel.TextColor3 = COLORS.text
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 15
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 12
titleLabel.Parent = titleBar

-- Subtítulo versión
local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 60, 0, 14)
versionLabel.Position = UDim2.new(0, 52, 0.5, 4)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v2.0 Mobile+"
versionLabel.TextColor3 = COLORS.accent
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 10
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.ZIndex = 12
versionLabel.Parent = titleBar

-- Botón X (cerrar/minimizar) - ESQUINA SUPERIOR DERECHA
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -42, 0.5, -15)
closeBtn.BackgroundColor3 = COLORS.red
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 13
closeBtn.Parent = titleBar

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

-- ══════════════════════════════════════════
-- CONTENIDO SCROLLABLE
-- ══════════════════════════════════════════
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -16, 1, -56)
scrollFrame.Position = UDim2.new(0, 8, 0, 52)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 3
scrollFrame.ScrollBarImageColor3 = COLORS.accent
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.ZIndex = 11
scrollFrame.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 6)
listPadding.PaddingBottom = UDim.new(0, 10)
listPadding.PaddingLeft = UDim.new(0, 4)
listPadding.PaddingRight = UDim.new(0, 4)
listPadding.Parent = scrollFrame

-- ══════════════════════════════════════════
-- ESTADO DEL FARM
-- ══════════════════════════════════════════
local statusSection = Instance.new("Frame")
statusSection.Size = UDim2.new(1, 0, 0, 52)
statusSection.BackgroundColor3 = COLORS.bgSecond
statusSection.BorderSizePixel = 0
statusSection.ZIndex = 12
statusSection.Parent = scrollFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusSection

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 12, 0.5, -5)
statusDot.BackgroundColor3 = COLORS.red
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 13
statusDot.Parent = statusSection

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = statusDot

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -30, 1, 0)
statusLabel.Position = UDim2.new(0, 30, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Estado: Inactivo"
statusLabel.TextColor3 = COLORS.subtext
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.ZIndex = 13
statusLabel.Parent = statusSection

-- Función para actualizar estado
local function setStatus(text, color)
    statusLabel.Text = "Estado: " .. text
    statusDot.BackgroundColor3 = color or COLORS.yellow
end

-- ══════════════════════════════════════════
-- FUNCIÓN PARA CREAR BOTONES DE TRABAJO
-- ══════════════════════════════════════════
local function createJobBtn(name, icon, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 46)
    btn.BackgroundColor3 = COLORS.bgSecond
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.ZIndex = 12
    btn.AutoButtonColor = false
    btn.Parent = scrollFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = COLORS.border
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 1, 0)
    iconLabel.Position = UDim2.new(0, 10, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextScaled = true
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextColor3 = COLORS.text
    iconLabel.ZIndex = 13
    iconLabel.Parent = btn

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -90, 1, 0)
    nameLabel.Position = UDim2.new(0, 46, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = COLORS.text
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 13
    nameLabel.Parent = btn

    local toggleIndicator = Instance.new("Frame")
    toggleIndicator.Size = UDim2.new(0, 36, 0, 20)
    toggleIndicator.Position = UDim2.new(1, -46, 0.5, -10)
    toggleIndicator.BackgroundColor3 = COLORS.border
    toggleIndicator.BorderSizePixel = 0
    toggleIndicator.ZIndex = 13
    toggleIndicator.Parent = btn

    local togCorner = Instance.new("UICorner")
    togCorner.CornerRadius = UDim.new(1, 0)
    togCorner.Parent = toggleIndicator

    local togCircle = Instance.new("Frame")
    togCircle.Size = UDim2.new(0, 14, 0, 14)
    togCircle.Position = UDim2.new(0, 3, 0.5, -7)
    togCircle.BackgroundColor3 = COLORS.subtext
    togCircle.BorderSizePixel = 0
    togCircle.ZIndex = 14
    togCircle.Parent = toggleIndicator

    local togCircleCorner = Instance.new("UICorner")
    togCircleCorner.CornerRadius = UDim.new(1, 0)
    togCircleCorner.Parent = togCircle

    local active = false

    local function setActive(state)
        active = state
        if state then
            TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.green}):Play()
            TweenService:Create(togCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 19, 0.5, -7), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = COLORS.green}):Play()
        else
            TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.border}):Play()
            TweenService:Create(togCircle, TweenInfo.new(0.2), {Position = UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = COLORS.subtext}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Color = COLORS.border}):Play()
        end
    end

    -- Hover effect
    btn.MouseEnter:Connect(function()
        if not active then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if not active then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.bgSecond}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        active = not active
        setActive(active)
        callback(active)
    end)

    return btn, setActive
end

-- ══════════════════════════════════════════
-- SEPARADOR CON TÍTULO
-- ══════════════════════════════════════════
local function createSeparator(text)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, 0, 0, 24)
    sep.BackgroundTransparency = 1
    sep.ZIndex = 12
    sep.Parent = scrollFrame

    local sepLine = Instance.new("Frame")
    sepLine.Size = UDim2.new(1, 0, 0, 1)
    sepLine.Position = UDim2.new(0, 0, 0.5, 0)
    sepLine.BackgroundColor3 = COLORS.border
    sepLine.BorderSizePixel = 0
    sepLine.ZIndex = 12
    sepLine.Parent = sep

    local sepText = Instance.new("TextLabel")
    sepText.Size = UDim2.new(0, 120, 1, 0)
    sepText.Position = UDim2.new(0.5, -60, 0, 0)
    sepText.BackgroundColor3 = COLORS.bg
    sepText.Text = "  " .. text .. "  "
    sepText.TextColor3 = COLORS.accent
    sepText.Font = Enum.Font.GothamBold
    sepText.TextSize = 11
    sepText.BorderSizePixel = 0
    sepText.ZIndex = 13
    sepText.Parent = sep
end

-- ══════════════════════════════════════════
-- LÓGICA AUTO FARM POR TRABAJO
-- ══════════════════════════════════════════

-- Variables de control
local farmConnections = {}
local activeJob = nil

local function stopAllFarms()
    for _, conn in pairs(farmConnections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    farmConnections = {}
    activeJob = nil
    CONFIG.farming = false
    setStatus("Inactivo", COLORS.red)
end

-- Función para mover al personaje a una posición
local function walkTo(pos)
    if humanoid and humanoid.Health > 0 then
        humanoid:MoveTo(pos)
        local arrived = humanoid.MoveToFinished:Wait(8)
        return arrived
    end
    return false
end

-- Función para encontrar objetos del juego
local function findNearestPart(name, maxDist)
    maxDist = maxDist or 50
    local nearest, nearDist = nil, maxDist
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find(name:lower()) then
            if obj:IsA("BasePart") then
                local dist = (rootPart.Position - obj.Position).Magnitude
                if dist < nearDist then
                    nearest = obj
                    nearDist = dist
                end
            end
        end
    end
    return nearest
end

-- Función para simular click/interacción con proximidad
local function interactWithPart(part)
    if part then
        local args = {part}
        -- Trigger proximity prompt si existe
        for _, pp in ipairs(part:GetDescendants()) do
            if pp:IsA("ProximityPrompt") then
                fireproximityprompt(pp)
                return true
            end
        end
        -- Intentar clickdetector
        for _, cd in ipairs(part:GetDescendants()) do
            if cd:IsA("ClickDetector") then
                fireclickdetector(cd)
                return true
            end
        end
    end
    return false
end

-- Función genérica de farm con RemoteEvent
local function fireRemote(remoteName, ...)
    local remotes = ReplicatedStorage:FindFirstChild("RemoteEvents") 
        or ReplicatedStorage:FindFirstChild("Remotes")
        or ReplicatedStorage
    
    local remote = remotes:FindFirstChild(remoteName, true)
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(...)
        return true
    end
    return false
end

-- ══════════════════════════════════════════
-- FARMS ESPECÍFICOS POR TRABAJO
-- ══════════════════════════════════════════

local FARMS = {}

-- 💰 CAJERO
FARMS["Cajero"] = function(active)
    if not active then return end
    setStatus("Trabajando: Cajero 💰", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            -- Buscar caja registradora
            local register = findNearestPart("Register") or findNearestPart("Cashier") or findNearestPart("Counter")
            if register then
                walkTo(register.Position)
                wait(0.3)
                interactWithPart(register)
            end
            -- Atender clientes
            fireRemote("CashierAction")
            fireRemote("ScanItem")
            wait(CONFIG.farmDelay)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🍕 PIZZERO
FARMS["Pizzero"] = function(active)
    if not active then return end
    setStatus("Trabajando: Pizzero 🍕", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local doughStation = findNearestPart("Dough") or findNearestPart("Pizza")
            local oven = findNearestPart("Oven")
            local cutStation = findNearestPart("Cut")
            local deliverStation = findNearestPart("Box") or findNearestPart("Deliver")
            
            if doughStation then walkTo(doughStation.Position); interactWithPart(doughStation); wait(0.5) end
            if oven then walkTo(oven.Position); interactWithPart(oven); wait(1) end
            if cutStation then walkTo(cutStation.Position); interactWithPart(cutStation); wait(0.5) end
            if deliverStation then walkTo(deliverStation.Position); interactWithPart(deliverStation); wait(0.3) end
            
            fireRemote("PizzaAction")
            fireRemote("MakePizza")
            wait(CONFIG.farmDelay + 0.5)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- ✂️ ESTILISTA
FARMS["Estilista"] = function(active)
    if not active then return end
    setStatus("Trabajando: Estilista ✂️", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local chair = findNearestPart("StylistChair") or findNearestPart("Salon") or findNearestPart("HairStation")
            if chair then
                walkTo(chair.Position)
                interactWithPart(chair)
                wait(0.8)
            end
            fireRemote("StylistAction")
            fireRemote("CutHair")
            wait(CONFIG.farmDelay + 0.3)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🧹 CONSERJE
FARMS["Conserje"] = function(active)
    if not active then return end
    setStatus("Trabajando: Conserje 🧹", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            -- Buscar manchas/suciedad para limpiar
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("stain") or obj.Name:lower():find("dirt") or obj.Name:lower():find("spill") then
                    if obj:IsA("BasePart") then
                        local dist = (rootPart.Position - obj.Position).Magnitude
                        if dist < 100 then
                            walkTo(obj.Position)
                            interactWithPart(obj)
                            wait(0.3)
                        end
                    end
                end
            end
            fireRemote("JanitorAction")
            fireRemote("CleanFloor")
            wait(CONFIG.farmDelay)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 📚 DOCENTE
FARMS["Docente"] = function(active)
    if not active then return end
    setStatus("Trabajando: Docente 📚", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local board = findNearestPart("Board") or findNearestPart("Whiteboard") or findNearestPart("Blackboard")
            local desk = findNearestPart("TeacherDesk") or findNearestPart("Podium")
            
            if board then walkTo(board.Position); interactWithPart(board); wait(0.5) end
            if desk then walkTo(desk.Position); interactWithPart(desk); wait(0.3) end
            
            fireRemote("TeacherAction")
            fireRemote("TeachLesson")
            wait(CONFIG.farmDelay + 0.8)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🪓 LEÑADOR
FARMS["Leñador"] = function(active)
    if not active then return end
    setStatus("Trabajando: Leñador 🪓", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            -- Buscar árbol más cercano
            local tree = findNearestPart("Tree") or findNearestPart("Wood") or findNearestPart("Log")
            if tree then
                walkTo(tree.Position)
                interactWithPart(tree)
                wait(1.2)
                -- Llevar tronco
                local dropZone = findNearestPart("WoodDrop") or findNearestPart("Sawmill")
                if dropZone then
                    walkTo(dropZone.Position)
                    interactWithPart(dropZone)
                    wait(0.3)
                end
            end
            fireRemote("LumberjackAction")
            fireRemote("ChopTree")
            wait(CONFIG.farmDelay + 0.5)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🛒 VENDEDOR
FARMS["Vendedor"] = function(active)
    if not active then return end
    setStatus("Trabajando: Vendedor 🛒", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local stall = findNearestPart("Stall") or findNearestPart("Shop") or findNearestPart("Stand")
            if stall then
                walkTo(stall.Position)
                interactWithPart(stall)
                wait(0.6)
            end
            fireRemote("SellerAction")
            fireRemote("SellItem")
            wait(CONFIG.farmDelay + 0.2)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- ⛏️ MINERO
FARMS["Minero"] = function(active)
    if not active then return end
    setStatus("Trabajando: Minero ⛏️", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local rock = findNearestPart("Rock") or findNearestPart("Ore") or findNearestPart("Mine")
            if rock then
                walkTo(rock.Position)
                interactWithPart(rock)
                wait(1.0)
                -- Depositar mineral
                local deposit = findNearestPart("Deposit") or findNearestPart("Cart")
                if deposit then
                    walkTo(deposit.Position)
                    interactWithPart(deposit)
                    wait(0.3)
                end
            end
            fireRemote("MinerAction")
            fireRemote("MineRock")
            wait(CONFIG.farmDelay + 0.4)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 📦 CADETE / REPOSITOR
FARMS["Cadete"] = function(active)
    if not active then return end
    setStatus("Trabajando: Cadete 📦", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local pickup = findNearestPart("Package") or findNearestPart("Box") or findNearestPart("Parcel")
            if pickup then
                walkTo(pickup.Position)
                interactWithPart(pickup)
                wait(0.5)
                local dropOff = findNearestPart("DeliveryPoint") or findNearestPart("Destination")
                if dropOff then
                    walkTo(dropOff.Position)
                    interactWithPart(dropOff)
                    wait(0.3)
                end
            end
            fireRemote("CadeteAction")
            wait(CONFIG.farmDelay + 0.3)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🏪 REPOSITOR
FARMS["Repositor"] = function(active)
    if not active then return end
    setStatus("Trabajando: Repositor 🏪", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local stock = findNearestPart("Shelf") or findNearestPart("Stock") or findNearestPart("Stockroom")
            local shelf = findNearestPart("EmptyShelf") or findNearestPart("DisplayShelf")
            
            if stock then walkTo(stock.Position); interactWithPart(stock); wait(0.5) end
            if shelf then walkTo(shelf.Position); interactWithPart(shelf); wait(0.5) end
            
            fireRemote("StockerAction")
            fireRemote("RestockShelf")
            wait(CONFIG.farmDelay + 0.3)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🚕 TAXISTA
FARMS["Taxista"] = function(active)
    if not active then return end
    setStatus("Trabajando: Taxista 🚕", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local taxiSpawn = findNearestPart("TaxiSpawn") or findNearestPart("Taxi") or findNearestPart("Car")
            local passenger = findNearestPart("Passenger") or findNearestPart("Customer")
            
            if taxiSpawn then walkTo(taxiSpawn.Position); interactWithPart(taxiSpawn); wait(0.5) end
            if passenger then walkTo(passenger.Position); interactWithPart(passenger); wait(0.5) end
            
            fireRemote("TaxiAction")
            fireRemote("PickupPassenger")
            wait(CONFIG.farmDelay + 1.0)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- 🎣 PESCADOR
FARMS["Pescador"] = function(active)
    if not active then return end
    setStatus("Trabajando: Pescador 🎣", COLORS.green)
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not CONFIG.farming then connection:Disconnect() return end
        pcall(function()
            local fishingSpot = findNearestPart("FishingSpot") or findNearestPart("Pier") or findNearestPart("Dock")
            if fishingSpot then
                walkTo(fishingSpot.Position)
                interactWithPart(fishingSpot)
                wait(2.0) -- Tiempo de pesca
            end
            -- Vender pescado
            local sellPoint = findNearestPart("FishSell") or findNearestPart("Market")
            if sellPoint then walkTo(sellPoint.Position); interactWithPart(sellPoint); wait(0.3) end
            
            fireRemote("FishermanAction")
            fireRemote("CastRod")
            wait(CONFIG.farmDelay + 1.5)
        end)
    end)
    table.insert(farmConnections, connection)
end

-- ══════════════════════════════════════════
-- AGREGAR BOTONES AL GUI
-- ══════════════════════════════════════════

createSeparator("── TRABAJOS ──")

local jobList = {
    {"Cajero", "💰", "Cajero"},
    {"Pizzero", "🍕", "Pizzero"},
    {"Estilista", "✂️", "Estilista"},
    {"Conserje", "🧹", "Conserje"},
    {"Docente", "📚", "Docente"},
    {"Leñador", "🪓", "Leñador"},
    {"Vendedor", "🛒", "Vendedor"},
    {"Minero", "⛏️", "Minero"},
    {"Cadete", "📦", "Cadete"},
    {"Repositor", "🏪", "Repositor"},
    {"Taxista", "🚕", "Taxista"},
    {"Pescador", "🎣", "Pescador"},
}

local jobToggles = {}

for _, job in ipairs(jobList) do
    local btn, setActive = createJobBtn(job[1], job[2], function(active)
        if active then
            -- Desactivar todos los demás
            for jobName, toggle in pairs(jobToggles) do
                if jobName ~= job[3] then toggle(false) end
            end
            stopAllFarms()
            CONFIG.farming = true
            FARMS[job[3]](true)
        else
            stopAllFarms()
        end
    end)
    jobToggles[job[3]] = setActive
end

-- ── CONFIGURACIÓN EXTRA ──
createSeparator("── OPCIONES ──")

-- Toggle Auto Sprint
local function createToggle(name, icon, defaultVal, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundColor3 = COLORS.bgSecond
    frame.BorderSizePixel = 0
    frame.ZIndex = 12
    frame.Parent = scrollFrame

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 38, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = icon .. "  " .. name
    lbl.TextColor3 = COLORS.text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 13
    lbl.Parent = frame

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 36, 0, 20)
    tog.Position = UDim2.new(1, -46, 0.5, -10)
    tog.BackgroundColor3 = defaultVal and COLORS.green or COLORS.border
    tog.Text = ""
    tog.BorderSizePixel = 0
    tog.ZIndex = 13
    tog.AutoButtonColor = false
    tog.Parent = frame

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(1, 0)
    tCorner.Parent = tog

    local circ = Instance.new("Frame")
    circ.Size = UDim2.new(0, 14, 0, 14)
    circ.Position = defaultVal and UDim2.new(0, 19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    circ.BackgroundColor3 = Color3.fromRGB(255,255,255)
    circ.BorderSizePixel = 0
    circ.ZIndex = 14
    circ.Parent = tog

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(1, 0)
    cCorner.Parent = circ

    local val = defaultVal

    tog.MouseButton1Click:Connect(function()
        val = not val
        TweenService:Create(tog, TweenInfo.new(0.2), {BackgroundColor3 = val and COLORS.green or COLORS.border}):Play()
        TweenService:Create(circ, TweenInfo.new(0.2), {Position = val and UDim2.new(0,19,0.5,-7) or UDim2.new(0,3,0.5,-7)}):Play()
        callback(val)
    end)
end

createToggle("Auto Sprint", "🏃", CONFIG.autoSprint, function(v)
    CONFIG.autoSprint = v
    if v then
        humanoid.WalkSpeed = CONFIG.sprintSpeed
    else
        humanoid.WalkSpeed = CONFIG.walkSpeed
    end
end)

createToggle("Anti-AFK", "💤", CONFIG.antiAFK, function(v)
    CONFIG.antiAFK = v
end)

-- ══════════════════════════════════════════
-- CÍRCULO FLOTANTE (cuando el GUI está oculto)
-- ══════════════════════════════════════════
local floatCircle = Instance.new("TextButton")
floatCircle.Name = "FloatCircle"
floatCircle.Size = UDim2.new(0, 56, 0, 56)
floatCircle.Position = UDim2.new(1, -80, 0.5, -28)
floatCircle.BackgroundColor3 = COLORS.accent
floatCircle.Text = "🏘"
floatCircle.TextScaled = true
floatCircle.Font = Enum.Font.GothamBold
floatCircle.TextColor3 = Color3.fromRGB(255,255,255)
floatCircle.BorderSizePixel = 0
floatCircle.ZIndex = 20
floatCircle.Visible = false
floatCircle.AutoButtonColor = false
floatCircle.Parent = screenGui

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = floatCircle

-- Sombra del círculo
local circleShadow = Instance.new("ImageLabel")
circleShadow.Size = UDim2.new(1, 20, 1, 20)
circleShadow.Position = UDim2.new(0, -10, 0, -5)
circleShadow.BackgroundTransparency = 1
circleShadow.Image = "rbxassetid://6014261993"
circleShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
circleShadow.ImageTransparency = 0.5
circleShadow.ScaleType = Enum.ScaleType.Slice
circleShadow.SliceCenter = Rect.new(49, 49, 450, 450)
circleShadow.ZIndex = 19
circleShadow.Parent = floatCircle

-- Stroke del círculo
local circleStroke = Instance.new("UIStroke")
circleStroke.Color = Color3.fromRGB(130, 133, 255)
circleStroke.Thickness = 2
circleStroke.Parent = floatCircle

-- Animación de pulso del círculo
local function pulseCircle()
    while floatCircle.Visible do
        TweenService:Create(circleStroke, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            Thickness = 4
        }):Play()
        wait(2)
    end
end

-- Hacer arrastrable el círculo
makeDraggable(floatCircle)
makeDraggable(mainFrame, titleBar)

-- ══════════════════════════════════════════
-- BOTÓN X: OCULTAR / MOSTRAR
-- ══════════════════════════════════════════
local function hideGui()
    CONFIG.guiVisible = false
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(
            mainFrame.Position.X.Scale,
            mainFrame.Position.X.Offset + 160,
            mainFrame.Position.Y.Scale,
            mainFrame.Position.Y.Offset + 230
        )
    }):Play()
    task.delay(0.3, function()
        mainFrame.Visible = false
        floatCircle.Visible = true
        -- Iniciar pulso
        task.spawn(pulseCircle)
    end)
end

local function showGui()
    CONFIG.guiVisible = true
    mainFrame.Visible = true
    mainFrame.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 320, 0, 460)
    }):Play()
    floatCircle.Visible = false
end

closeBtn.MouseButton1Click:Connect(hideGui)
floatCircle.MouseButton1Click:Connect(showGui)

-- Hover en el botón X
closeBtn.MouseEnter:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
    TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3 = COLORS.red}):Play()
end)

-- ══════════════════════════════════════════
-- SISTEMAS PASIVOS
-- ══════════════════════════════════════════

-- Auto Sprint
RunService.Heartbeat:Connect(function()
    pcall(function()
        if CONFIG.autoSprint and humanoid and humanoid.Health > 0 then
            humanoid.WalkSpeed = CONFIG.sprintSpeed
        end
    end)
end)

-- Anti-AFK
local antiAfkConn
antiAfkConn = RunService.Heartbeat:Connect(function()
    if CONFIG.antiAFK then
        pcall(function()
            -- Simula micro movimiento para evitar desconexión
            local vjs = game:GetService("VirtualInputManager")
            -- Alternativa: VirtualUser
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.new(0,0), CFrame.new())
            wait(0.1)
            vu:Button2Up(Vector2.new(0,0), CFrame.new())
        end)
    end
end)

-- Regenerar referencia al personaje tras muerte
player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    if CONFIG.farming then
        setStatus("Respawneado - reiniciando...", COLORS.yellow)
        wait(2)
    end
end)

-- ══════════════════════════════════════════
-- ANIMACIÓN DE ENTRADA
-- ══════════════════════════════════════════
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 320, 0, 460),
    Position = UDim2.new(0.5, -160, 0.5, -230)
}):Play()

print("✅ Bloxburg Auto Farm cargado correctamente")
print("🏘 GUI visible - Usa el botón ✕ para minimizar")
