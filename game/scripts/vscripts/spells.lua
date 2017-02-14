DUMMY_UNIT = "npc_dummy_unit"

Spells = Spells or class({})

function Spells:constructor()
    self.entities = {}
    self.dashes = {}
end

function Spells.TestPoint(point)
    return GameRules.GameMode.level:GetPartAt(point.x, point.y)
end

function Spells.TestCircle(point, rad)
    return GameRules.GameMode.level:FindCirclePartIntersection(point.x, point.y, rad)
end

function Spells.WrapException(callback, ...)
    local status, err = pcall(callback, ...)

    if not status then
        print(err)
    end
end

function Spells:Update()
    for i = #self.entities, 1, -1 do
        local entity = self.entities[i]

        if entity.destroyed then
            Spells.WrapException(
                function(entity, i)
                    entity:Remove()
                    table.remove(self.entities, i)
                end
            , entity, i)
        end
    end

    for i = #self.dashes, 1, -1 do
        local dash = self.dashes[i]

        Spells.WrapException(
            function(dash, i)
                if not dash.destroyed then
                    dash:Update()
                else
                    table.remove(self.dashes, i)
                end
            end
        , dash, i)
    end

    for _, entity in ipairs(self.entities) do
        Spells.WrapException(
            function(entity)
                if not entity.destroyed then
                    entity:Update()
                end
            end
        , entity)
    end

    -- resolving collisions
    -- TODO add segment/circle and segment/segment resolvers

    for _, first in ipairs(self.entities) do
        if first:Alive() and first.collisionType == COLLISION_TYPE_INFLICTOR and not first.falling then
            for _, second in ipairs(self:GetValidTargets()) do
                Spells.WrapException(
                    function(first, second)
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
                , first, second)
            end
        end
    end

    -- Resolving falling entities
    for _, entity in ipairs(self.entities) do
        if entity:CanFall() and not entity.falling then
            Spells.WrapException(
                function(entity)
                    local level = GameRules.GameMode.level
                    local hit = entity:TestFalling()

                    if not hit then
                        local softKb = self:FindSoftKnockback(entity)
                        local horVel

                        if softKb then
                            horVel = softKb.direction * softKb.force
                        end

                        print(softKb, horVel)

                        entity:MakeFall(horVel)
                    end

                    -- Doing damage to the pieces entity is standing on
                    if not GameRules.GameMode:IsDeathMatch() then
                        if hit and not level.running and instanceof(entity, Hero) then
                            for enthit, _ in pairs(hit) do
                                local p = Vector(enthit.x, enthit.y)
                                local dir = (entity:GetPos() - p):Normalized() * 20

                                level:DamageGround(enthit, 0.35, entity, p + dir, 0)
                            end
                        end
                    end
                end
            , entity)
        end
    end
end

function Spells:FindSoftKnockback(entity)
    for _, dash in ipairs(self.dashes) do
        if instanceof(dash, SoftKnockback) and dash.hero == entity then
            return dash
        end
    end

    return nil
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

function Spells:GroundDamage(point, radius, source, suppress)
    local hitByHero = {}

    -- TODO fix self:GroundDamage
    for _, hero in pairs(GameRules.GameMode.round.spells:GetHeroTargets()) do
        if hero ~= source then
            local hit = hero:TestFalling()

            if hit then
                hitByHero[hero] = hit
            end
        end
    end

    local parts = GameRules.GameMode.level:DamageGroundInRadius(point, radius, source, suppress)

    for hero, hit in pairs(hitByHero) do
        for _, part in pairs(parts) do
            if part.launched and hit[part] then
                hero:AddNewModifier(hero, nil, "modifier_launched", { duration = 0.5 })
                break
            end
        end
    end
end

function Spells:GetValidTargets()
    return self:FilterEntities(function(ent)
        return not ent:IsInvulnerable() and ent:Alive() and not ent.falling
    end)
end

function Spells:GetHeroTargets()
    return self:FilterEntities(function(ent)
        return instanceof(ent, Hero)
    end, self:GetValidTargets())
end

function Spells:FindClosest(to, range, list)
    local min = math.huge
    local closest = nil

    for _, ent in pairs(list or self.entities) do
        local distance = (ent:GetPos() - to):Length2D()

        if distance < min and distance <= range then
            min = distance
            closest = ent
        end
    end

    return closest
end

function Spells:FilterEntities(filter, list)
    local result = {}

    for _, ent in pairs(list or self.entities) do
        if filter(ent) then
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
        local dot = direction:Dot((target:GetPos() - from):Normalized())
        dot = math.min(math.max(dot, -1), 1) -- Yes, that happens

        return math.acos(dot) <= coneAngle / 2 and rfilter(target)
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