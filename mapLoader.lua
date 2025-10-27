function loadScreen(num, offset)
    local scr = {
        walls = {}
    }

    local img = love.image.newImageData("map/" .. num .. ".png")

    for y = 0, img:getHeight() - 1 do
        for x = 0, img:getWidth() - 1 do
            local r, g, b, a = img:getPixel(x, y)
            r = r * 255
            g = g * 255
            b = b * 255
            a = a * 255

            local xpos = x * TILE_SIZE
            local ypos = y * TILE_SIZE - offset * TILE_SIZE * SCREEN_TILES_HEIGHT + 1

            if r == 0 and g == 0 and b == 0 then
                table.insert(scr.walls, wall:new(xpos, ypos))
            end
        end
    end

    return scr
end