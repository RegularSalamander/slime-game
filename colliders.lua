collider = class:new()

function collider:init()
    self.type = "none"
    self.points = {}
end

-- move collider such that the first point lies at (x, y)
function collider:move(x, y)
    if self.type == "none" then return end

    local dx = x - self.points[1]
    local dy = y - self.points[2]
    for i = 1, #self.points, 2 do
        self.points[i] = self.points[i] + dx
        self.points[i+1] = self.points[i+1] + dy
    end
end

function collider:draw()
    for i = 1, #self.points - 2, 2 do
        love.graphics.line(
            math.floor(self.points[i]), math.floor(self.points[i+1]),
            math.floor(self.points[i+2]), math.floor(self.points[i+3])
        )
    end
    love.graphics.line(
        math.floor(self.points[#self.points-1]), math.floor(self.points[#self.points]),
        math.floor(self.points[1]), math.floor(self.points[2])
    )
end

pointcollider = collider:new()
function pointcollider:init(x, y)
    self.type = "point"
    self.points = {x, y}
end
function pointcollider:draw()
    love.graphics.circle("fill", math.floor(self.points[1]), math.floor(self.points[2]), 3)
end

linecollider = collider:new()
function linecollider:init(x1, y1, x2, y2)
    self.type = "line"
    self.points = {x1, y1, x2, y2}
end

rectcollider = collider:new()
function rectcollider:init(x, y, w, h)
    self.type = "rect"
    self.points = {x, y, x+w, y, x+w, y+h, x, y+h}
    self.quad = {x, y, w, h}
end
function rectcollider:move(x, y)
    self.quad[1] = x
    self.quad[2] = y

    local dx = x - self.points[1]
    local dy = y - self.points[2]
    for i = 1, #self.points, 2 do
        self.points[i] = self.points[i] + dx
        self.points[i+1] = self.points[i+1] + dy
    end
end

polycollider = collider:new()
function polycollider:init(points)
    self.type = "poly"
    self.points = points
end

function intersect(a, b)
    if a.type == "none" then
        return false
    elseif a.type == "point" then
        if b.type == "point" then
            return false
        elseif b.type == "line" then
            return false
        elseif b.type == "rect" then
            return pointInRect(a, b)
        elseif b.type == "poly" then
            return pointInPoly(a, b)
        end
    elseif a.type == "line" then
        if b.type == "line" then
            return lineIntersect(a, b)
        elseif b.type == "rect" then
            return linePolyIntersect(a, b)
        elseif b.type == "poly" then
            return linePolyIntersect(a, b)
        end
    elseif a.type == "rect" then
        if b.type == "rect" then
            return rectIntersect(a, b)
        elseif b.type == "poly" then
            return polyIntersect(a, b)
        end
    elseif a.type == "poly" then
        if b.type == "poly" then
            return polyIntersect(a, b)
        end
    else
        error("Intersection test with an invalid collider type")
    end

    return intersect(b, a)
end

--returns true if any point in a is inside the rect of b
function pointInRect(a, b)
    for i = 1, #a.points, 2 do
        if a.points[i] >= b.quad[1] and
           a.points[i+1] >= b.quad[2] and
           a.points[i] <= b.quad[1] + b.quad[3] and
           a.points[i+1] <= b.quad[2] + b.quad[4]
        then return true end
    end
    return false
end

--returns true if any point in a is inside the polygon of b
function pointInPoly(a, b)
    for i = 1, #a.points, 2 do
        local windingNumber = 0
        local x, y = a.points[i], a.points[i+1]
        
        for j = 1, #b.points, 2 do
            local xi = b.points[wrap(j, #b.points)]
            local yi = b.points[wrap(j+1, #b.points)]
            local xj = b.points[wrap(j+2, #b.points)]
            local yj = b.points[wrap(j+3, #b.points)]

            if yj <= y then
                if yi > y then
                    if isLeft(xj, yj, xi, yi, x, y) > 0 then
                        windingNumber = windingNumber + 1
                    end
                end
            else
                if yi <= y then
                    if isLeft(xj, yj, xi, yi, x, y) < 0 then
                        windingNumber = windingNumber - 1
                    end
                end
            end
        end

        if windingNumber ~= 0 then return true end
    end

    return false
end

--returns true if the line a intersects the line b
function lineIntersect(a, b)
    local x, y, int = lineTest(a.points, b.points)
    return int
end

--returns true if the line a intersects the polygon b
function linePolyIntersect(a, b)
    --line tests
    for i = 1, #b.points, 2 do
        local x, y, int = lineTest(a.points,
            {b.points[wrap(i, #b.points)], b.points[wrap(i+1, #b.points)], b.points[wrap(i+2, #b.points)], b.points[wrap(i+3, #b.points)]}
        )
        if int then return true end
    end

    --point in polygon tests
    return pointInPoly(a, b)
end

--returns true if the polygon a intersects the polygon b
function polyIntersect(a, b)
    --line tests
    for i = 1, #a.points, 2 do
        for j = 1, #b.points, 2 do
            local x, y, int = lineTest(
                {a.points[wrap(j, #a.points)], a.points[wrap(j+1, #a.points)], a.points[wrap(j+2, #a.points)], a.points[wrap(j+3, #a.points)]},
                {b.points[wrap(j, #b.points)], b.points[wrap(j+1, #b.points)], b.points[wrap(j+2, #b.points)], b.points[wrap(j+3, #b.points)]}
            )
            if int then return true end
        end
    end

    --point in polygon tests
    return pointInPoly(a, b)
end

--returns true if the rect a intersects the rect b
function rectIntersect(a, b)
    -- love.graphics.setBackgroundColor(1, 1, 1, 1)
    return a.quad[1] <= b.quad[1] + b.quad[3] and
           a.quad[2] <= b.quad[2] + b.quad[4] and
           a.quad[1] + a.quad[3] >= b.quad[1] and
           a.quad[2] + a.quad[4] >= b.quad[2]
end

--takes in two lines {x1, y1, x2, y2} and returns the (x, y) position of the intersection and a bool if they intersect within the segment
function lineTest(lineA, lineB)
    if math.abs(lineA[1] - lineA[3]) < 0.0001 then
        lineA[1] = lineA[1] + 0.0001
    end
    if math.abs(lineB[1] - lineB[3]) < 0.0001 then
        lineB[1] = lineB[1] + 0.0001
    end

    local m1 = (lineA[2] - lineA[4]) / (lineA[1] - lineA[3])
    local b1 = -m1*lineA[1] + lineA[2]

    local m2 = (lineB[2] - lineB[4]) / (lineB[1] - lineB[3])
    local b2 = -m2*lineB[1] + lineB[2]

    --parallel lines
    if math.abs(m1 - m2) < 0.0001 then
        return false
    end

    local x = (b2 - b1) / (m1 - m2)
    local y = m1*x + b1
    local int = x >= math.min(lineA[1], lineA[3]) and x <= math.max(lineA[1], lineA[3]) and
                x >= math.min(lineB[1], lineB[3]) and x <= math.max(lineB[1], lineB[3])

    return x, y, int
end

function wrap(x, a)
    return (x - 1) % a + 1
end

function isLeft(x1, y1, x2, y2, x3, y3)
    return (x2 - x1) * (y3 - y1) - (x3 -  x1) * (y2 - y1)
end