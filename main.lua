local player = game.Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    hum:MoveTo(char.HumanoidRootPart.Position + Vector3.new(5,0,0))
                end
            end
        end)
    end
end)

print("AUTO MOVE OK")
