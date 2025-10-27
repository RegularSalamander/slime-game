wall = class:new()

function wall:init(x, y, sprite)
    self.pos = {x=x, y=y}
    self.sprite = sprite
    self.collider = rectcollider:new(x, y, TILE_SIZE, TILE_SIZE)
end

function wall:draw()
    love.graphics.draw(sprites.wall, self.pos.x, self.pos.y - 1)

    if DEBUG_MODE then
        self.collider:draw()
    end
end


map = class:new()

function map:init()
    self.screens = {}
    self.currentScreen = 1

    self.screens[1] = loadScreen(1, 0)
end

function map:wallCollide(other)
    local screen = self.screens[self.currentScreen]
    
    for i = 1, #screen.walls do
        if intersect(screen.walls[i].collider, other) then
            return true
        end
    end

    return false
end

function map:draw()
    local screen = self.screens[self.currentScreen]
    
    for i = 1, #screen.walls do
        screen.walls[i]:draw()
    end
end