DUMMY_UNIT = "npc_dummy_unit"

Spells = Spells or class({})

function Spells:constructor()
    self.entities = {}
    self.dashes = {}
end

function Spells.TestPoint(point)
    return GameRules.GameMode.level:GetPartAt(point.x, point.y)
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

        if not dash.destroyed then
            dash:Update()
        else
            table.remove(self.dashes, i)
        end
    end

    for _, entity in ipairs(self.entities) do
        if not entity.destroyed then
            entity:Update()
        end
    end

    -- resolving collisions
    -- TODO add segment/circle and segment/segment resolvers

    for _, first in ipairs(self.entities) do
        if first:Alive() and first.collisionType == COLLISION_TYPE_INFLICTOR and not first.falling then
            for _, second in ipairs(self:GetValidTargets()) do
                if first ~= second and not second.falling and first:Alive() and second:Alive() and second.collisionType ~= COLLISION_TYPE_NONE and first:CollidesWith(second) and second:CollidesWith(first) then
                    local radSum = first:GetRad() + second:GetRad()

                    if (first:GetPos() - second:GetPos()):Length2D() <= radSum then
                        if not second:IsInvulnerable() then
                            first:CollideWith(second)
                        end

                        if not first:IsInvulnerable() then
                            second:CollideWith(first)
                        end
                    end
                end
            end
        end
    end

    -- Resolving falling entities
    for _, entity in ipairs(self.entities) do
        if entity:CanFall() and not entity.falling then
            local level = GameRules.GameMode.level
            local hit = entity:TestFalling()

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

function Spells:InterruptDashes(hero)
    for i = #self.dashes, 1, -1 do
        local dash = self.dashes[i]

        if dash.hero == hero then
            dash:Interrupt()

            if dash.destroyed then
                table.remove(self.dashes, i)
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
        if not ent:IsInvulnerable() and ent:Alive() then
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

function Filters.WrapFilter(filter)
    local meta = {
        __add = function(filter1, filter2) 
            return Filters.And(filter1, filter2)
        end,
        __call = function(table, ...)
            return table.f(...)
        end,
        __concat = function(filter1, filter2)
            return Filters.Or(filter1, filter2)
        end,
        __unm = function(filter1)
            return Filters.Not(filter1)
        end
    }

    local table = {
        f = filter
    }

    setmetatable(table, meta)

    return table
end

function Filters.Area(from, radius)
    return Filters.WrapFilter(function(target)
        return (target:GetPos() - from):Length2D() <= radius
    end)
end

function Filters.Cone(from, radius, direction, coneAngle)
    local rfilter = Filters.Area(from, radius)

    return Filters.WrapFilter(function(target)
        local angle = math.acos(direction:Dot((target:GetPos() - from):Normalized()))

        return angle <= coneAngle / 2 and rfilter(target)
    end)
end

function Filters.Line(from, to, width)
    return Filters.WrapFilter(function(target)
        return SegmentCircleIntersection(from, to, target:GetPos(), target:GetRad() + (width or 0))
    end)
end

function Filters.And(filter1, filter2)
    return Filters.WrapFilter(function(target)
        return filter1(target) and filter2(target)
    end)
end

function Filters.Or(filter1, filter2)
    return Filters.WrapFilter(function(target)
        return filter1(target) or filter2(target)
    end)
end

function Filters.Not(filter1)
    return Filters.WrapFilter(function(target)
        return not filter1(target)
    end)
end

function Filters.NotEquals(who)
    return Filters.WrapFilter(function(target)
        return target ~= who
    end)
end

Wrappers = {}

function Wrappers.DirectionalAbility(ability, optionalRange, optionalMinRange)
    function ability:GetCastRange()
        return 0
    end

    local getCursorPosition = ability.BaseClass.GetCursorPosition

    function ability:GetDirection()
        local target = getCursorPosition(ability)
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = (target - casterPos):Normalized() * Vector(1, 1, 0)

        if direction:Length2D() == 0 then
            direction = self:GetCaster():GetForwardVector()
        end

        return direction
    end

    function ability:GetCursorPosition()
        local target = getCursorPosition(ability)
        local realRange = optionalRange or self.BaseClass.GetCastRange(self, target, nil)
        local minRange = optionalMinRange or 0
        local casterPos = self:GetCaster():GetAbsOrigin()
        local direction = self:GetDirection()

        if realRange > 0 and (target - casterPos):Length2D() > realRange then
            target = casterPos + direction * realRange
        end

        if (target - casterPos):Length2D() < minRange then
            target = casterPos + direction * minRange
        end

        return target
    end
end