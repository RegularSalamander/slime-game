map = class:new()

function map:init()
    self.screens = {}
    self.currentScreen = 1 --current screen is the screen the player is on, we still have to load adjacent screens

    self.screens[1] = loadScreen(1, 0, 3, 1)
    self.screens[2] = loadScreen(2, 1)
    self.screens[3] = loadScreen(3, 2)
    self.screens[4] = loadScreen(4, 3)
    self.screens[5] = loadScreen(5, 4)

    self.sideLeft = linecollider:new(0, 1000, 0, -100000)
    self.sideRight = linecollider:new(128, 1000, 128, -100000)
end

function map:collide(other)
    local collision = {
        wall = false,
        positive = false,
        negative = false,
        water = false,
        obstacle = false
    }

    if intersect(self.sideLeft, other) or intersect(self.sideRight, other) then
        collision.wall = true
    end

    local screen
    
    for i = self.currentScreen - 1, self.currentScreen + 1 do
        screen = self.screens[i]
        if screen then
            for j = 1, #screen.positive do
                if intersect(screen.positive[j].collider, other) then
                    collision.positive = true
                end
            end

            for j = 1, #screen.negative do
                if intersect(screen.negative[j].collider, other) then
                    collision.negative = true
                end
            end

            for j = 1, #screen.walls do
                if intersect(screen.walls[j].collider, other) then
                    collision.wall = true
                end
            end

            for j = 1, #screen.water do
                if intersect(screen.water[j].collider, other) then
                    collision.water = true
                end
            end

            for j = 1, #screen.obstacles do
                if intersect(screen.obstacles[j].collider, other) then
                    collision.obstacle = true
                    collision.sendDir = screen.obstacles[j].sendDir(other.points[1], other.points[2])
                end
            end
        end
    end

    return collision
end

function map:draw(debug)
    local screen
    
    for i = self.currentScreen - 1, self.currentScreen + 1 do
        screen = self.screens[i]
        if screen then
            love.graphics.setColor(1, 1, 1, 1)
            if screen.img then
                love.graphics.draw(screen.img, 0, -screen.offset * SCREEN_HEIGHT)
            else
                for j = 1, #screen.walls do
                    screen.walls[j]:draw(true)
                end
                for j = 1, #screen.water do
                    screen.water[j]:draw(true)
                end
                for j = 1, #screen.obstacles do
                    screen.obstacles[j]:draw(true)
                end
            end

            if DEBUG_MODE then
                for j = 1, #screen.walls do
                    screen.walls[j]:draw(false)
                end
                for j = 1, #screen.positive do
                    screen.positive[j]:draw()
                end
                for j = 1, #screen.negative do
                    screen.negative[j]:draw()
                end
                for j = 1, #screen.water do
                    screen.water[j]:draw()
                end
                for j = 1, #screen.obstacles do
                    screen.obstacles[j]:draw()
                end
            end
        end
    end
end

function map:drawBack(debug)
    local screen
    
    for i = self.currentScreen - 1, self.currentScreen + 1 do
        screen = self.screens[i]
        if screen then
            love.graphics.setColor(1, 1, 1, 1)
            if screen.bg[math.floor(screen.bgFrame)] then
                love.graphics.draw(screen.bg[math.floor(screen.bgFrame)], 0, -screen.offset * SCREEN_HEIGHT)
                screen.bgFrame = screen.bgFrame + 1/MAP_FRAMES
                if screen.bgFrame >= #screen.bg + 1 then
                    screen.bgFrame = screen.bgFrame - #screen.bg
                end
            end
        end
    end
end

function map:drawFore(debug)
    local screen
    
    for i = self.currentScreen - 1, self.currentScreen + 1 do
        screen = self.screens[i]
        if screen then
            love.graphics.setColor(1, 1, 1, 1)
            if screen.fg[math.floor(screen.fgFrame)] then
                love.graphics.draw(screen.fg[math.floor(screen.fgFrame)], 0, -screen.offset * SCREEN_HEIGHT)
                screen.fgFrame = screen.fgFrame + 1/MAP_FRAMES
                if screen.fgFrame >= #screen.fg + 1 then
                    screen.fgFrame = screen.fgFrame - #screen.fg
                end
            end
        end
    end
end