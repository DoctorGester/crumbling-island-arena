Projectile = Projectile or class({}, nil, UnitEntity)

function Projectile:constructor(round, params)
    getbase(Projectile).constructor(self, round, DUMMY_UNIT, params.from)

    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.modifierImmune = true
    self.hero = params.owner
    self.owner = self.hero.owner
    self.from = params.from
    self.to = params.to
    self.vel = (self.to - self.from):Normalized()
    self.radius = params.radius or 64

    if self.vel:Length2D() == 0 then
        self.vel = self.hero:GetFacing()
    end

    self:SetFacing(self.to - self.from)
    self:GetUnit():SetNeverMoveToClearSpace(true)
    self:SetGraphics(params.graphics)

    self.hitModifier = params.hitModifier -- { name, duration, ability }
    self.hitSound = params.hitSound
    self.hitFunction = params.hitFunction
    self.hitCondition = params.hitCondition
    self.destroyFunction = params.destroyFunction
    self.continueOnHit = params.continueOnHit or false
    self.gracePeriod = params.gracePeriod or 30
    self.hitGroup = {}

    self:SetPos(self.from)
    self:SetSpeed(params.speed or 600)

    Statistics.IncreaseProjectilesFired(self.owner)
end

function Projectile:CanFall()
    return false
end

function Projectile:Update()
    getbase(Projectile).Update(self)

    if self.falling then
        return
    end

    local pos = self:GetPos()

    if IsOutOfTheMap(pos) then
        self:Destroy()
        return
    end
    
    for target, time in pairs(self.hitGroup) do
        self.hitGroup[target] = time - 1
    end

    self:SetPos(self:GetNextPosition(pos))
end

function Projectile:CollidesWith(target)
    if self.hitCondition then
        return self:hitCondition(target)
    end

    return self.owner ~= target.owner
end

function Projectile:CollideWith(target)
    if self.hitGroup[target] and self.hitGroup[target] > 0 then
        return
    end

    if self.hitFunction then
        self:hitFunction(target)
    else
        target:Damage(self)
    end
    
    if self.hitSound then
        target:EmitSound(self.hitSound)
    end

    if self.hitModifier then
        target:AddNewModifier(self.hero, self.hitModifier.ability, self.hitModifier.name, { duration = self.hitModifier.duration })
    end

    if self.continueOnHit then
        self.hitGroup[target] = self.gracePeriod
    else
        self:Destroy()
    end
end

function Projectile:GetNextPosition(pos)
    return pos + (self.vel * (self:GetSpeed() / 30))
end

function Projectile:Damage(source)
    local mode = GameRules:GetGameModeEntity()
    local dust = ParticleManager:CreateParticle("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN, mode)
    ParticleManager:SetParticleControl(dust, 0, self:GetPos())
    ParticleManager:SetParticleControl(dust, 1, self:GetPos())
    ParticleManager:ReleaseParticleIndex(dust)

    local sign = ParticleManager:CreateParticle("particles/msg_fx/msg_deny.vpcf", PATTACH_CUSTOMORIGIN, mode)
    ParticleManager:SetParticleControl(sign, 0, self:GetPos())
    ParticleManager:SetParticleControl(sign, 3, Vector(200, 0, 0))
    ParticleManager:ReleaseParticleIndex(sign)

    self:Destroy()
end

function Projectile:GetSpeed()
    return self.speed
end

function Projectile:SetSpeed(speed)
    self.speed = speed
end

function Projectile:SetGraphics(graphics)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    if graphics then
        self.particle = ParticleManager:CreateParticle(graphics, PATTACH_ABSORIGIN_FOLLOW , self:GetUnit())
    end
end

function Projectile:Remove()
    if self.destroyFunction then
        self:destroyFunction()
    end

    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    getbase(Projectile).Remove(self)
end

-- Projectile with distance cap

DistanceCappedProjectile = DistanceCappedProjectile or class({}, nil, Projectile)

function DistanceCappedProjectile:constructor(round, params)
    getbase(DistanceCappedProjectile).constructor(self, round, params)

    self.distance = params.distance or 1000
    self.distancePassed = 0
end

function DistanceCappedProjectile:Update()
    local prev = self:GetPos()
    getbase(DistanceCappedProjectile).Update(self)
    local pos = self:GetPos()

    if self.distance and self.distance <= self.distancePassed then
        self:Destroy()
    end

    self.distancePassed = self.distancePassed + (prev - pos):Length2D()
end

-- Projectile with point target

PointTargetProjectile = PointTargetProjectile or class({}, nil, Projectile)

function PointTargetProjectile:constructor(round, params)
    getbase(DistanceCappedProjectile).constructor(self, round, params)

    self.target = params.target or params.to
    self.targetReachedFunction = params.targetReachedFunction
end

function PointTargetProjectile:Update()
    getbase(PointTargetProjectile).Update(self)

    local pos = self:GetPos()

    if (self.target - self:GetPos()):Length2D() <= self:GetRad() then
        if self.targetReachedFunction then
            self:targetReachedFunction()
        end

        self:Destroy()
    end
end

function PointTargetProjectile:GetNextPosition(pos)
    return pos + ((self.target - pos):Normalized() * (self:GetSpeed() / 30))
end

-- Projectile with unit target

HomingProjectile = HomingProjectile or class({}, nil, Projectile)

function HomingProjectile:constructor(round, params)
    self.heightOffset = params.heightOffset or 0
    params.to = params.target:GetPos() + Vector(0, 0, self.heightOffset)
    getbase(DistanceCappedProjectile).constructor(self, round, params)

    self.target = params.target
end

function HomingProjectile:GetNextPosition(pos)
    return pos + ((self.target:GetPos() + Vector(0, 0, self.heightOffset) - pos):Normalized() * (self:GetSpeed() / 30))
end