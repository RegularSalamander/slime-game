function loadScreen(num, offset, bgFrames, fgFrames)
    local scr = {
        walls = {},
        positive = {},
        negative = {},
        water = {},
        rope = {},
        obstacles = {}
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
            elseif r == 0 and g == 0 and b == 255 then
                table.insert(scr.water, mapObject:new(xpos, ypos, {x=4, y=0}, "square"))
            elseif r == 255 and g == 255 and b < 4 then
                if b == 0 then table.insert(scr.obstacles, mapObject:new(xpos, ypos, {x=5, y=0}, "spikeTop")) end
                if b == 1 then table.insert(scr.obstacles, mapObject:new(xpos, ypos, {x=6, y=0}, "spikeRight")) end
                if b == 2 then table.insert(scr.obstacles, mapObject:new(xpos, ypos, {x=7, y=0}, "spikeBottom")) end
                if b == 3 then table.insert(scr.obstacles, mapObject:new(xpos, ypos, {x=8, y=0}, "spikeLeft")) end
            elseif r == 255 and g == 128 and b == 0 then
                table.insert(scr.rope, mapObject:new(xpos, ypos, {x=9, y=0}, "rope"))
            end
        end
    end

    return scr
end