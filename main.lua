print("ULTRA PIZZERO cargado")

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- CONFIG
local activo = false
local lastMove = tick()

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,270,0,230)
frame.Position = UDim2.new(0.5,-135,0.5,-115)
frame.BackgroundColor3 = Color3.fromRGB(10,10,20)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "🍕 ULTRA PIZZERO"
title.TextColor3 = Color3.fromRGB(120,120,255)
title.BackgroundTransparency = 1

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,25)
status.Position = UDim2.new(0,0,0,35)
status.Text = "OFF"
status.TextColor3 = Color3.new(1,1,1)
status.BackgroundTransparency = 1

-- FUNCIONES CORE

local function buscarLista(lista)
    local mejor = nil
    local dist = 999

    for _,v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local name = v.Name:lower()
            for _,n in pairs(lista) do
                if string.find(name,n) then
                    local d = (root.Position - v.Position).Magnitude
                    if d < dist then
                        dist = d
                        mejor = v
                    end
                end
            end
        end
    end

    return mejor
end

local function tp(obj)
    if obj then
        root.CFrame = obj.CFrame + Vector3.new(0,2,0)
        lastMove = tick()
    end
end

local function interact(obj)
    if not obj then return end
    for _,v in pairs(obj:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            fireproximityprompt(v)
        end
    end
end

-- SISTEMA INTELIGENTE DE RUTA

local estaciones = {
    masa = {"dough","pizza"},
    horno = {"oven"},
    caja = {"box"}
}

local orden = {"masa","horno","caja"}
local step = 1

task.spawn(function()
    while true do
        task.wait(0.3)

        if activo then
            local tipo = orden[step]
            local obj = buscarLista(estaciones[tipo])

            if obj then
                tp(obj)
                task.wait(0.2)
                interact(obj)

                step = step + 1
                if step > #orden then
                    step = 1
                end
            else
                -- fallback inteligente
                local any = buscarLista({"pizza","oven","box"})
                if any then
                    tp(any)
                    interact(any)
                end
            end
        end
    end
end)

-- AUTO RESET SI SE TRABA

task.spawn(function()
    while true do
        task.wait(3)
        if activo then
            if tick() - lastMove > 6 then
                status.Text = "Reiniciando ruta..."
                step = 1
            end
        end
    end
end)

-- TOGGLE
title.InputBegan:Connect(function()
    activo = not activo
    status.Text = activo and "ON 🔥" or "OFF"
end)

print("ULTRA listo")
