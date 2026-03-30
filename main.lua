-- Script principal para Delta
-- Crea GUI, maneja detección, distancia y auto-farm

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Crear RemoteEvent si no existe (para comunicación servidor)
local farmEvent = ReplicatedStorage:FindFirstChild("FarmEvents")
if not farmEvent then
    farmEvent = Instance.new("RemoteEvent")
    farmEvent.Name = "FarmEvents"
    farmEvent.Parent = ReplicatedStorage
end

-- Crear la GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FarmGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Burbuja (minimizable)
local bubble = Instance.new("Frame")
bubble.Name = "Bubble"
bubble.Size = UDim2.new(0, 50, 0, 50)
bubble.Position = UDim2.new(0, 10, 0, 100)
bubble.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
bubble.BackgroundTransparency = 0.2
bubble.BorderSizePixel = 0
bubble.Parent = screenGui

local bubbleCorner = Instance.new("UICorner")
bubbleCorner.CornerRadius = UDim.new(1, 0)
bubbleCorner.Parent = bubble

local bubbleText = Instance.new("TextLabel")
bubbleText.Size = UDim2.new(1, 0, 1, 0)
bubbleText.BackgroundTransparency = 1
bubbleText.Text = "🌾"
bubbleText.TextColor3 = Color3.fromRGB(255, 255, 255)
bubbleText.TextScaled = true
bubbleText.Font = Enum.Font.SourceSansBold
bubbleText.Parent = bubble

-- Panel principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 250)
mainFrame.Position = UDim2.new(0, 70, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 8)
mainCorner.Parent = mainFrame

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Auto Farm"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextScaled = true
title.Font = Enum.Font.SourceSansBold
title.Parent = mainFrame

-- Input para nombre del objeto
local objectNameInput = Instance.new("TextBox")
objectNameInput.Size = UDim2.new(0.8, 0, 0, 30)
objectNameInput.Position = UDim2.new(0.1, 0, 0, 40)
objectNameInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
objectNameInput.Text = ""
objectNameInput.PlaceholderText = "Nombre del objeto"
objectNameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
objectNameInput.TextScaled = true
objectNameInput.Font = Enum.Font.SourceSans
objectNameInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = objectNameInput

-- Botón seleccionar
local setTargetBtn = Instance.new("TextButton")
setTargetBtn.Size = UDim2.new(0.8, 0, 0, 30)
setTargetBtn.Position = UDim2.new(0.1, 0, 0, 75)
setTargetBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
setTargetBtn.Text = "Seleccionar"
setTargetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
setTargetBtn.TextScaled = true
setTargetBtn.Font = Enum.Font.SourceSansBold
setTargetBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = setTargetBtn

-- Etiqueta de distancia
local distanceLabel = Instance.new("TextLabel")
distanceLabel.Size = UDim2.new(0.8, 0, 0, 30)
distanceLabel.Position = UDim2.new(0.1, 0, 0, 110)
distanceLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
distanceLabel.Text = "Distancia: --"
distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distanceLabel.TextScaled = true
distanceLabel.Font = Enum.Font.SourceSans
distanceLabel.Parent = mainFrame

local distCorner = Instance.new("UICorner")
distCorner.CornerRadius = UDim.new(0, 4)
distCorner.Parent = distanceLabel

-- Botón auto-farm toggle
local autoFarmBtn = Instance.new("TextButton")
autoFarmBtn.Size = UDim2.new(0.38, 0, 0, 30)
autoFarmBtn.Position = UDim2.new(0.1, 0, 0, 145)
autoFarmBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
autoFarmBtn.Text = "Auto Farm: OFF"
autoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmBtn.TextScaled = true
autoFarmBtn.Font = Enum.Font.SourceSansBold
autoFarmBtn.Parent = mainFrame

local autoCorner = Instance.new("UICorner")
autoCorner.CornerRadius = UDim.new(0, 4)
autoCorner.Parent = autoFarmBtn

-- Botón recolectar ahora
local collectBtn = Instance.new("TextButton")
collectBtn.Size = UDim2.new(0.38, 0, 0, 30)
collectBtn.Position = UDim2.new(0.52, 0, 0, 145)
collectBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
collectBtn.Text = "Recolectar"
collectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
collectBtn.TextScaled = true
collectBtn.Font = Enum.Font.SourceSansBold
collectBtn.Parent = mainFrame

local collectCorner = Instance.new("UICorner")
collectCorner.CornerRadius = UDim.new(0, 4)
collectCorner.Parent = collectBtn

-- Estado
local targetObject = nil
local autoFarmEnabled = false
local lastCollectionTime = 0
local COLLECTION_COOLDOWN = 1

-- ------------------------------------------------------------
-- FUNCIONES DE ARRASTRE MEJORADO (sin problemas de delta)
-- ------------------------------------------------------------
local function makeDraggable(frame)
	local dragging = false
	local dragStart = nil
	local frameStart = nil
	local connection

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			frameStart = frame.AbsolutePosition
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local newPos = frameStart + delta

			-- Limitar dentro de la pantalla
			local parentSize = frame.Parent.AbsoluteSize
			local minX = 0
			local minY = 0
			local maxX = parentSize.X - frame.AbsoluteSize.X
			local maxY = parentSize.Y - frame.AbsoluteSize.Y
			newPos = Vector2.new(math.clamp(newPos.X, minX, maxX), math.clamp(newPos.Y, minY, maxY))

			-- Convertir a escala
			local newScaleX = newPos.X / parentSize.X
			local newScaleY = newPos.Y / parentSize.Y
			frame.Position = UDim2.new(newScaleX, 0, newScaleY, 0)
		end
	end)
end

makeDraggable(mainFrame)
makeDraggable(bubble)

-- Minimizar/restaurar con burbuja
bubble.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-- ------------------------------------------------------------
-- DETECCIÓN DE OBJETOS
-- ------------------------------------------------------------
local function findObjectByName(name)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj.Name == name and (obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Tool")) then
			if obj:GetAttribute("Farmable") == true then
				return obj
			end
		end
	end
	return nil
end

-- ------------------------------------------------------------
-- CÁLCULO DE DISTANCIA
-- ------------------------------------------------------------
local function getDistanceToTarget()
	if not targetObject then return nil end
	local objPos
	if targetObject:IsA("Model") then
		objPos = targetObject.PrimaryPart and targetObject.PrimaryPart.Position or targetObject:GetPivot().Position
	else
		objPos = targetObject.Position
	end
	return (humanoidRootPart.Position - objPos).Magnitude
end

local function updateDistanceDisplay()
	if targetObject and targetObject.Parent then
		local dist = getDistanceToTarget()
		if dist then
			distanceLabel.Text = string.format("Distancia: %.1f", dist)
		else
			distanceLabel.Text = "Distancia: --"
		end
	else
		distanceLabel.Text = "Objeto no encontrado"
	end
end

-- ------------------------------------------------------------
-- RECOLECTAR
-- ------------------------------------------------------------
local function collect()
	if not targetObject or not targetObject.Parent then
		warn("No hay objeto válido")
		return
	end
	local dist = getDistanceToTarget()
	if dist and dist <= 15 then
		farmEvent:FireServer(targetObject)
		print("Recolectado: " .. targetObject.Name)
	else
		print("Demasiado lejos para recolectar")
	end
end

-- ------------------------------------------------------------
-- AUTO-FARM LOOP
-- ------------------------------------------------------------
RunService.Heartbeat:Connect(function(dt)
	if not autoFarmEnabled then return end
	if not targetObject or not targetObject.Parent then
		updateDistanceDisplay()
		return
	end

	local dist = getDistanceToTarget()
	if dist and dist <= 10 then
		local now = tick()
		if now - lastCollectionTime >= COLLECTION_COOLDOWN then
			lastCollectionTime = now
			collect()
		end
	end
	updateDistanceDisplay()
end)

-- ------------------------------------------------------------
-- EVENTOS DE BOTONES
-- ------------------------------------------------------------
setTargetBtn.MouseButton1Click:Connect(function()
	local objName = objectNameInput.Text
	if objName == "" then return end
	local found = findObjectByName(objName)
	if found then
		targetObject = found
		distanceLabel.Text = "Objeto seleccionado: " .. targetObject.Name
		print("Objeto seleccionado:", targetObject.Name)
	else
		targetObject = nil
		distanceLabel.Text = "Objeto no encontrado"
		warn("No se encontró: " .. objName)
	end
end)

autoFarmBtn.MouseButton1Click:Connect(function()
	autoFarmEnabled = not autoFarmEnabled
	autoFarmBtn.Text = autoFarmEnabled and "Auto Farm: ON" or "Auto Farm: OFF"
end)

collectBtn.MouseButton1Click:Connect(function()
	collect()
end)

-- Actualizar distancia constantemente
RunService.RenderStepped:Connect(function()
	updateDistanceDisplay()
end)

-- Reasignar personaje al reaparecer
player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)

-- Mensaje de inicio
print("Auto Farm GUI cargada. Selecciona un objeto con atributo Farmable=true")
