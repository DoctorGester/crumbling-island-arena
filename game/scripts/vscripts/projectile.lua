Projectile = Projectile or class({}, nil, DynamicEntity)

-- TODO target + targetReached
function Projectile:constructor(round, params)
    DynamicEntity.constructor(self, round)

    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.hero = params.owner
    self.owner = self.hero.owner
    self.from = params.from
    self.to = params.to
    self.radius = params.radius or 64
    self.distance = params.distance
    self.distancePassed = 0

    self.unit = CreateUnitByName(DUMMY_UNIT, self.from, false, nil, nil, DOTA_TEAM_NOTEAM)
    self.unit:SetForwardVector(self.to - self.from)
    self.unit:SetNeverMoveToClearSpace(true)

    self.particle = ParticleManager:CreateParticle(params.graphics, PATTACH_ABSORIGIN_FOLLOW , self.unit)

    self.hitModifier = params.hitModifier -- { name, duration, ability }
    self.hitSound = params.hitSound
    self.hitFunction = params.hitFunction
    self.hitCondition = params.hitCondition
    self.continueOnHit = params.continueOnHit or false
    self.gracePeriod = params.gracePeriod or 30
    self.hitGroup = {}

    self.previousPosition = self.from
    self:SetPos(self.from)
    self:SetSpeed(params.speed or 600)
end

function Projectile:Update()
    if IsOutOfTheMap(self:GetPos()) then
        self:Destroy()
        return
    end

    if self.distance and self.distance <= self.distancePassed then
        self:Destroy()
    end

    self.previousPosition = self:GetPos()

    local pos = self:GetNextPosition()

    self.distancePassed = self.distancePassed + (self.previousPosition - pos):Length2D()
    
    self:SetPos(pos)
end

function Projectile:CollidesWith(target)
    if self.hitCondition then
        return self:hitCondition(target)
    end

    return DynamicEntity.CollidesWith(self, target)
end

function Projectile:CollideWith(target)
    if self.hitGroup[target] then
        return
    end

    if self.hitFunction then
        self:hitFunction(target)
    else
        target:Damage(self)
        target.round:CheckEndConditions()
    end
    
    if self.hitSound then
        target:EmitSound(self.hitSound)
    end

    if self.hitModifier then
        target:AddNewModifier(self.hero, self.hitModifier.ability, self.hitModifier.name, { duration = self.hitModifier.duration })
    end

    if self.continueOnHit then
        self.hitGroup[target] = true
    else
        self:Destroy()
    end
end

function Projectile:SetPos(pos)
    DynamicEntity.SetPos(self, pos)

    self.unit:SetAbsOrigin(pos)
end

function Projectile:GetNextPosition()
    return self:GetPos() + ((self.to - self.from):Normalized() * (self:GetSpeed() / 30))
end

function Projectile:Damage(source)
    self:Destroy()
end

function Projectile:GetSpeed()
    return self.speed
end

function Projectile:SetSpeed(speed)
    self.speed = speed
end

function Projectile:Remove()
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    self.unit:RemoveSelf()
end