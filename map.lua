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
    self.currentScreen = 1 --current screen is the screen the player is on, we still have to load adjacent screens

    self.screens[1] = loadScreen(1, 0)
    self.screens[2] = loadScreen(2, 1)
end

function map:wallCollide(other)
    local screen
    
    for i = self.currentScreen - 1, self.currentScreen + 1 do
        screen = self.screens[i]
        if screen then
            for j = 1, #screen.walls do
                if intersect(screen.walls[j].collider, other) then
                    return true
                end
            end
        end
    end

    return false
end

function map:draw()
    local screen
    
    for i = self.currentScreen - 1, self.currentScreen + 1 do
        screen = self.screens[i]
        if screen then
            for j = 1, #screen.walls do
                screen.walls[j]:draw()
            end
        end
    end
end