Dash = Dash or class({})

function Dash:constructor(hero, to, speed, params)
    self.hero = hero
    self.to = to
    self.velocity = speed / 30

    self.from = hero:GetPos()
    self.zStart = hero:GetGroundHeight(self.from)

    self.radius = params.radius or 128
    self.modifier = params.modifier
    self.arrivalSound = params.arrivalSound
    self.loopingSound = params.loopingSound
    self.findClearSpace = params.findClearSpace

    if self.findClearSpace == nil then
       self.findClearSpace = true 
    end

    self.PositionFunction = params.positionFunction or self.PositionFunction
    self.heightFunction = params.heightFunction
    self.arrivalFunction = params.arrivalFunction
    self.hitParams = params.hitParams
    self.hitGroup = {}
    self.interruptedByStuns = params.interruptedByStuns

    if self.interruptedByStuns == nil then
       self.interruptedByStuns = true 
    end

    self.destroyed = false

    if self.loopingSound then
        self.hero:EmitSound(self.loopingSound)
    end

    if params.forceFacing then
        local facing = self.to - self.from

        if facing:Length2D() == 0 then
            facing = self.hero:GetFacing()
        end
        
        self.hero:SetFacing(facing:Normalized() * Vector(1, 1, 0))
    end

    if self.modifier then
        local duration = nil

        if self.to and not params.noFixedDuration then
            duration = (self.to - self.hero:GetPos()):Length2D() / speed
        end

        self.modifierHandle
            = self.hero:AddNewModifier(self.modifier.source or self.hero, self.modifier.ability, self.modifier.name, { duration = duration })

        if self.modifierHandle == nil then
            self.cantStart = true
        end
    end

    hero.round.spells:AddDash(self)
end

function Dash:SetModifierHandle(modifier)
    local all = self.hero:AllModifiers()

    -- Destroying a modifier which is already removed results in crash
    for _, modifier in pairs(all) do
        if modifier == self.modifierHandle then
            self.modifierHandle:Destroy()
            break
        end
    end

    self.modifierHandle = modifier
end

function Dash:HasEnded()
    return (self.to - self.hero:GetPos()):Length2D() <= self.velocity
end

function Dash:Update()
    local result = nil
    if self.hero:Alive() and not self.cantStart then
        local origin = self.hero:GetPos()
        result = self:PositionFunction(origin)

        result.z = self.zStart + self:HeightFunction(origin)
        self.hero:SetPos(result)

        if self.hitParams then
            local params = vlua.clone(self.hitParams)

            local function groupFilter(target)
                return not self.hitGroup[target]
            end

            params.filter = Filters.Line(origin, result, self.hero:GetRad()) + Filters.WrapFilter(groupFilter)
            params.filterProjectiles = true

            local hurt = self.hero:AreaEffect(params)

            for _, target in ipairs(hurt or {}) do
                self.hitGroup[target] = true
            end
        end
    end

    local modifierRemoved = (self.modifier and self.hero:Alive()) and self.hero:FindModifier(self.modifier.name) ~= self.modifierHandle
    local interrupted = not self.hero:Alive() or self:IsStunned() or modifierRemoved or self.cantStart
    if interrupted or self:HasEnded() then
        self:End(self.hero:Alive() and self.hero:GetPos() or self.to, not interrupted)
    end

    return result
end

function Dash:End(at, reachedDestination)
    if (at - self.to):Length2D() < 100 then
        at = self.to
    end

    if self.hero:Alive() then
        if self.findClearSpace then
            GridNav:DestroyTreesAroundPoint(at, self.radius, true)
            self.hero:FindClearSpace(at, false)
        else
            self.hero:SetPos(at)
        end
    end

    self:OnArrival(reachedDestination)
    self.destroyed = true
end

function Dash:Interrupt()
    self:End(self.hero:GetPos(), false)
end

function Dash:IsStunned()
    if self.interruptedByStuns then
        for _, modifier in pairs(self.hero:AllModifiers()) do
            if modifier ~= self.modifierHandle then
                if modifier.IsStunDebuff and modifier:IsStunDebuff() then
                    if self.modifierHandle then
                        return modifier:GetCaster() ~= self.modifierHandle:GetCaster() or modifier:GetName() == "modifier_falling"
                    end

                    return true
                end
            end
        end

        return false
    else
        return self.hero:HasModifier("modifier_falling")
    end
end

function Dash:PositionFunction(current)
    local diff = self.to - current
    return current + (diff:Normalized() * self.velocity)
end

function Dash:HeightFunction(current)
    if self.heightFunction then
        return self:heightFunction(current)
    end

    return 0
end

function Dash:OnArrival(reachedDestination)
    if self.hero:Alive() then
        self:SetModifierHandle(nil)
    end

    if self.arrivalSound then
        self.hero:EmitSound(self.arrivalSound)
    end

    if self.loopingSound then
        self.hero:StopSound(self.loopingSound)
    end

    if self.arrivalFunction and reachedDestination then
        self:arrivalFunction()
    end
end

FunctionDash = FunctionDash or class({}, nil, Dash)

function FunctionDash:constructor(hero, to, time, params)
    getbase(FunctionDash).constructor(self, hero, to, (hero:GetPos() - to):Length2D() / time, params)

    self.time = time
    self.startTime = GameRules:GetGameTime()
end

function FunctionDash:HasEnded()
    return (GameRules:GetGameTime() - self.startTime) >= self.time
end

function FunctionDash:PositionFunction(current)
    -- Cubic
    local function f(t)
        return t*(2-t) 
    end

    local progress = math.min((GameRules:GetGameTime() - self.startTime) / self.time, 1.0)
    progress = f(progress)

    return self.from + (self.to - self.from) * progress
end

-- Knockback utility method

function Knockback(hero, ability, direction, distance, speed, heightFunction, modifier)
    hero.round.spells:InterruptDashes(hero)

    local multipler = 1

    for _, modifier in pairs(hero:AllModifiers()) do
        if modifier.GetKnockbackMultiplier then
            multipler = multipler * modifier:GetKnockbackMultiplier()
        end
    end

    Dash(hero, hero:GetPos() + direction:Normalized() * distance * multipler, speed, {
        modifier = { name = modifier or "modifier_knockback_lua", ability = ability, source = ability:GetCaster() },
        heightFunction = heightFunction,
        interruptedByStuns = false
    })
end