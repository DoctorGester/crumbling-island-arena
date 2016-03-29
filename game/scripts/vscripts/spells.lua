DUMMY_UNIT = "npc_dummy_unit"

Spells = Spells or class({})

function Spells:constructor()
    self.entities = {}
    self.dashes = {}
end

function Spells.TestPoint(point, unit)
    local ground = point * Vector(1, 1, 0) - Vector(0, 0, 1)
    
    local trace = {
        startpos = ground,
        endpos = ground - Vector(0, 0, 5),
        ignore = unit
    }

    TraceLine(trace)

    return trace.enthit
end

function Spells.TestEntity(entity)
    local pos = entity:GetPos()
    local hit = nil

    for i = 0, 8 do
        local an = math.pi / 4 * i
        local point = pos + Vector(math.cos(an), math.sin(an)) * entity:GetRad()
        local enthit = Spells.TestPoint(point, entity.unit)

        if enthit and enthit:GetName() == "map_part" then
            if not hit then
                hit = {}
            end

            hit[enthit] = true
        end
    end

    return hit
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
                if first ~= second and not second.falling and second:Alive() and second.collisionType ~= COLLISION_TYPE_NONE and first:CollidesWith(second) and second:CollidesWith(first) then
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
            local level = GameRules.GameMode.level
            local hit = Spells.TestEntity(entity)

            if not hit then
                entity:MakeFall()
            end

            -- Doing damage to the pieces entity is standing on
            if hit and not level.running and instanceof(entity, Hero) then
                for enthit, _ in pairs(hit) do
                    level:DamageGround(enthit, 0.35)
                end
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
        return SegmentCircleIntersection(from, to, target:GetPos(), target:GetRad() + (width or 0))
    end
end

function Filters.And(filter1, filter2)
    return function(target)
        return filter1(target) and filter2(target)
    end
end

function Filters.NotEquals(who)
    return function(target)
        return target ~= who
    end
end

Wrappers = {}

function Wrappers.DirectionalAbility(ability, optionalRange)
    function ability:GetCastRange()
        return 0
    end

    local getCursorPosition = ability.BaseClass.GetCursorPosition

    function ability:GetDirection()
        local target = getCursorPosition(ability)
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = (target - casterPos):Normalized() * Vector(1, 1, 0)

        if direction:Length2D() == 0 then
            direction = hero:GetFacing()
        end

        return direction
    end

    function ability:GetCursorPosition()
        local target = getCursorPosition(ability)
        local realRange = optionalRange or self.BaseClass.GetCastRange(self)
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = self:GetDirection()

        if (target - casterPos):Length2D() > realRange then
            target = casterPos + direction * realRange
        end

        return target
    end
end