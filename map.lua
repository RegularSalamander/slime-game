wall = class:new()

function wall:init(x, y, sprite)
    self.pos = {x=x, y=y}
    self.sprite = sprite
    self.collider = rectcollider:new(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
end

function wall:draw()
    self.collider:draw()
end


map = class:new()

function map:init()
    self.screens = {
        {
            walls = {}
        }
    }

    -- testing wall tiles
    for i = 1, 10 do
        table.insert(self.screens[1].walls, wall:new(0, i))
        table.insert(self.screens[1].walls, wall:new(i, 10))
        table.insert(self.screens[1].walls, wall:new(i+5, 9))
    end
    
    self.currentScreen = 1
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