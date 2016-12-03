function Level:LoadPolygons()
    self.polygons = require("levels/"..MAPS[GetMapName()].prefab)
end

function Level:Clusterize()
    local maxArea = -math.huge
    local biggestBounds = nil

    for _, polygon in ipairs(self.polygons) do
        local bounds = polygon:getBounds()
        local area = (bounds.maxX - bounds.minX) * (bounds.maxY - bounds.minY)

        if area > maxArea then
            biggestBounds = bounds
            maxArea = area
        end
    end

    self.cellSize = math.max(biggestBounds.maxX - biggestBounds.minX, biggestBounds.maxY - biggestBounds.minY) + 1
    self.clusters = {}

    for _, polygon in ipairs(self.polygons) do
        --[[ Not entirely sure why but it fails sometimes
            for i = 1, #polygon.x do
                self:AddPolyPointToCluster(polygon, polygon.x[i], polygon.y[i])
            end
        ]]

        local bounds = polygon:getBounds()

        self:AddPolyPointToCluster(polygon, polygon.originX, polygon.originY)
        self:AddPolyPointToCluster(polygon, bounds.minX, bounds.minY)
        self:AddPolyPointToCluster(polygon, bounds.maxX, bounds.maxY)
        self:AddPolyPointToCluster(polygon, bounds.maxX, bounds.minY)
        self:AddPolyPointToCluster(polygon, bounds.minX, bounds.maxY)
    end
end

function Level:AddPolyPointToCluster(polygon, x, y)
    local clusterX = math.floor(x / self.cellSize)
    local clusterY = math.floor(y / self.cellSize)

    local row = self.clusters[clusterY]

    if row == nil then
        row = {}
        self.clusters[clusterY] = row
    end

    local column = row[clusterX]

    if column == nil then
        column = {}
        row[clusterX] = column
    end

    column[polygon] = 1
end

function Level:UpdatePolyPointCluster(polygon, oldX, oldY, newX, newY)
    local oldCX = math.floor(oldX / self.cellSize)
    local oldCY = math.floor(oldY / self.cellSize)

    local newCX = math.floor(oldX / self.cellSize)
    local newCY = math.floor(oldY / self.cellSize)

    if oldCX ~= newCX or oldCY ~= newCY then
        self.clusters[oldCY][oldCX][polygon] = nil

        self:AddPolyPointToCluster(polygon, newX, newY)
    end
end

function Level:AssociatePieces()
    for _, part in pairs(self.parts) do
        local found = nil

        for _, polygon in ipairs(self.polygons) do
            if (Vector(part.x, part.y, 0) - Vector(polygon.originX, polygon.originY, 0)):Length2D() <= 64 then
                found = polygon
                break
            end
        end
        
        local poly = self:GetClosestPolygonAt(part.x, part.y, true)

        if not poly then
            poly = self:GetClosestPolygonAt(part.x, part.y, false)
        end

        if poly then
            poly.part = part
            part.poly = poly
        else
            DebugDrawSphere(Vector(part.x, part.y, 0), Vector(0, 255, 0), 200, 32, false, 6000)
            print("Not found for", part.x, part.y)
        end
    end

    if IsInToolsMode() then
        for _, poly in ipairs(self.polygons) do
            if not poly.part then
                self:DebugPolygon(poly)
            end
        end
    end
end

function Level:GetPartAt(x, y)
    local polygon = self:GetPolygonAt(x, y)

    if polygon and polygon.part.z > -1000 then
        return polygon.part
    end
end

function Level:DistanceToPolygon(x, y, poly)
    return (Vector(x, y, 0) - Vector(poly.originX, poly.originY, 0)):Length2D()
end

function Level:GetClosestPolygonAt(x, y, checkContains)
    local closest = nil
    local minDist = math.huge

    for _, polygon in ipairs(self.polygons) do
        if not polygon.part and (not checkContains or polygon:contains(x, y)) then
            local distance = self:DistanceToPolygon(x, y, polygon)

            if distance < minDist then
                minDist = distance
                closest = polygon
            end
        end
    end

    return closest
end 

function Level:DebugPolygon(poly, time)
    local h = GetGroundHeight(Vector(0, 0, 0), nil)
    local len = #poly.x

    for i = 2, len do
        DebugDrawLine(Vector(poly.x[i]+poly.ox, poly.y[i]+poly.oy, h), Vector(poly.x[i - 1]+poly.ox, poly.y[i - 1]+poly.oy, h), 255, 0, 0, false, time or 6000)
    end

    DebugDrawLine(Vector(poly.x[len]+poly.ox, poly.y[len]+poly.oy, h), Vector(poly.x[1]+poly.ox, poly.y[1]+poly.oy, h), 255, 0, 0, false, time or 6000)
end

function Level:DebugBounds(bounds, time)
    local h = GetGroundHeight(Vector(0, 0, 0), nil) + 1
    local t = time or 6000

    DebugDrawLine(Vector(bounds.minX, bounds.minY, h), Vector(bounds.minX, bounds.maxY, h), 100, 255, 0, false, t)
    DebugDrawLine(Vector(bounds.minX, bounds.maxY, h), Vector(bounds.maxX, bounds.maxY, h), 100, 255, 0, false, t)
    DebugDrawLine(Vector(bounds.maxX, bounds.maxY, h), Vector(bounds.maxX, bounds.minY, h), 100, 255, 0, false, t)
    DebugDrawLine(Vector(bounds.maxX, bounds.minY, h), Vector(bounds.minX, bounds.minY, h), 100, 255, 0, false, t)
end

function Level:DebugCluster(clusterX, clusterY, time)
    local bounds = {
        minX = clusterX * self.cellSize,
        minY = clusterY * self.cellSize,
        maxX = (clusterX + 1) * self.cellSize,
        maxY = (clusterY + 1) * self.cellSize,
    }

    self:DebugBounds(bounds, time)
end

function Level:GetClusterAt(x, y)
    local clusterX = math.floor(x / self.cellSize)
    local clusterY = math.floor(y / self.cellSize)

    local row = self.clusters[clusterY]

    if not row then
        return nil
    end

    return row[clusterX]
end

function Level:GetPolygonAt(x, y)
    local cluster = self:GetClusterAt(x, y)

    if not cluster then
        return nil
    end

    for polygon, _ in pairs(cluster) do
        --self:DebugPolygon(polygon, 0.1)
        if polygon:contains(x, y) then
            return polygon
        end
    end
end

function Level:FindCirclePartIntersection(x, y, rad)
    local clusters = {}

    local function insertCluster(ox, oy)
        local c = self:GetClusterAt(x + ox, y + oy)

        if c then
            clusters[c] = true
        end
    end

    insertCluster(rad, rad)
    insertCluster(rad, -rad)
    insertCluster(-rad, rad)
    insertCluster(-rad, -rad)
    insertCluster(0, 0)

    local result

    for cluster, _ in pairs(clusters) do
        for polygon, _ in pairs(cluster) do
            if polygon.part.z > -1000 and (polygon:contains(x, y) or polygon:intersectsCircle(x, y, rad)) then
                --self:DebugPolygon(polygon, 0.1)

                if not result then
                    result = {}
                end

                result[polygon.part] = true
            end
        end
    end

    return result
end

function Level:SetPartOffset(part, offsetX, offsetY)
    part.offsetX = offsetX
    part.offsetY = offsetY
    self:UpdatePartPosition(part)

    if part.poly then
        local polygon = part.poly
        local oldOX = polygon.originX + polygon.ox
        local oldOY = polygon.originY + polygon.oy
        local boundsOld = vlua.clone(polygon:getBounds())
        polygon:setOffset(offsetX, offsetY)
        local bounds = polygon:getBounds()

        self:UpdatePolyPointCluster(polygon, oldOX, oldOY, polygon.originX + offsetX, polygon.originY + offsetY)
        self:UpdatePolyPointCluster(polygon, boundsOld.minX, boundsOld.minY, bounds.minX, bounds.minY)
        self:UpdatePolyPointCluster(polygon, boundsOld.maxX, boundsOld.maxY, bounds.maxX, bounds.maxY)
        self:UpdatePolyPointCluster(polygon, boundsOld.maxX, boundsOld.minY, bounds.maxX, bounds.minY)
        self:UpdatePolyPointCluster(polygon, boundsOld.minX, boundsOld.maxY, bounds.minX, bounds.maxY)
    end
end

local reset = Level.Reset
function Level:Reset(...)
    reset(self, ...)

    for _, polygon in ipairs(self.polygons) do
        polygon:setOffset(0, 0)
    end
end