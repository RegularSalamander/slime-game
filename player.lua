player = class:new()

function player:init()
    self.pos = {x = 3 * TILE_SIZE, y = 4 * TILE_SIZE}
    self.vel = {x = 0.5, y = 0}

    self.onground = false
    self.onwall = false
    
    self.prevonwall = false
    self.prevonground = false

    self.dir = 1
    self.lastWallDir = 1
    self.disconnectTimer = 0
    self.bufferedJump = false
    
    self.coyoteGround = 0
    self.coyoteWall = 0

    self.climbTime = 0
    self.climbFrame = 0

    self.bouncing = false
    self.bounceFrame = 0

    self.mantling = false
    self.mantleStart = {x=0, y=0}
    self.mantleEnd = {x=0, y=0}
    self.mantleProg = 0

    self.collider = rectcollider:new(self.pos.x, self.pos.y, PLAYER_WIDTH, PLAYER_HEIGHT)
    self.wallTester = pointcollider:new(self.pos.x - 1, self.pos.y + PLAYER_HEIGHT/2)
    self.groundTester = linecollider:new(self.pos.x + 1, self.pos.y + PLAYER_HEIGHT + 1, self.pos.x + PLAYER_WIDTH - 1, self.pos.y + PLAYER_HEIGHT + 1)
end

function player:update()
    --player not in neutral state
    if self.bouncing then
        self:bounceUpdate()
        return
    end
    if self.mantling then
        self:mantleUpdate()
        return
    end

    --collision state tests and coyote time
    self.prevonground = self.onground
    self.onground = gameMap:collide(self.groundTester).wall
    self.prevonwall = self.onwall
    self.onwall = gameMap:collide(self.wallTester).wall and (self.prevonwall or self.vel.y >= 0)

    self.coyoteGround = self.coyoteGround + 1
    self.coyoteWall = self.coyoteWall + 1
    if self.onground then
        self.coyoteGround = 0
        self.climbTime = 0
    end
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
    if self.onwall and not self.onground then
        if leftRightMove == -1 * self.dir then
            self.disconnectTimer = self.disconnectTimer + 1
            if self.disconnectTimer >= PLAYER_DISCONNECT_FRAMES then
                self.vel.x = -self.dir
            end
        else
            self.disconnectTimer = PLAYER_DISCONNECT_FRAMES
        end
    elseif self.onground then
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
    elseif self.climbTime > PLAYER_CLIMB_TIME then
        self.vel.y = self.vel.y + PLAYER_SLIDE_GRAV
    else
        if upDownMove > 0 then
            self.vel.y = approach(self.vel.y, PLAYER_MAX_CLIMB_VEL, PLAYER_CLIMB_ACCEL)
            self.climbTime = self.climbTime + PLAYER_GRAB_INCREASE
        elseif upDownMove < 0 then
            self.vel.y = approach(self.vel.y, -PLAYER_MAX_CLIMB_VEL, PLAYER_CLIMB_ACCEL)
            self.climbTime = self.climbTime + PLAYER_CLIMB_INCREASE
        else
            self.vel.y = approach(self.vel.y, 0, PLAYER_CLIMB_DECEL)
            self.climbTime = self.climbTime + PLAYER_GRAB_INCREASE
        end
    end

    --mantling
    if self.prevonwall and not self.onwall and controls.up > 0 and self.lastWallDir == self.dir and self.vel.y < 0 then
        self.mantling = true
        self.mantleProg = 0
        self.mantleStart = {x=self.pos.x, y=self.pos.y}
        if self.dir == 1 then
            self.mantleEnd = {x=self.wallTester.points[1], y=self.wallTester.points[2] - PLAYER_HEIGHT - 1}
        else
            self.mantleEnd = {x=self.wallTester.points[1] - PLAYER_WIDTH, y=self.wallTester.points[2] - PLAYER_HEIGHT - 1}
        end
        return
    end
    if self.prevonground and not self.onground and controls.down > 0 then
        self.mantling = true
        self.mantleProg = 0
        self.mantleStart = {x=self.pos.x, y=self.pos.y}
        self.mantleEnd = {x=self.pos.x - PLAYER_WIDTH/2, y=self.pos.y + PLAYER_HEIGHT}
        if self.dir == 1 then
            self.mantleEnd = {x=math.floor(self.pos.x + 2), y=self.pos.y+6}
            self.dir = -1
        else
            self.mantleEnd = {x=math.floor(self.pos.x - 1), y=self.pos.y+6}
            self.dir = 1
        end
        self.disconnectTimer = 0
        return
    end

    --jumping
    if controls.z == 1 or self.bufferedJump then
        self.bufferedJump = false
        if self.onwall and not self.onground then
            self.vel.x = PLAYER_CLIMB_JUMP_VEL_X * -self.lastWallDir
            self.vel.y = -PLAYER_CLIMB_JUMP_VEL_Y
        elseif self.coyoteGround <= COYOTE_TIME_GROUND then
            self.vel.y = -PLAYER_JUMP_VEL
            self.onwall = false
        elseif self.coyoteWall <= COYOTE_TIME_WALL then
            self.vel.x = PLAYER_CLIMB_JUMP_VEL_X * -self.lastWallDir
            self.vel.y = -PLAYER_CLIMB_JUMP_VEL_Y
        end
    end

    --neutral movement and collision
    local target

    target = self.pos.x + self.vel.x
    while self.pos.x ~= target do
        self.pos.x = approach(self.pos.x, target, 1)
        self:move()
        local col = gameMap:collide(self.collider)
        if col.positive and self.vel.x > 0 then
            self.pos.x = self.pos.x - 1
            local x = self.vel.x
            self.vel.x = -self.vel.y
            self.vel.y = -x
            self.bouncing = true
            break
        end
        if col.negative and self.vel.x < 0 then
            self.pos.x = self.pos.x + 1
            local x = self.vel.x
            self.vel.x = self.vel.y
            self.vel.y = x
            self.bouncing = true
            break
        end
        if col.wall then
            self.pos.x = self.pos.x - sign(self.vel.x)
            self.vel.x = 0
            break
        end
    end
    
    target = self.pos.y + self.vel.y
    while self.pos.y ~= target do
        self.pos.y = approach(self.pos.y, target, 1)
        self:move()
        local col = gameMap:collide(self.collider)
        if col.positive and self.vel.y > 0 then
            self.pos.y = self.pos.y - 1
            local x = self.vel.x
            self.vel.x = -self.vel.y
            self.vel.y = -x
            self.bouncing = true
            break
        end
        if col.negative and self.vel.y > 0 then
            self.pos.y = self.pos.y - 1
            local x = self.vel.x
            self.vel.x = self.vel.y
            self.vel.y = x
            self.bouncing = true
            break
        end
        if col.wall then
            self.pos.y = self.pos.y - sign(self.vel.y)
            self.vel.y = 0
            break
        end
    end

    self:move()
end

function player:bounceUpdate()
    self.vel.y = self.vel.y + PLAYER_GRAVITY_ACCEL

    local target

    target = self.pos.x + self.vel.x
    while self.pos.x ~= target do
        self.pos.x = approach(self.pos.x, target, 1)
        self:move()
        local col = gameMap:collide(self.collider)
        if col.positive and self.vel.x > 0 then
            self.pos.x = self.pos.x - 1
            local x = self.vel.x
            self.vel.x = -self.vel.y * PLAYER_BOUNCE_FALLOFF
            self.vel.y = -x * PLAYER_BOUNCE_FALLOFF
            break
        end
        if col.negative and self.vel.x < 0 then
            self.pos.x = self.pos.x + 1
            local x = self.vel.x
            self.vel.x = self.vel.y * PLAYER_BOUNCE_FALLOFF
            self.vel.y = x * PLAYER_BOUNCE_FALLOFF
            break
        end
        if col.wall then
            self.pos.x = self.pos.x - sign(self.vel.x)
            self.vel.x = self.vel.x * -PLAYER_BOUNCE_FALLOFF
            break
        end
    end
    
    target = self.pos.y + self.vel.y
    while self.pos.y ~= target do
        self.pos.y = approach(self.pos.y, target, 1)
        self:move()
        local col = gameMap:collide(self.collider)
        if col.positive and self.vel.y > 0 then
            self.pos.y = self.pos.y - 1
            local x = self.vel.x
            self.vel.x = -self.vel.y * PLAYER_BOUNCE_FALLOFF
            self.vel.y = -x * PLAYER_BOUNCE_FALLOFF
            break
        end
        if col.negative and self.vel.y > 0 then
            self.pos.y = self.pos.y - 1
            local x = self.vel.x
            self.vel.x = self.vel.y * PLAYER_BOUNCE_FALLOFF
            self.vel.y = x * PLAYER_BOUNCE_FALLOFF
            break
        end
        if col.wall then
            self.pos.y = self.pos.y - sign(self.vel.y)
            if self.vel.y > 0 and self.vel.y < PLAYER_BOUNCE_THRESHOLD and math.abs(self.vel.x) < PLAYER_BOUNCE_THRESHOLD then
                self.bouncing = false
            else
                self.vel.y = self.vel.y * -PLAYER_BOUNCE_FALLOFF
            end
            break
        end
    end

    self:move()
end

function player:mantleUpdate()
    if controls.z > 0 and self.mantleEnd.y > self.mantleStart.y then
        self.bufferedJump = true
    end
    
    self.pos.x = mapFunc(self.mantleProg, 0, PLAYER_MANTLE_FRAMES, self.mantleStart.x, self.mantleEnd.x)
    self.pos.y = mapFunc(self.mantleProg, 0, PLAYER_MANTLE_FRAMES, self.mantleStart.y, self.mantleEnd.y)

    self:move()
    local col = gameMap:collide(self.collider)
    if col.positive or col.negative then
        self.mantling = false
        self.bouncing = true
        return
    end

    self.mantleProg = self.mantleProg + 1

    if self.mantleProg >= PLAYER_MANTLE_FRAMES then
        self.mantling = false
        self.vel.x = 0
        self.vel.y = 0
    end
end

function player:move()
    self.collider:move(self.pos.x, self.pos.y)
    self.wallTester:move(self.pos.x + PLAYER_WIDTH/2 + PLAYER_WIDTH/2*self.dir + self.dir, self.pos.y + PLAYER_HEIGHT/2 + 0.5)
    self.groundTester:move(self.pos.x + 1, self.pos.y + PLAYER_HEIGHT + 1)
end

function player:draw()
    local quadx = 0
    local quady = 0

    if self.bouncing then
        --bounce
        if self.vel.x > 0 then
            self.bounceFrame = self.bounceFrame + 1/PLAYER_BOUNCE_FRAMES
        else
            self.bounceFrame = self.bounceFrame - 1/PLAYER_BOUNCE_FRAMES
        end
        if self.bounceFrame >= 8 then self.bounceFrame = self.bounceFrame - 8 end
        if self.bounceFrame < 0 then self.bounceFrame = self.bounceFrame + 8 end
        quadx = 4
        quady = math.floor(self.bounceFrame)
    elseif self.onground then
        --walk
        quady = 0
        if self.vel.x > PLAYER_MAX_RUN_VEL/2 then
            quadx = 1
        elseif self.vel.x < -PLAYER_MAX_RUN_VEL/2 then
            quadx = 2
        end
    elseif self.onwall then
        --climb
        if self.vel.y < -PLAYER_MAX_CLIMB_VEL/2 then
            quady = 5
        elseif self.vel.y > PLAYER_MAX_CLIMB_VEL/2 then
            quady = 6
        else
            quady = 4
        end
        if self.dir == 1 then
            quadx = 1
        end
        
        --blinking
        if self.climbTime >= PLAYER_CLIMB_WARNING then
            self.climbFrame = self.climbFrame + 1/PLAYER_CLIMB_BLINK
        else
            self.climbFrame = 0.99
        end
        if self.climbFrame >= 2 then self.climbFrame = self.climbFrame - 2 end
        quadx = quadx + 2 * math.floor(self.climbFrame)
    else
        --air
        quady = 1
        if self.vel.y > PLAYER_JUMP_VEL/4 or self.mantling and self.mantleEnd.y > self.mantleStart.y then
            quady = 3
        elseif self.vel.y < -PLAYER_JUMP_VEL/4 or self.mantling and self.mantleEnd.y < self.mantleStart.y then
            quady = 1
        else
            quady = 2
        end
        if self.vel.x > PLAYER_MAX_AIR_VEL/2 or self.mantling and self.mantleEnd.x > self.mantleStart.x  then
            quadx = 1
        elseif self.vel.x < -PLAYER_MAX_AIR_VEL/2 or self.mantling and self.mantleEnd.x < self.mantleStart.x then
            quadx = 2
        end
    end

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        sprites.slime,
        love.graphics.newQuad(
            quadx*PLAYER_DRAW_WIDTH, quady*PLAYER_DRAW_HEIGHT,
            PLAYER_DRAW_WIDTH, PLAYER_DRAW_HEIGHT,
            PLAYER_DRAW_WIDTH*PLAYER_SPRITE_COLS, PLAYER_DRAW_HEIGHT*PLAYER_SPRITE_ROWS
        ),
        math.floor(self.pos.x), math.floor(self.pos.y) - 1
    )

    if DEBUG_MODE then
        self.collider:draw()
        if self.onwall then love.graphics.setColor(1, 0, 0, 1) else love.graphics.setColor(1, 1, 1, 1) end
        self.wallTester:draw()
        if self.onground then love.graphics.setColor(1, 0, 0, 1) else love.graphics.setColor(1, 1, 1, 1) end
        self.groundTester:draw()
        return
    end
end