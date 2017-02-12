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
    self.removeOnDeath = false

    if self.vel:Length2D() == 0 then
        self.vel = self.hero:GetFacing()
    end

    self.currentMultiplier = 1.0

    self:GetUnit():SetNeverMoveToClearSpace(true)
    self:SetFacing(self.vel)
    self:SetGraphics(params.graphics)

    self.hitModifier = params.hitModifier -- { name, duration, ability }
    self.hitSound = params.hitSound
    self.hitFunction = params.hitFunction
    self.hitCondition = params.hitCondition
    self.nonBlockedHitAction = params.nonBlockedHitAction
    self.destroyFunction = params.destroyFunction
    self.continueOnHit = params.continueOnHit or false
    self.gracePeriod = params.gracePeriod or 30
    self.hitGroup = {}
    self.disablePrediction = params.disablePrediction or false
    self.destroyOnDamage = params.destroyOnDamage
    self.invulnerable = params.invulnerable or false
    self.damage = params.damage
    self.isPhysical = params.isPhysical
    self.screenShake = params.screenShake
    self.hitProjectiles = params.hitProjectiles
    self.considersGround = params.considersGround
    self.ability = params.ability

    if self.destroyOnDamage == nil then
       self.destroyOnDamage = true 
    end

    self:SetSpeed(params.speed or 600)
    self:SetPos(self.from)

    self.hero.round.statistics:IncreaseProjectilesFired(self.owner)

    self.isNew = 2
end

function Projectile:CanFall()
    return self.considersGround
end

function Projectile:MakeFall()
    self:Destroy()
end

function Projectile:GetRad()
    return self.radius
end

function Projectile:SetPos(pos)
    self.position = pos

    if self.disablePrediction then
        self:GetUnit():SetAbsOrigin(pos)
    else
        self:GetUnit():SetAbsOrigin(self:GetNextPosition(self:GetNextPosition(pos)))
    end
end

function Projectile:FindClearSpace(position, force)
    self.position = position

    self:GetUnit():SetNeverMoveToClearSpace(false)
    FindClearSpaceForUnit(self.unit, position, force)
    self:GetUnit():SetNeverMoveToClearSpace(true)
end

function Projectile:Deflect(by, direction)
    direction.z = 0
    self.vel = direction:Normalized()
    self.owner = by.owner

    self:SetFacing(self.vel)
end

function Projectile:Update()
    getbase(Projectile).Update(self)

    if self.falling then
        return
    end

    local multiplier = 1

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.GetProjectileSpeedModifier then
            multiplier = multiplier * modifier:GetProjectileSpeedModifier()
        end
    end

    if self.currentMultiplier < multiplier then
        self.currentMultiplier = math.min(self.currentMultiplier + 0.15, multiplier)
    else
        self.currentMultiplier = math.max(self.currentMultiplier - 0.15, multiplier)
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

    self.isNew = self.isNew - 1
end

function Projectile:CollidesWith(target)
    if self.hitCondition then
        return self:hitCondition(target)
    end

    local areEnemies = (self.owner.team ~= target.owner.team or target.specialAlly)

    if instanceof(target, Projectile) then
        return ((IsAttackAbility(self.ability) and IsAttackAbility(target.ability)) or (self.hitProjectiles or target.hitProjectiles)) and areEnemies
    else
        return areEnemies
    end
end

function Projectile:CollideWith(target)
    if self.hitGroup[target] and self.hitGroup[target] > 0 then
        return
    end

    local invulnerableTarget = target:IsInvulnerable()

    local blocked = self.ability and target:AllowAbilityEffect(self, self.ability) == false

    if not blocked then
        if self.hitFunction then
            self:hitFunction(target)
        elseif self.damage ~= nil then
            target:Damage(self, self.damage, self.isPhysical)
        end

        if self.hitModifier then
            target:AddNewModifier(self.hero, self.hitModifier.ability, self.hitModifier.name, { duration = self.hitModifier.duration })
        end
    end

    if self.nonBlockedHitAction then
        self:nonBlockedHitAction(target, blocked)
    end

    if self.hitSound then
        target:EmitSound(self.hitSound)
    end

    if self.screenShake then
        ScreenShake(self:GetPos(), unpack(self.screenShake))
    end

    if self.continueOnHit then
        self.hitGroup[target] = self.gracePeriod
    elseif not instanceof(target, Projectile) and not invulnerableTarget then
        self:Destroy()
    end
end

function Projectile:GetNextPosition(pos)
    return pos + (self.vel * (self:GetSpeed() / 30))
end

function Projectile:Damage(source)
    if not self.destroyOnDamage then
        return
    end

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
    return self.speed * self.currentMultiplier
end

function Projectile:SetSpeed(speed)
    self.speed = speed
end

function Projectile:SetGraphics(graphics)
    if self.particle then
        local p = self.particle
        local function cleaner()
            ParticleManager:DestroyParticle(p, false)
            ParticleManager:ReleaseParticleIndex(p)
        end

        if self.isNew > 0 then
            Timers:CreateTimer(cleaner)
        else
            cleaner()
        end
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
        self:SetGraphics(nil)
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
    self.target = params.target or params.to
    self.targetReachedFunction = params.targetReachedFunction
    self.parabola = params.parabola

    getbase(DistanceCappedProjectile).constructor(self, round, params)
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

function PointTargetProjectile:Deflect(by, direction)
    direction.z = 0

    local len = (self.target - self:GetPos()):Length2D()
    self.target = self:GetPos() + direction:Normalized() * len
    self.owner = by.owner

    self:SetFacing(direction)
end

function PointTargetProjectile:GetNextPosition(pos)
    local result = pos + ((self.target - pos):Normalized() * (self:GetSpeed() / 30))

    if self.parabola then
        local d = (self.from - self.to):Length2D()
        local x = (self.from - result):Length2D()
        result.z = ParabolaZ(self.parabola, d, x)

        self:SetFacing(result - pos)
    end

    return result
end

-- Projectile with unit target

HomingProjectile = HomingProjectile or class({}, nil, Projectile)

function HomingProjectile:constructor(round, params)
    self.heightOffset = params.heightOffset or 0
    params.to = params.target:GetPos() + Vector(0, 0, self.heightOffset)
    self.target = params.target

    getbase(DistanceCappedProjectile).constructor(self, round, params)
end

function HomingProjectile:Update()
    getbase(HomingProjectile).Update(self)

    if not self.target:Alive() then
        self:Destroy()
    end
end

function HomingProjectile:GetNextPosition(pos)
    return pos + ((self.target:GetPos() + Vector(0, 0, self.heightOffset) - pos):Normalized() * (self:GetSpeed() / 30))
end