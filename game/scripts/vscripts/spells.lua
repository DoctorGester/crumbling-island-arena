DUMMY_UNIT = "npc_dummy_unit"

Spells = Spells or class({})

function Spells:constructor()
    self.entities = {}
    self.dashes = {}
end

function Spells.TestPoint(point)
    return GameRules.GameMode.level:GetPartAt(point.x, point.y)
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
                        entity:MakeFall()
                    end

                    -- Doing damage to the pieces entity is standing on
                    if not GameRules.GameMode:IsDeathMatch() then
                        if hit and not level.running and instanceof(entity, Hero) then
                            for enthit, _ in pairs(hit) do
                                level:DamageGround(enthit, 0.35, entity)
                            end
                        end
                    end
                end
            , entity)
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

function Spells:GroundDamage(point, radius, source)
    GameRules.GameMode.level:DamageGroundInRadius(point, radius, source)
end

function Spells:GetValidTargets()
    return self:FilterEntities(function(ent)
        return not ent:IsInvulnerable() and ent:Alive()
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

function Wrappers.GuidedAbility(ability, forceFacing, doNotSetFacing)
    if ability._guided then
        return
    else
        ability._guided = true
    end

    local onChannelThink = ability.OnChannelThink
    local getCursorPosition = ability.GetCursorPosition

    function ability:OnChannelThink(interval)
        if interval == 0 then
            local function updateLastFacing(self, from)
                local delta = from - self:GetCaster():GetParentEntity():GetPos()
                delta = (delta * Vector(1, 1, 0)):Normalized()
                self.lastFacing = delta
                self.lastGuidedPos = from
            end

            updateLastFacing(self, getCursorPosition(self))

            self.listener = CustomGameEventManager:RegisterListener("guided_ability_cursor", function(_, args)
                local eventAbility = EntIndexToHScript(args.ability)

                if eventAbility ~= self then
                    return
                end

                local pos = Vector(args.pos["0"], args.pos["1"], args.pos["2"])
                updateLastFacing(self, pos)
            end)
        end

        if not doNotSetFacing then
            self:GetCaster():GetParentEntity():SetFacing(self.lastFacing)
        end

        onChannelThink(self, interval)
    end

    local onChannelFinish = ability.OnChannelFinish

    function ability:OnChannelFinish(interrupted)
        CustomGameEventManager:UnregisterListener(self.listener)

        if forceFacing then
            local caster = self:GetCaster()

            Timers:CreateTimer(function()
                if IsValidEntity(caster) then
                    caster:Interrupt()
                    caster:GetParentEntity():SetFacing(self.lastFacing)
                end
            end)
        end

        onChannelFinish(self, interrupted)
    end

    function ability:GetCursorPosition()
        return self.lastGuidedPos
    end
end