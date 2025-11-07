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
    elseif collideType == "spikeTop" then
        self.collider = linecollider:new(x+1, y+1, x+TILE_SIZE-1, y+1)
        self.sendDir = function(x, y) return {x=0, y=1} end
    elseif collideType == "spikeRight" then
        self.collider = linecollider:new(x+TILE_SIZE-1, y+1, x+TILE_SIZE-1, y+TILE_SIZE-1)
        self.sendDir = function(x, y) return {x=-1, y=0} end
    elseif collideType == "spikeBottom" then
        self.collider = linecollider:new(x+1, y+TILE_SIZE-1, x+TILE_SIZE-1, y+TILE_SIZE-1)
        self.sendDir = function(x, y) return {x=0, y=-1} end
    elseif collideType == "spikeLeft" then
        self.collider = linecollider:new(x+1, y+1, x+1, y+TILE_SIZE-1)
        self.sendDir = function(x, y) return {x=1, y=0} end
    elseif collideType == "rope" then
        self.collider = linecollider:new(x+TILE_SIZE/2, y, x+TILE_SIZE/2, y+TILE_SIZE)
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