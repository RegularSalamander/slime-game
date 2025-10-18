player = class:new()

function player:init()
    self.pos = {x = 3 * TILE_SIZE, y = 5 * TILE_SIZE}
    self.vel = {x = 0, y = 0.01}

    self.onground = false
    self.onwall = false

    self.dir = 1

    self.collider = rectcollider:new(self.pos.x, self.pos.y, PLAYER_WIDTH, PLAYER_HEIGHT)
    self.wallTester = pointcollider:new(self.pos.x - 1, self.pos.y + PLAYER_HEIGHT/2)
    self.groundTester = linecollider:new(self.pos.x + 1, self.pos.y + PLAYER_HEIGHT + 1, self.pos.x + PLAYER_WIDTH - 2, self.pos.y + PLAYER_HEIGHT + 1)
end

function player:update()
    self.onground = gameMap:wallCollide(self.groundTester)
    self.onwall = gameMap:wallCollide(self.wallTester)

    if controls.z == 1 and self.onground then
        self.vel.y = PLAYER_JUMP_VEL
    end

    local move = 0
    if controls.right > 0 then move = move + 1 end
    if controls.left > 0 then move = move - 1 end

    if move > 0 then
        self.vel.x = approach(self.vel.x, PLAYER_MAX_RUN_VEL, PLAYER_RUN_ACCEL)
    elseif move < 0 then
        self.vel.x = approach(self.vel.x, -PLAYER_MAX_RUN_VEL, PLAYER_RUN_ACCEL)
    else
        self.vel.x = approach(self.vel.x, 0, PLAYER_RUN_DECEL)
    end

    if move ~= 0 then
        self.dir = move
    end

    self.vel.y = self.vel.y + PLAYER_GRAVITY_ACCEL

    local target

    target = self.pos.x + self.vel.x
    while self.pos.x ~= target do
        self.pos.x = approach(self.pos.x, target, 1)
        self:move()
        if gameMap:wallCollide(self.collider) then
            self.pos.x = self.pos.x - sign(self.vel.x)
            self.vel.x = 0
            break
        end
    end
    
    target = self.pos.y + self.vel.y
    while self.pos.y ~= target do
        self.pos.y = approach(self.pos.y, target, 1)
        self:move()
        if gameMap:wallCollide(self.collider) then
            self.pos.y = self.pos.y - sign(self.vel.y)
            self.vel.y = 0
            break
        end
    end

    self:move()
end

function player:move()
    self.collider:move(self.pos.x, self.pos.y)
    self.wallTester:move(self.pos.x + PLAYER_WIDTH/2 + PLAYER_WIDTH/2*self.dir + self.dir, self.pos.y + PLAYER_HEIGHT/2)
    self.groundTester:move(self.pos.x + 1, self.pos.y + PLAYER_HEIGHT + 1)
end

function player:draw()
    self.collider:draw()
    if self.onwall then love.graphics.setColor(1, 0, 0, 1) else love.graphics.setColor(1, 1, 1, 1) end
    self.wallTester:draw()
    if self.onground then love.graphics.setColor(1, 0, 0, 1) else love.graphics.setColor(1, 1, 1, 1) end
    self.groundTester:draw()
end