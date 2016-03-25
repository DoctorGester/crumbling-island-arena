DUMMY_UNIT = "npc_dummy_unit"

Spells = Spells or class({})

function Spells:constructor()
    self.entities = {}
    self.dashes = {}
end

function Spells.TestPoint(point, unit)
    local ground = point * Vector(1, 1, 0)
    
    local trace = {
        startpos = ground,
        endpos = ground - Vector(0, 0, 5),
        ignore = unit
    }

    TraceLine(trace)

    return trace.hit
end

function Spells:Update()
    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        if entity.destroyed then
            entity:Remove()
            table.remove(self.entities, i)
        end
    end

    for i = #self.dashes, 1, -1 do
        local dash = self.dashes[i]

        dash:Update()

        if dash.destroyed then
            table.remove(self.dashes, i)
        end
    end

    for _, entity in ipairs(self.entities) do
        entity:Update()
    end

    -- resolving collisions
    -- TODO add segment/circle and segment/segment resolvers

    for _, first in ipairs(self.entities) do
        if first:Alive() and first.collisionType == COLLISION_TYPE_INFLICTOR and not first.falling then
            for _, second in ipairs(self:GetValidTargets()) do
                if first ~= second and not first.falling and second:Alive() and second.collisionType ~= COLLISION_TYPE_NONE and first:CollidesWith(second) and second:CollidesWith(first) then
                    local radSum = first:GetRad() + second:GetRad()

                    if (first:GetPos() - second:GetPos()):Length2D() <= radSum then
                        first:CollideWith(second)
                        second:CollideWith(first)
                    end
                end
            end
        end
    end

    -- Resolving falling entities
    for _, entity in ipairs(self.entities) do
        if entity:CanFall() and not entity.falling then
            local hit = false
            local pos = entity:GetPos()

            for i = 0, 8 do
                local an = math.pi / 4 * i
                local point = pos + Vector(math.cos(an), math.sin(an)) * entity:GetRad()

                if Spells.TestPoint(point, entity.unit) then
                    hit = true
                    break
                end
            end

            if not hit then
                entity:MakeFall()
            end
        end
    end
end

function Spells:GroundDamage(point, radius)
    GameRules.GameMode.level:DamageGroundInRadius(point, radius)
end

function Spells:GetValidTargets()
    local result = {}

    for _, ent in pairs(self.entities) do
        if not ent.invulnerable and ent:Alive() then
            table.insert(result, ent)
        end
    end

    return result
end

function Spells:GetHeroTargets()
    local result = {}

    for _, ent in pairs(self:GetValidTargets()) do
        if ent:__instanceof__(Hero) then
            table.insert(result, ent)
        end
    end

    return result
end

function Spells:AddDash(dash)
    table.insert(self.dashes, dash)
end

function Spells:AddDynamicEntity(entity)
    table.insert(self.entities, entity)
end

Filters = {}

function Filters.Area(from, radius)
    return function(target)
        return (target:GetPos() - from):Length2D() <= radius
    end
end

function Filters.Cone(from, radius, direction, coneAngle)
    local rfilter = Filters.Area(from, radius)

    return function(target)
        local angle = math.acos(direction:Dot((target:GetPos() - from):Normalized()))

        return angle <= coneAngle / 2 and rfilter(target)
    end
end

function Filters.Line(from, to, width)
    return function(target)
        return SegmentCircleIntersection(from, to, target:GetPos(), target:GetRad() + (lineWidth or 0))
    end
end

function Filters.And(filter1, filter2)
    return function(target)
        return filter1(target) and filter2(target)
    end
end