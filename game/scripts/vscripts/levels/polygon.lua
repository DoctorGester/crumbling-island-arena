Polygon = class({})

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

function Polygon:GetName()
    return "map_part"
end