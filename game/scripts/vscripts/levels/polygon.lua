Polygon = Polygon or class({})

function Polygon:constructor()
    self.x = {}
    self.y = {}
    self.originX = 0
    self.originY = 0
    self.ox = 0
    self.oy = 0
    self.transformer = MAPS[GetMapName()].transformer
end

function Polygon:setOrigin(x, y)
    x, y = self.transformer(x, y)

    self.originX = x
    self.originY = y
end

function Polygon:addPoint(x, y)
    x, y = self.transformer(x, y)

    table.insert(self.x, x)
    table.insert(self.y, y)
end

function Polygon:setOffset(x, y)
    self.ox = x
    self.oy = y

    self:calculateBounds()
end

function Polygon:calculateBounds()
    local minX = math.huge
    local minY = math.huge
    local maxX = -math.huge
    local maxY = -math.huge

    for i = 1, #self.x do
        minX = math.min(self.x[i] + self.ox, minX)
        minY = math.min(self.y[i] + self.oy, minY)
        maxX = math.max(self.x[i] + self.ox, maxX)
        maxY = math.max(self.y[i] + self.oy, maxY)
    end

    self.bounds = {
        minX = minX,
        minY = minY,
        maxX = maxX,
        maxY = maxY
    }
end

function Polygon:getBounds()
    if not self.bounds then
        self:calculateBounds()
    end

    return self.bounds
end

function Polygon:contains(mx, my)
    local bounds = self:getBounds()

    if mx < bounds.minX or mx > bounds.maxX or my < bounds.minY or my > bounds.maxY then
        return false
    end

    local pointAmount = #self.x
    local i, j = pointAmount, pointAmount
    local oddNodes = false

    for i=1, pointAmount do
        if ((self.y[i]+self.oy < my and self.y[j]+self.oy >= my or self.y[j]+self.oy < my and self.y[i]+self.oy>=my) and (self.x[i]+self.ox<=mx or self.x[j]+self.ox<=mx)) then
            if (self.x[i]+self.ox+(my-(self.y[i]+self.oy))/(self.y[j]-self.y[i])*(self.x[j]-self.x[i])<mx) then
                oddNodes = not oddNodes
            end
        end
        j = i
    end

    return oddNodes
end

function Polygon:boundsIntersectRectangle(x, y, w, h)
    local bounds = self:getBounds()
    return x + w > bounds.minX and y + h > bounds.minY and x < bounds.maxX and y < bounds.maxY
end

function Polygon:boundsContainsRectangle(x, y, w, h)
    local bounds = self:getBounds()
    return x >= bounds.minX and y >= bounds.minY and (x + w) <= bounds.maxX and (y + h) <= bounds.maxY;
end

function Polygon:intersectsCircle(cx, cy, rad)
    local pointAmount = #self.x
    local j = pointAmount

    local circleBounds = { cx - rad, cy - rad, rad * 2, rad * 2 }

    if not (self:boundsIntersectRectangle(unpack(circleBounds)) or self:boundsContainsRectangle(unpack(circleBounds))) then
        return false
    end

    local radSq = rad * rad

    for i = 1, #self.x do
        local xi = self.x[i]
        local yi = self.y[i]
        local xj = self.x[j]
        local yj = self.y[j]
    
        local segX, segY = xj - xi, yj - yi
        local pX, pY = cx - xi, cy - yi

        local segL = math.sqrt(segX * segX + segY * segY)
        local segnX, segnY = segX / segL, segY / segL

        local dot = segnX * pX + segnY * pY

        local resultX, resultY

        if dot <= 0 then
            resultX = xi
            resultY = yi
        elseif dot >= segL then
            resultX = xj
            resultY = yj
        else
            resultX = xi + (segnX * dot)
            resultY = yi + (segnY * dot)
        end

        if (resultX - cx) ^ 2 + (resultY - cy) ^ 2 <= radSq then
            return true
        end

        j = i
    end

    return false
end

function Polygon:GetName()
    return "map_part"
end