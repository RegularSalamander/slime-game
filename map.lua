mapObject = class:new()

function mapObject:init(x, y, spritepos, collideType)
    self.pos = {x=x, y=y}
    if collideType == "square" then
        self.collider = rectcollider:new(x, y, TILE_SIZE, TILE_SIZE)
    elseif collideType == "positive" then
        self.collider = linecollider:new(x+TILE_SIZE, y+1, x+1, y+TILE_SIZE)
    elseif collideType == "negative" then
        self.collider = linecollider:new(x, y+1, x+TILE_SIZE-1, y+TILE_SIZE)
    elseif collideType == "left" then
        self.collider = polycollider:new({x, y+2, x+TILE_SIZE-2, y+TILE_SIZE, x, y+TILE_SIZE})
    elseif collideType == "right" then
        self.collider = polycollider:new({x+TILE_SIZE, y+2, x+TILE_SIZE, y+TILE_SIZE, x+2, y+TILE_SIZE})
    else
        self.collider = collider:new()
    end
    self.spritepos = spritepos
end

function mapObject:draw(drawTile)
    if drawTile then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(
            sprites.mapObject,
            love.graphics.newQuad(
                self.spritepos.x * TILE_SIZE, self.spritepos.y * TILE_SIZE,
                TILE_SIZE, TILE_SIZE,
                WALL_SPRITE_COLS * TILE_SIZE, WALL_SPRITE_ROWS * TILE_SIZE
            ),
            self.pos.x, self.pos.y - 1
        )
    end

    if DEBUG_MODE then
        self.collider:draw()
    end
end


map = class:new()

function map:init()
    self.screens = {}
    self.currentScreen = 1 --current screen is the screen the player is on, we still have to load adjacent screens

    self.screens[1] = loadScreen(1, 0, 3, 1)
    self.screens[2] = loadScreen(2, 1, 1)
    self.screens[3] = loadScreen(3, 2, 1)
    self.screens[4] = loadScreen(4, 3, 1)
    self.screens[5] = loadScreen(5, 4, 1)
    -- self.screens[1] = loadScreen(4, 0)
end

function map:collide(other)
    local collision = {
        wall = false,
        positive = false,
        negative = false
    }

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