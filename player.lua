player = class:new()

function player:init()
    self.pos = {x = 3 * TILE_SIZE, y = 5 * TILE_SIZE}
    self.vel = {x = 0, y = 0.01}

    self.onground = false
    self.onwall = false

    self.prevonwall = false

    self.coyoteGround = 0
    self.coyoteWall = 0

    self.dir = 1
    self.lastWallDir = 1

    self.collider = rectcollider:new(self.pos.x, self.pos.y, PLAYER_WIDTH, PLAYER_HEIGHT)
    self.wallTester = pointcollider:new(self.pos.x - 1, self.pos.y + PLAYER_HEIGHT/2)
    self.groundTester = linecollider:new(self.pos.x + 1, self.pos.y + PLAYER_HEIGHT + 1, self.pos.x + PLAYER_WIDTH - 2, self.pos.y + PLAYER_HEIGHT + 1)
end

function player:update()
    --collision state tests and coyote time
    self.onground = gameMap:wallCollide(self.groundTester)
    self.prevonwall = self.onwall
    self.onwall = gameMap:wallCollide(self.wallTester) and (self.prevonwall or self.vel.y >= 0)

    self.coyoteGround = self.coyoteGround + 1
    self.coyoteWall = self.coyoteWall + 1
    if self.onground then self.coyoteGround = 0 end
    if self.onwall then
        self.coyoteWall = 0
        self.lastWallDir = self.dir
    end

    --controls
    local leftRightMove = 0
    if controls.right > 0 then leftRightMove = leftRightMove + 1 end
    if controls.left > 0 then leftRightMove = leftRightMove - 1 end

    local upDownMove = 0
    if controls.down > 0 then upDownMove = upDownMove + 1 end
    if controls.up > 0 then upDownMove = upDownMove - 1 end

    --left and right movement/deceleration
    if self.onground then
        if leftRightMove > 0 and self.vel.x < PLAYER_MAX_RUN_VEL then
            self.vel.x = approach(self.vel.x, PLAYER_MAX_RUN_VEL, PLAYER_RUN_ACCEL)
        elseif leftRightMove < 0 and self.vel.x > -PLAYER_MAX_RUN_VEL then
            self.vel.x = approach(self.vel.x, -PLAYER_MAX_RUN_VEL, PLAYER_RUN_ACCEL)
        else
            self.vel.x = approach(self.vel.x, 0, PLAYER_RUN_DECEL)
        end
    else
        if leftRightMove > 0 and self.vel.x < PLAYER_MAX_AIR_VEL then
            self.vel.x = approach(self.vel.x, PLAYER_MAX_AIR_VEL, PLAYER_AIR_ACCEL)
        elseif leftRightMove < 0 and self.vel.x > -PLAYER_MAX_AIR_VEL then
            self.vel.x = approach(self.vel.x, -PLAYER_MAX_AIR_VEL, PLAYER_AIR_ACCEL)
        else
            self.vel.x = approach(self.vel.x, 0, PLAYER_AIR_DECEL)
        end
    end

    --direction control
    if self.onground and leftRightMove ~= 0 then
        self.dir = leftRightMove
    elseif self.vel.x ~= 0 then
        self.dir = sign(self.vel.x)
    end

    --gravity and climbing
    if not self.onwall then
        self.vel.y = self.vel.y + PLAYER_GRAVITY_ACCEL
    else
        if upDownMove > 0 then
            self.vel.y = approach(self.vel.y, PLAYER_MAX_CLIMB_SPEED, PLAYER_CLIMB_ACCEL)
        elseif upDownMove < 0 then
            self.vel.y = approach(self.vel.y, -PLAYER_MAX_CLIMB_SPEED, PLAYER_CLIMB_ACCEL)
        else
            self.vel.y = approach(self.vel.y, 0, PLAYER_CLIMB_DECEL)
        end
    end

    if self.prevonwall and not self.onwall and controls.up > 0 and self.lastWallDir == self.dir then
        self.vel.y = -PLAYER_CLIMBUP_VEL
    end

    --jumping
    if controls.z == 1 then
        if self.coyoteGround <= COYOTE_TIME_GROUND then
            self.vel.y = -PLAYER_JUMP_VEL
            self.onwall = false
        elseif self.coyoteWall <= COYOTE_TIME_WALL then
            self.vel.x = PLAYER_CLIMB_JUMP_VEL_X * -self.lastWallDir
            self.vel.y = -PLAYER_CLIMB_JUMP_VEL_Y
        end
    end

    --movement calculations
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
    self.wallTester:move(self.pos.x + PLAYER_WIDTH/2 + PLAYER_WIDTH/2*self.dir + self.dir, self.pos.y + PLAYER_HEIGHT/2 + 0.5)
    self.groundTester:move(self.pos.x + 1, self.pos.y + PLAYER_HEIGHT + 1)
end

function player:draw()
    self.collider:draw()
    if self.onwall then love.graphics.setColor(1, 0, 0, 1) else love.graphics.setColor(1, 1, 1, 1) end
    self.wallTester:draw()
    if self.onground then love.graphics.setColor(1, 0, 0, 1) else love.graphics.setColor(1, 1, 1, 1) end
    self.groundTester:draw()
end