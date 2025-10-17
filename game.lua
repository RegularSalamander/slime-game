function game_load()
    controls = {
        left = 0,
        right = 0,
        up = 0,
        down = 0,
        z = 0
    }

    gameMap = map:new()
end

function game_update()
    --update controls
    for k, v in pairs(controls) do
        if v > 0 then controls[k] = v + 1
        else controls[k] = v - 1
        end
    end
end

function game_draw()
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear()

    love.graphics.print(controls.z, 10, 10)

    gameMap:draw()
end

function game_keypressed(key, scancode, isrepeat)
    if isrepeat then return end

    --remap keys
    if scancode == "w" then scancode = "up" end
    if scancode == "a" then scancode = "left" end
    if scancode == "s" then scancode = "down" end
    if scancode == "d" then scancode = "right" end
    if scancode == "space" then scancode = "z" end
    if scancode == "g" then scancode = "z" end

    if controls[scancode] then controls[scancode] = 1 end
end

function game_keyreleased(key, scancode, isrepeat)
    if isrepeat then return end
    
    --remap keys
    if scancode == "w" then scancode = "up" end
    if scancode == "a" then scancode = "left" end
    if scancode == "s" then scancode = "down" end
    if scancode == "d" then scancode = "right" end
    if scancode == "space" then scancode = "z" end
    if scancode == "g" then scancode = "z" end

    if controls[scancode] then controls[scancode] = 0 end
end