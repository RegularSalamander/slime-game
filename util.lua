function wrap(x, a)
    return (x - 1) % a + 1
end

function approach(value, target, step)
    if value < target then
        if value + step > target then
            return target
        else
            return value + step
        end
    else
        if value - step < target then
            return target
        else
            return value - step
        end
    end
end

function sign(x)
    if x < 0 then return -1 end
    if x > 0 then return 1 end
    return 0
end

function mapFunc(x, a, b, c, d)
    return (x-a) / (b-a) * (d-c) + c
end

function lerp(x, a, b)
    return mapFunc(x, 0, 1, a, b)
end