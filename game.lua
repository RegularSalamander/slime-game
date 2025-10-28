function game_load()
    controls = {
        left = 0,
        right = 0,
        up = 0,
        down = 0,
        z = 0
    }

    gameMap = map:new()
    gamePlayer = player:new()

    camera = {x = 0, y = 0}
    love.graphics.setBackgroundColor(48/255, 15/255, 10/255)
end

function game_update()
    gamePlayer:update()

    if gamePlayer.pos.y < camera.y + CAMERA_HIGH_HEIGHT then
        camera.y = gamePlayer.pos.y - CAMERA_HIGH_HEIGHT
    end
    if gamePlayer.pos.y > camera.y + CAMERA_LOW_HEIGHT then
        camera.y = gamePlayer.pos.y - CAMERA_LOW_HEIGHT
    end
    camera.y = math.min(camera.y, 0)

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

    love.graphics.push()
    love.graphics.translate(math.floor(-camera.x), math.floor(-camera.y))

    gameMap:draw()

    gamePlayer:draw()

    love.graphics.pop()
end

function game_keypressed(key, scancode, isrepeat)
    if isrepeat then return end

    if (DEBUG_MODE or true) and scancode == "tab" then
        gamePlayer.bouncing = true
        gamePlayer.onground = false
        gamePlayer.onwall = false
    end

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