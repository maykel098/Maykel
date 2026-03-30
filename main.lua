-- ============================================================
--  UNIVERSAL LOCATOR & ATTRACTOR  |  Delta Executor
--  Pega y ejecuta directamente en Delta
-- ============================================================

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")

local player   = Players.LocalPlayer
local camera   = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()

player.CharacterAdded:Connect(function(char)
    character = char
end)

-- ============================================================
--  CONFIGURACIÓN
-- ============================================================
local CONFIG = {
    attractForce = 120,
    scanRadius   = 500,
    refreshRate  = 0.5,
    maxListItems = 30,
    highlightColor = Color3.fromRGB(0, 255, 180),
    toggleKey    = Enum.KeyCode.F9,
}

-- ============================================================
--  LIMPIAR GUI ANTERIOR (evita duplicados al re-ejecutar)
-- ============================================================
local existing = CoreGui:FindFirstChild("UniversalLocatorGUI")
if existing then existing:Destroy() end

-- ============================================================
--  CONSTRUCCIÓN DEL GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "UniversalLocatorGUI"
ScreenGui.ResetOnSpawn     = false
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset   = true

-- En Delta usamos CoreGui para que el GUI persista
-- syn.protect_gui es compatible con la mayoría de executors modernos
pcall(function()
    if syn then syn.protect_gui(ScreenGui) end
end)
ScreenGui.Parent = CoreGui

-- ── Ventana principal ──────────────────────────────────────
local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, 340, 0, 480)
MainFrame.Position         = UDim2.new(0, 20, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent           = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local UIStroke = Instance.new("UIStroke")
UIStroke.Color     = Color3.fromRGB(0, 200, 140)
UIStroke.Thickness = 1.5
UIStroke.Parent    = MainFrame

-- ── Barra de título ────────────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Name             = "TitleBar"
TitleBar.Size             = UDim2.new(1, 0, 0, 38)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = MainFrame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 10)

local TitleCover = Instance.new("Frame")
TitleCover.Size            = UDim2.new(1, 0, 0.5, 0)
TitleCover.Position        = UDim2.new(0, 0, 0.5, 0)
TitleCover.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
TitleCover.BorderSizePixel = 0
TitleCover.Parent          = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size            = UDim2.new(1, -80, 1, 0)
TitleLabel.Position        = UDim2.new(0, 12, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text            = "🔍 UNIVERSAL LOCATOR"
TitleLabel.Font            = Enum.Font.GothamBold
TitleLabel.TextSize        = 14
TitleLabel.TextColor3      = Color3.fromRGB(255, 255, 255)
TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
TitleLabel.Parent          = TitleBar

local MinBtn = Instance.new("TextButton")
MinBtn.Size               = UDim2.new(0, 28, 0, 28)
MinBtn.Position           = UDim2.new(1, -60, 0.5, -14)
MinBtn.BackgroundColor3   = Color3.fromRGB(255, 200, 0)
MinBtn.Text               = "—"
MinBtn.Font               = Enum.Font.GothamBold
MinBtn.TextSize           = 14
MinBtn.TextColor3         = Color3.fromRGB(0, 0, 0)
MinBtn.BorderSizePixel    = 0
MinBtn.Parent             = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(1, 0)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 28, 0, 28)
CloseBtn.Position         = UDim2.new(1, -28, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.Text             = "✕"
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.TextSize         = 14
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- ── Contenido ──────────────────────────────────────────────
local Content = Instance.new("Frame")
Content.Name             = "Content"
Content.Size             = UDim2.new(1, 0, 1, -38)
Content.Position         = UDim2.new(0, 0, 0, 38)
Content.BackgroundTransparency = 1
Content.Parent           = MainFrame

-- Label radio
local RadiusLabel = Instance.new("TextLabel")
RadiusLabel.Size          = UDim2.new(1, -20, 0, 22)
RadiusLabel.Position      = UDim2.new(0, 10, 0, 8)
RadiusLabel.BackgroundTransparency = 1
RadiusLabel.Text          = "Radio: 500 studs"
RadiusLabel.Font          = Enum.Font.Gotham
RadiusLabel.TextSize      = 12
RadiusLabel.TextColor3    = Color3.fromRGB(0, 210, 150)
RadiusLabel.TextXAlignment = Enum.TextXAlignment.Left
RadiusLabel.Parent        = Content

-- Slider radio
local RadiusSlider = Instance.new("Frame")
RadiusSlider.Name         = "RadiusSlider"
RadiusSlider.Size         = UDim2.new(1, -20, 0, 8)
RadiusSlider.Position     = UDim2.new(0, 10, 0, 32)
RadiusSlider.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
RadiusSlider.BorderSizePixel = 0
RadiusSlider.Parent       = Content
Instance.new("UICorner", RadiusSlider).CornerRadius = UDim.new(1, 0)

local RadiusFill = Instance.new("Frame")
RadiusFill.Name           = "Fill"
RadiusFill.Size           = UDim2.new(0.5, 0, 1, 0)
RadiusFill.BackgroundColor3 = Color3.fromRGB(0, 200, 140)
RadiusFill.BorderSizePixel = 0
RadiusFill.Parent         = RadiusSlider
Instance.new("UICorner", RadiusFill).CornerRadius = UDim.new(1, 0)

-- ── Filtros ────────────────────────────────────────────────
local FilterFrame = Instance.new("Frame")
FilterFrame.Size          = UDim2.new(1, -20, 0, 32)
FilterFrame.Position      = UDim2.new(0, 10, 0, 46)
FilterFrame.BackgroundTransparency = 1
FilterFrame.Parent        = Content

local UIListH = Instance.new("UIListLayout")
UIListH.FillDirection     = Enum.FillDirection.Horizontal
UIListH.Padding           = UDim.new(0, 6)
UIListH.VerticalAlignment = Enum.VerticalAlignment.Center
UIListH.Parent            = FilterFrame

local function makeFilterBtn(label, color, default)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 88, 0, 26)
    btn.BackgroundColor3 = default and color or Color3.fromRGB(30, 35, 50)
    btn.Text             = label
    btn.Font             = Enum.Font.GothamBold
    btn.TextSize         = 11
    btn.TextColor3       = Color3.fromRGB(255, 255, 255)
    btn.BorderSizePixel  = 0
    btn.Parent           = FilterFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn:SetAttribute("active", default)
    return btn
end

local BtnParts  = makeFilterBtn("⬡ Partes",     Color3.fromRGB(80, 120, 220), true)
local BtnNPCs   = makeFilterBtn("🧍 NPCs",       Color3.fromRGB(220, 120, 0),  true)
local BtnModels = makeFilterBtn("📦 Modelos",    Color3.fromRGB(180, 50, 220), true)

-- ── Búsqueda ───────────────────────────────────────────────
local SearchBox = Instance.new("TextBox")
SearchBox.Size            = UDim2.new(1, -20, 0, 28)
SearchBox.Position        = UDim2.new(0, 10, 0, 84)
SearchBox.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
SearchBox.BorderSizePixel = 0
SearchBox.PlaceholderText = "🔎  Buscar por nombre..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 120, 140)
SearchBox.Text            = ""
SearchBox.Font            = Enum.Font.Gotham
SearchBox.TextSize        = 12
SearchBox.TextColor3      = Color3.fromRGB(220, 240, 255)
SearchBox.ClearTextOnFocus = false
SearchBox.Parent          = Content
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", SearchBox).Color = Color3.fromRGB(0, 160, 110)

-- ── Lista scroll ───────────────────────────────────────────
local ListContainer = Instance.new("ScrollingFrame")
ListContainer.Name        = "ObjectList"
ListContainer.Size        = UDim2.new(1, -20, 1, -230)
ListContainer.Position    = UDim2.new(0, 10, 0, 120)
ListContainer.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
ListContainer.BorderSizePixel = 0
ListContainer.ScrollBarThickness = 4
ListContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 140)
ListContainer.CanvasSize  = UDim2.new(0, 0, 0, 0)
ListContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
ListContainer.Parent      = Content
Instance.new("UICorner", ListContainer).CornerRadius = UDim.new(0, 8)

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder      = Enum.SortOrder.LayoutOrder
ListLayout.Padding        = UDim.new(0, 3)
ListLayout.Parent         = ListContainer

local ListPadding = Instance.new("UIPadding")
ListPadding.PaddingTop    = UDim.new(0, 4)
ListPadding.PaddingLeft   = UDim.new(0, 4)
ListPadding.PaddingRight  = UDim.new(0, 4)
ListPadding.Parent        = ListContainer

-- ── Panel inferior ─────────────────────────────────────────
local BottomPanel = Instance.new("Frame")
BottomPanel.Size          = UDim2.new(1, -20, 0, 80)
BottomPanel.Position      = UDim2.new(0, 10, 1, -90)
BottomPanel.BackgroundTransparency = 1
BottomPanel.Parent        = Content

local AttractAllBtn = Instance.new("TextButton")
AttractAllBtn.Size        = UDim2.new(0.48, 0, 0, 34)
AttractAllBtn.Position    = UDim2.new(0, 0, 0, 0)
AttractAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
AttractAllBtn.Text        = "⚡ ATRAER TODO"
AttractAllBtn.Font        = Enum.Font.GothamBold
AttractAllBtn.TextSize    = 12
AttractAllBtn.TextColor3  = Color3.fromRGB(255, 255, 255)
AttractAllBtn.BorderSizePixel = 0
AttractAllBtn.Parent      = BottomPanel
Instance.new("UICorner", AttractAllBtn).CornerRadius = UDim.new(0, 8)

local StopBtn = Instance.new("TextButton")
StopBtn.Size              = UDim2.new(0.48, 0, 0, 34)
StopBtn.Position          = UDim2.new(0.52, 0, 0, 0)
StopBtn.BackgroundColor3  = Color3.fromRGB(200, 50, 50)
StopBtn.Text              = "⛔ DETENER"
StopBtn.Font              = Enum.Font.GothamBold
StopBtn.TextSize          = 12
StopBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
StopBtn.BorderSizePixel   = 0
StopBtn.Parent            = BottomPanel
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size          = UDim2.new(1, 0, 0, 20)
StatusLabel.Position      = UDim2.new(0, 0, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text          = "Listo  |  F9 = ocultar/mostrar"
StatusLabel.Font          = Enum.Font.Gotham
StatusLabel.TextSize      = 11
StatusLabel.TextColor3    = Color3.fromRGB(120, 150, 180)
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center
StatusLabel.Parent        = BottomPanel

local CountLabel = Instance.new("TextLabel")
CountLabel.Size           = UDim2.new(1, 0, 0, 18)
CountLabel.Position       = UDim2.new(0, 0, 0, 60)
CountLabel.BackgroundTransparency = 1
CountLabel.Text           = "0 objetos encontrados"
CountLabel.Font           = Enum.Font.Gotham
CountLabel.TextSize       = 11
CountLabel.TextColor3     = Color3.fromRGB(0, 200, 140)
CountLabel.TextXAlignment = Enum.TextXAlignment.Center
CountLabel.Parent         = BottomPanel

-- ── Botón flotante ─────────────────────────────────────────
local FloatBtn = Instance.new("TextButton")
FloatBtn.Size             = UDim2.new(0, 44, 0, 44)
FloatBtn.Position         = UDim2.new(0, 20, 0.5, -22)
FloatBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 100)
FloatBtn.Text             = "🔍"
FloatBtn.Font             = Enum.Font.GothamBold
FloatBtn.TextSize         = 20
FloatBtn.BorderSizePixel  = 0
FloatBtn.Visible          = false
FloatBtn.Parent           = ScreenGui
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

-- ============================================================
--  ESTADO
-- ============================================================
local attracting       = false
local attractedTargets = {}
local scannedObjects   = {}

-- ============================================================
--  UTILIDADES
-- ============================================================
local function getRootPart()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getPosition(obj)
    if obj:IsA("BasePart") then
        return obj.Position
    elseif obj:IsA("Model") then
        local r = obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChild("PrimaryPart")
            or obj:FindFirstChildWhichIsA("BasePart")
        return r and r.Position
    end
end

local function getDistance(obj)
    local root = getRootPart()
    if not root then return math.huge end
    local pos  = getPosition(obj)
    if not pos  then return math.huge end
    return (root.Position - pos).Magnitude
end

local function isNPC(obj)
    return obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid") ~= nil
end

-- ============================================================
--  HIGHLIGHTS  (SelectionBox)
-- ============================================================
local highlights = {}

local function addHighlight(obj, color)
    if highlights[obj] then return end
    local h = Instance.new("SelectionBox")
    h.Adornee             = obj
    h.Color3              = color or CONFIG.highlightColor
    h.LineThickness       = 0.06
    h.SurfaceColor3       = color or CONFIG.highlightColor
    h.SurfaceTransparency = 0.85
    h.Parent              = workspace
    highlights[obj]       = h
end

local function removeHighlight(obj)
    if highlights[obj] then highlights[obj]:Destroy() highlights[obj] = nil end
end

local function clearHighlights()
    for obj, h in pairs(highlights) do h:Destroy() end
    highlights = {}
end

-- ============================================================
--  ESCANEO
-- ============================================================
local function kindColor(k)
    if k == "NPC"    then return Color3.fromRGB(255, 160, 30) end
    if k == "Modelo" then return Color3.fromRGB(180, 80, 255) end
    return Color3.fromRGB(80, 150, 255)
end

local function scanObjects()
    local root = getRootPart()
    if not root then return {} end

    local showParts   = BtnParts:GetAttribute("active")
    local showNPCs    = BtnNPCs:GetAttribute("active")
    local showModels  = BtnModels:GetAttribute("active")
    local filter      = SearchBox.Text:lower()
    local results     = {}

    for _, obj in ipairs(workspace:GetDescendants()) do
        if character and obj:IsDescendantOf(character) then continue end

        local valid, kind = false, "Parte"

        if isNPC(obj) and showNPCs then
            if obj.Parent == workspace or obj.Parent:IsA("Folder") then
                valid, kind = true, "NPC"
            end
        elseif obj:IsA("Model") and not isNPC(obj) and showModels then
            if obj.Parent == workspace or obj.Parent:IsA("Folder") then
                valid, kind = true, "Modelo"
            end
        elseif obj:IsA("BasePart") and showParts then
            if not obj.Parent:IsA("Model") then
                valid, kind = true, "Parte"
            end
        end

        if valid then
            local dist = getDistance(obj)
            if dist <= CONFIG.scanRadius then
                local name = obj.Name:lower()
                if filter == "" or name:find(filter, 1, true) then
                    table.insert(results, { obj = obj, dist = dist, kind = kind })
                end
            end
        end

        if #results >= CONFIG.maxListItems then break end
    end

    table.sort(results, function(a, b) return a.dist < b.dist end)
    return results
end

-- ============================================================
--  CONSTRUIR LISTA
-- ============================================================
local listItems = {}

local function clearList()
    for _, v in ipairs(listItems) do v:Destroy() end
    listItems = {}
end

local function buildList(results)
    clearList()
    for i, entry in ipairs(results) do
        local row = Instance.new("Frame")
        row.Size             = UDim2.new(1, 0, 0, 38)
        row.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
        row.BorderSizePixel  = 0
        row.LayoutOrder      = i
        row.Parent           = ListContainer
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local tag = Instance.new("Frame")
        tag.Size             = UDim2.new(0, 52, 0, 22)
        tag.Position         = UDim2.new(0, 6, 0.5, -11)
        tag.BackgroundColor3 = kindColor(entry.kind)
        tag.BorderSizePixel  = 0
        tag.Parent           = row
        Instance.new("UICorner", tag).CornerRadius = UDim.new(0, 4)

        local tagLbl = Instance.new("TextLabel")
        tagLbl.Size               = UDim2.new(1, 0, 1, 0)
        tagLbl.BackgroundTransparency = 1
        tagLbl.Text               = entry.kind
        tagLbl.Font               = Enum.Font.GothamBold
        tagLbl.TextSize           = 9
        tagLbl.TextColor3         = Color3.fromRGB(255, 255, 255)
        tagLbl.Parent             = tag

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size              = UDim2.new(1, -170, 0, 18)
        nameLbl.Position          = UDim2.new(0, 64, 0, 4)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text              = entry.obj.Name
        nameLbl.Font              = Enum.Font.Gotham
        nameLbl.TextSize          = 12
        nameLbl.TextColor3        = Color3.fromRGB(220, 235, 255)
        nameLbl.TextXAlignment    = Enum.TextXAlignment.Left
        nameLbl.TextTruncate      = Enum.TextTruncate.AtEnd
        nameLbl.Parent            = row

        local distLbl = Instance.new("TextLabel")
        distLbl.Size              = UDim2.new(1, -170, 0, 14)
        distLbl.Position          = UDim2.new(0, 64, 0, 22)
        distLbl.BackgroundTransparency = 1
        distLbl.Text              = string.format("%.1f studs", entry.dist)
        distLbl.Font              = Enum.Font.Gotham
        distLbl.TextSize          = 10
        distLbl.TextColor3        = Color3.fromRGB(100, 160, 140)
        distLbl.TextXAlignment    = Enum.TextXAlignment.Left
        distLbl.Parent            = row

        -- Botón Atraer
        local aBtn = Instance.new("TextButton")
        aBtn.Size             = UDim2.new(0, 56, 0, 26)
        aBtn.Position         = UDim2.new(1, -120, 0.5, -13)
        aBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
        aBtn.Text             = "⚡Atraer"
        aBtn.Font             = Enum.Font.GothamBold
        aBtn.TextSize         = 10
        aBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        aBtn.BorderSizePixel  = 0
        aBtn.Parent           = row
        Instance.new("UICorner", aBtn).CornerRadius = UDim.new(0, 5)

        -- Botón Ver
        local vBtn = Instance.new("TextButton")
        vBtn.Size             = UDim2.new(0, 46, 0, 26)
        vBtn.Position         = UDim2.new(1, -58, 0.5, -13)
        vBtn.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
        vBtn.Text             = "👁 Ver"
        vBtn.Font             = Enum.Font.GothamBold
        vBtn.TextSize         = 10
        vBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        vBtn.BorderSizePixel  = 0
        vBtn.Parent           = row
        Instance.new("UICorner", vBtn).CornerRadius = UDim.new(0, 5)

        -- Lógica Atraer individual
        aBtn.MouseButton1Click:Connect(function()
            if attractedTargets[entry.obj] then
                attractedTargets[entry.obj] = false
                aBtn.BackgroundColor3       = Color3.fromRGB(0, 170, 110)
                aBtn.Text                   = "⚡Atraer"
                removeHighlight(entry.obj)
            else
                attractedTargets[entry.obj] = true
                aBtn.BackgroundColor3       = Color3.fromRGB(200, 50, 50)
                aBtn.Text                   = "⛔ Stop"
                addHighlight(entry.obj, kindColor(entry.kind))
                StatusLabel.Text = "Atrayendo: " .. entry.obj.Name
            end
        end)

        -- Lógica Ver
        vBtn.MouseButton1Click:Connect(function()
            local pos = getPosition(entry.obj)
            if pos then
                local camOff = pos + Vector3.new(0, 8, 16)
                camera.CameraType = Enum.CameraType.Scriptable
                TweenService:Create(camera, TweenInfo.new(0.8, Enum.EasingStyle.Sine), {
                    CFrame = CFrame.lookAt(camOff, pos)
                }):Play()
                task.delay(4, function()
                    camera.CameraType = Enum.CameraType.Custom
                end)
            end
        end)

        table.insert(listItems, row)
    end
    CountLabel.Text = #results .. " objetos encontrados"
end

-- ============================================================
--  HEARTBEAT — ATRACCIÓN
-- ============================================================
RunService.Heartbeat:Connect(function()
    local root = getRootPart()
    if not root then return end

    for obj, active in pairs(attractedTargets) do
        if not active then continue end
        if not obj or not obj.Parent then
            attractedTargets[obj] = nil
            continue
        end

        local humanoid = obj:IsA("Model") and obj:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid:MoveTo(root.Position)
        else
            local part = obj:IsA("BasePart") and obj
                or (obj:IsA("Model") and (obj.PrimaryPart
                    or obj:FindFirstChild("HumanoidRootPart")
                    or obj:FindFirstChildWhichIsA("BasePart")))
            if part then
                if part.Anchored then part.Anchored = false end
                local dir = root.Position - part.Position
                if dir.Magnitude < 3 then
                    attractedTargets[obj] = false
                    removeHighlight(obj)
                else
                    part.Velocity = dir.Unit * CONFIG.attractForce
                end
            end
        end
    end
end)

-- ============================================================
--  BUCLE DE ESCANEO
-- ============================================================
local lastScan = 0
RunService.RenderStepped:Connect(function()
    local now = tick()
    if now - lastScan < CONFIG.refreshRate then return end
    lastScan = now
    scannedObjects = scanObjects()
    buildList(scannedObjects)
end)

-- ============================================================
--  SLIDER RADIO
-- ============================================================
local draggingRadius = false

RadiusSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingRadius = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingRadius = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingRadius and input.UserInputType == Enum.UserInputType.MouseMovement then
        local sliderX = RadiusSlider.AbsolutePosition.X
        local sliderW = RadiusSlider.AbsoluteSize.X
        local ratio   = math.clamp((input.Position.X - sliderX) / sliderW, 0, 1)
        RadiusFill.Size       = UDim2.new(ratio, 0, 1, 0)
        CONFIG.scanRadius     = math.floor(ratio * 1000)
        RadiusLabel.Text      = "Radio: " .. CONFIG.scanRadius .. " studs"
    end
end)

-- ============================================================
--  FILTROS
-- ============================================================
local function toggleFilter(btn, color)
    local a = not btn:GetAttribute("active")
    btn:SetAttribute("active", a)
    btn.BackgroundColor3 = a and color or Color3.fromRGB(30, 35, 50)
end

BtnParts.MouseButton1Click:Connect(function()  toggleFilter(BtnParts,  Color3.fromRGB(80,120,220)) end)
BtnNPCs.MouseButton1Click:Connect(function()   toggleFilter(BtnNPCs,   Color3.fromRGB(220,120,0))  end)
BtnModels.MouseButton1Click:Connect(function() toggleFilter(BtnModels, Color3.fromRGB(180,50,220)) end)

-- ============================================================
--  ATRAER TODO / DETENER
-- ============================================================
AttractAllBtn.MouseButton1Click:Connect(function()
    if not attracting then
        attracting = true
        AttractAllBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        AttractAllBtn.Text             = "⚡ ATRAYENDO..."
        StatusLabel.Text               = "Atrayendo todos..."
        for _, e in ipairs(scannedObjects) do
            attractedTargets[e.obj] = true
            addHighlight(e.obj, kindColor(e.kind))
        end
    end
end)

StopBtn.MouseButton1Click:Connect(function()
    attracting = false
    AttractAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    AttractAllBtn.Text             = "⚡ ATRAER TODO"
    StatusLabel.Text               = "Detenido"
    for obj in pairs(attractedTargets) do attractedTargets[obj] = false end
    clearHighlights()
end)

-- ============================================================
--  MOSTRAR / OCULTAR
-- ============================================================
local guiVisible = true
local minimized  = false

local function setVisible(v)
    guiVisible        = v
    MainFrame.Visible = v
    FloatBtn.Visible  = not v
end

local function toggleMinimize()
    minimized = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size = UDim2.new(0, 340, 0, minimized and 38 or 480)
    }):Play()
    MinBtn.Text = minimized and "□" or "—"
end

MinBtn.MouseButton1Click:Connect(toggleMinimize)
CloseBtn.MouseButton1Click:Connect(function() setVisible(false) end)
FloatBtn.MouseButton1Click:Connect(function() setVisible(true)  end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CONFIG.toggleKey then
        setVisible(not guiVisible)
    end
end)

-- ============================================================
--  ARRASTRAR VENTANA
-- ============================================================
local dragging, dragStart, startPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("[UniversalLocator] ✅ Ejecutado en Delta. F9 para mostrar/ocultar.")
