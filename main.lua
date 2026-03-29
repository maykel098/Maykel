print("RUNNING")
task.spawn(function()
    while true do
        print("LOOP OK")
        task.wait(2)
    end
end)
