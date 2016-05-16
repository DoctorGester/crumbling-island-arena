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
        self.modifierHandle
            = self.hero:AddNewModifier(self.modifier.source or self.hero, self.modifier.ability, self.modifier.name, {})
    end

    hero.round.spells:AddDash(self)
end

function Dash:SetModifierHandle(modifier)
    local all = self.hero:AllModifiers()

    -- Destroying a modifier which is already removed results in crash
    for _, modifier in pairs(all) do
        if modifier == self.modifierHandle then
            self.modifierHandle:Destroy(false)
            break
        end
    end

    self.modifierHandle = modifier
end

function Dash:Update()
    if self.hero.destroyed then
        if self.loopingSound then
            self.hero:StopSound(self.loopingSound)
        end

        self.destroyed = true
        return
    end

    local origin = self.hero:GetPos()
    local result = self:PositionFunction(origin)

    result.z = self.zStart + self:HeightFunction(origin)
    self.hero:SetPos(result)

    if self.hitParams then
        local params = vlua.clone(self.hitParams)

        local function groupFilter(target)
            return not self.hitGroup[target]
        end

        params.filter = Filters.And(Filters.Line(origin, result, self.hero:GetRad()), groupFilter)
        params.filterProjectiles = true

        local hurt = self.hero:AreaEffect(params)

        for _, target in ipairs(hurt or {}) do
            self.hitGroup[target] = true
        end
    end

    local interrupted = self:IsStunned() or not self.hero:Alive()
    if (self.to - origin):Length2D() <= self.velocity or interrupted then
        self:End(self.hero:GetPos(), not interrupted)
    end

    return result
end

function Dash:End(at, reachedDestination)
    if self.findClearSpace then
        GridNav:DestroyTreesAroundPoint(at, self.radius, true, 1)
        self.hero:FindClearSpace(at, false)
    else
        self.hero:SetPos(at)
    end

    self:OnArrival(reachedDestination)
    self.destroyed = true
end

function Dash:Interrupt()
    self:End(self.hero:GetPos(), false)
end

function Dash:IsStunned()
    for _, modifier in pairs(self.hero:AllModifiers()) do
        if modifier ~= self.modifierHandle then
            if modifier.IsStunDebuff and modifier:IsStunDebuff() then
                if self.modifierHandle then
                    return modifier:GetCaster() ~= self.modifierHandle:GetCaster()
                end

                return true
            end
        end
    end

    return false
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
    self:SetModifierHandle(nil)

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

-- Knockback utility method

function Knockback(hero, ability, direction, distance, speed, heightFunction)
    hero.round.spells:InterruptDashes(hero)

    Dash(hero, hero:GetPos() + direction:Normalized() * distance, speed, {
        modifier = { name = "modifier_knockback_lua", ability = ability, source = ability:GetCaster() },
        heightFunction = heightFunction
    })
end