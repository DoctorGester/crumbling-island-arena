SECOND_STAGE_OBSTRUCTOR = "Layer2Obstructor"
THIRD_STAGE_OBSTRUCTOR = "Layer3Obstructor"

STARTING_DISTANCE = 2200
FINISHING_DISTANCE = 900

if Level == nil then
    Level = class({})
end

function Level:constructor()
    self.parts = Entities:FindAllByName("map_part")
    self.distance = STARTING_DISTANCE
    self.fallingParts = {}
    self.indexedParts = {}
    self.navIndex = {}
    self.psoIndex = {}
    self.running = true

    for _, part in ipairs(self.parts) do
        local position = part:GetAbsOrigin()
        part.x = position.x
        part.y = position.y
        part.z = position.z
        part.velocity = 0

        local id = math.floor(position:Length2D())
        local index = self.indexedParts[id]

        if not index then
            index = {}
            self.indexedParts[id] = index
        end

        table.insert(index, part)
    end

    self:BuildPolygonIndex()
end

function Level:BuildPolygonIndex()
    local worldMin = Vector(GetWorldMinX(), GetWorldMinY(), 0)
    local worldMax = Vector(GetWorldMaxX(), GetWorldMaxY(), 0)
    local x1 = GridNav:WorldToGridPosX(worldMin.x)
    local x2 = GridNav:WorldToGridPosX(worldMax.x)
    local y1 = GridNav:WorldToGridPosX(worldMin.y)
    local y2 = GridNav:WorldToGridPosX(worldMax.y)

    local gridIndex = {}

    for x = x1 + 1, x2 - 1 do
        for y = y1 + 1, y2 - 1 do
            local worldX = GridNav:GridPosToWorldCenterX(x)
            local worldY = GridNav:GridPosToWorldCenterY(y)

            local trace = {
                startpos = Vector(worldX, worldY, 127),
                endpos = Vector(worldX, worldY, 0)
            }

            TraceLine(trace)

            if trace.hit then
                local index = gridIndex[trace.enthit]
                
                if not index then
                    index = {}
                    gridIndex[trace.enthit] = index
                end

                table.insert(index, { x = x, y = y })
            end
        end
    end

    for ent, index in pairs(gridIndex) do
        local minX = x2
        local maxX = x1
        local minY = y2
        local maxY = y1

        local result = {}

        for _, position in ipairs(index) do
            minX = math.min(minX, position.x)
            maxX = math.max(maxX, position.x)
            minY = math.min(minY, position.y)
            maxY = math.max(maxY, position.y)
        end

        for x = minX, maxX, 2 do
            for y = minY, maxY, 2 do
                local worldX = GridNav:GridPosToWorldCenterX(x)
                local worldY = GridNav:GridPosToWorldCenterY(y)
                local params = { origin = Vector(worldX, worldY, 0) }

                table.insert(result, params)
            end
        end

        self.navIndex[ent] = result
    end
end

function Level:Reset()
    self.fallingParts = {}
    self.distance = STARTING_DISTANCE

    for _, part in ipairs(self.parts) do
        part:SetAbsOrigin(Vector(part.x, part.y, 0))
        part.z = 0

        if self.psoIndex[part] then
            for _, pso in ipairs(self.psoIndex[part]) do
                pso:RemoveSelf()
            end
        end
    end
end

function Level:EnableObstructors(obstructors, enable)
    for _, obstructor in pairs(obstructors) do
        obstructor:SetEnabled(enable, true)
    end
end

function Level:BlockPart(part)
    local nav = self.navIndex[part]

    if nav then
        local result = {}

        for _, data in ipairs(nav) do
            --local pso = SpawnEntityFromTableSynchronous("point_simple_obstruction", data)
            
            --table.insert(result, pso)
        end

        self.psoIndex[part] = result
    end
end

function Level:Unblock(distance)
    local index = self.indexedParts[distance]

    if index then
        for _, part in ipairs(index) do
            if self.psoIndex[part] then
                for _, pso in ipairs(self.psoIndex[part]) do
                    pso:RemoveSelf()
                end
            end
        end
    end
end

function Level:Update()
    local currentIndex = self.indexedParts[self.distance]

    if currentIndex and self.running then
        self:Unblock(self.distance + 64)

        for _, part in ipairs(currentIndex) do
            table.insert(self.fallingParts, part)

            self:BlockPart(part)
        end
    end

    for i = #self.fallingParts, 1, -1 do
        local part = self.fallingParts[i]
        part.velocity = part.velocity + 8
        part.z = part.z - part.velocity
        part:SetAbsOrigin(Vector(part.x, part.y, part.z))

        if part.z <= -4096 then
            table.remove(self.fallingParts, i)
        end
    end

    if self.distance > FINISHING_DISTANCE then
        self.distance = self.distance - 1
    else
        self.running = false
    end
end