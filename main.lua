require "class"
require "colliders"

require "variables"

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setLineStyle("rough")

    love.window.setMode(SCREEN_WIDTH*DEFAULT_SCALE, SCREEN_HEIGHT*DEFAULT_SCALE, { vsync = true, msaa = 0, highdpi = true, resizable=true})
    love.window.setTitle("Slime to the Top")
    
    gameCanvas = love.graphics.newCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)

    a = polycollider:new({10, 0, 40, 0, 50, 10, 50, 40, 40, 50, 10, 50, 0, 40, 0, 10})
    b = linecollider:new(30, 10, 40, 50)
    c = pointcollider:new(100, 100)
    d = rectcollider:new(10, 60, 30, 30)
    love.graphics.setBackgroundColor(0, 0, 0)
end

function love.update()
    local w, h = love.graphics.getDimensions()
    local scl = math.min(w/SCREEN_WIDTH, h/SCREEN_HEIGHT)
    local Xoff = 0
    local Yoff = 0
    if w > h then Xoff = (w - h) / 2 end
    if h > w then Yoff = (h - w) / 2 end

    a:move((love.mouse.getX() - Xoff) / scl, (love.mouse.getY() - Yoff) / scl)
end

function love.draw()
    love.graphics.setCanvas(gameCanvas)

    love.graphics.clear()

    if intersect(a, b) or intersect(a, c) or intersect(a, d) then
        love.graphics.setColor(1, 1/2, 1/2, 1)
    else
        love.graphics.setColor(1, 1, 1, 1)
    end
    a:draw()
    b:draw()
    c:draw()
    d:draw()
    love.graphics.print(b.type, 0, 0)

    love.graphics.setCanvas()
    local w, h = love.graphics.getDimensions()
    local scl = math.min(w/SCREEN_WIDTH, h/SCREEN_HEIGHT)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gameCanvas, w/2, h/2, 0, scl, scl, SCREEN_WIDTH/2, SCREEN_HEIGHT/2)
end