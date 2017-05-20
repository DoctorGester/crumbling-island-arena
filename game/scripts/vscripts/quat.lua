Quat = {}

function Quat.new(x, y, z, w)
    return { x = x, y = y, z = z, w = w }
end

function Quat.normalize(q)
    local len = math.sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w)

    if len > 0 and len ~= 1 then
        return Quat.new(q.x / len, q.y / len, q.z / len, q.w / len)
    end

    return q
end

function Quat.fromAxisAngle(x, y, z, a)
    local factor = math.sin( a / 2.0 )

    local nx = x * factor
    local ny = y * factor
    local nz = z * factor
    local w = math.cos( a / 2.0 )

    return Quat.normalize(Quat.new(nx, ny, nz, w))
end

function Quat.mul(this, other)
    local newX = this.w * other.x + this.x * other.w + this.y * other.z - this.z * other.y
    local newY = this.w * other.y + this.y * other.w + this.z * other.x - this.x * other.z
    local newZ = this.w * other.z + this.z * other.w + this.x * other.y - this.y * other.x
    local newW = this.w * other.w - this.x * other.x - this.y * other.y - this.z * other.z

    return Quat.new(newX, newY, newZ, newW)
end

function Quat.toEuler(q1)
    local sqw = q1.w*q1.w
    local sqx = q1.x*q1.x
    local sqy = q1.y*q1.y
    local sqz = q1.z*q1.z
    local unit = sqx + sqy + sqz + sqw
    local test = q1.x*q1.y + q1.z*q1.w

    if (test > 0.499*unit) then
        local yaw = 2 * math.atan2(q1.x,q1.w);
        local pitch = math.pi/2;
        local roll = 0;
        return yaw, pitch, roll
    end

    if (test < -0.499*unit) then
        local yaw = -2 * math.atan2(q1.x,q1.w);
        local pitch = -math.pi/2;
        local roll = 0;
        return yaw, pitch, roll
    end

    local yaw = math.atan2(2*q1.y*q1.w-2*q1.x*q1.z , sqx - sqy - sqz + sqw);
    local pitch = math.asin(2*test/unit);
    local roll = math.atan2(2*q1.x*q1.w-2*q1.y*q1.z , -sqx + sqy - sqz + sqw)

    return yaw, pitch, roll
end