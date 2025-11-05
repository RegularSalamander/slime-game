function loadScreen(num, offset, bgFrames, fgFrames)
    local scr = {
        walls = {},
        positive = {},
        negative = {}
    }

    if not bgFrames then bgFrames = 0 end
    if not fgFrames then fgFrames = 0 end
    scr.img = nil
    if love.filesystem.getInfo("assets/map/" .. num .. ".png") then
        scr.img = love.graphics.newImage("assets/map/" .. num .. ".png")
    end
    scr.bg = {}
    for i = 1, bgFrames do
        if love.filesystem.getInfo("assets/map/" .. num .. "_bg" .. i ..".png") then
            scr.bg[i] = love.graphics.newImage("assets/map/" .. num .. "_bg" .. i ..".png")
        end
    end
    scr.fg = {}
    for i = 1, fgFrames do
        if love.filesystem.getInfo("assets/map/" .. num .. "_fg" .. i ..".png") then
            scr.fg[i] = love.graphics.newImage("assets/map/" .. num .. "_fg" .. i ..".png")
        end
    end

    scr.bgFrame = 1
    scr.fgFrame = 1
    
    scr.offset = offset

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
                table.insert(scr.walls, mapObject:new(xpos, ypos, {x=1, y=0}, "square"))
            elseif r == 128 and g == 0 and b == 0 then
                table.insert(scr.positive, mapObject:new(xpos, ypos, {x=0, y=0}, "positive"))
                table.insert(scr.walls, mapObject:new(xpos, ypos, {x=2, y=0}, "right"))
            elseif r == 0 and g == 128 and b == 0 then
                table.insert(scr.negative, mapObject:new(xpos, ypos, {x=0, y=0}, "negative"))
                table.insert(scr.walls, mapObject:new(xpos, ypos, {x=3, y=0}, "left"))
            end
        end
    end

    return scr
end