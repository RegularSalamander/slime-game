require "class"
require "colliders"

function love.load()
    a = polycollider:new({20, 0, 80, 0, 100, 20, 100, 80, 80, 100, 20, 100, 0, 80, 0, 20})
    b = linecollider:new(300, 100, 400, 500)
    c = pointcollider:new(100, 100)
    d = rectcollider:new(100, 300, 30, 30)
    love.graphics.setBackgroundColor(0, 0, 0)
end

function love.update()
    a:move(love.mouse.getPosition())
end

function love.draw()
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
end