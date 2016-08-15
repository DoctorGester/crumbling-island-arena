ArcProjectile = ArcProjectile or class({}, nil, UnitEntity)

function ArcProjectile:constructor(round, params)
    getbase(Projectile).constructor(self, round, DUMMY_UNIT, params.from)

    self.collisionType = COLLISION_TYPE_NONE
    self.modifierImmune = true
    self.hero = params.owner
    self.owner = self.hero.owner
    self.from = params.from
    self.to = params.to
    self.vel = (self.to - self.from):Normalized()
    self.radius = params.radius or 16
    self.arc = params.arc
    self.removeOnDeath = false

    if self.vel:Length2D() == 0 then
        self.vel = self.hero:GetFacing()
    end

    self.arc = self.arc * math.min((self.to - self.from):Length2D() / 900, 1.0)

    self.currentMultiplier = 1.0

    self:GetUnit():SetNeverMoveToClearSpace(true)
    self:SetFacing(self.to - self.from)
    self:SetGraphics(params.graphics)

    self.hitParams = params.hitParams
    self.destroyFunction = params.destroyFunction
    self.disablePrediction = true
    self.invulnerable = true

    self.hitSound = params.hitSound
    self.hitScreenShake = params.hitScreenShake
    self.hitFunction = params.hitFunction
    self.loopingSound = params.loopingSound

    if self.loopingSound then
        self:EmitSound(self.loopingSound)
    end

    self:SetSpeed(params.speed or 600)
    self:SetPos(self.from)

    if not params.disableStats then
        self.hero.round.statistics:IncreaseProjectilesFired(self.owner)
    end
end

function ArcProjectile:CanFall()
    return false
end

function ArcProjectile:GetRad()
    return self.radius
end

function ArcProjectile:SetPos(pos)
    self.position = pos

    if self.disablePrediction then
        self:GetUnit():SetAbsOrigin(pos)
    else
        self:GetUnit():SetAbsOrigin(self:GetNextPosition(self:GetNextPosition(pos)))
    end
end

function ArcProjectile:FindClearSpace(position, force)
    self.position = position

    self:GetUnit():SetNeverMoveToClearSpace(false)
    FindClearSpaceForUnit(self.unit, position, force)
    self:GetUnit():SetNeverMoveToClearSpace(true)
end

function ArcProjectile:Update()
    local prevFallingPos = self:GetPos()

    getbase(Projectile).Update(self)

    if self.falling then
        self:SetPos(self:GetPos() + self.fallingDirection)
        self:SetFacing(self:GetPos() - prevFallingPos)
        return
    end

    local pos = self:GetPos()

    if IsOutOfTheMap(pos) then
        self:Destroy()
        return
    end
    
    local prevPos = self:GetPos()

    self:SetPos(self:GetNextPosition(pos))

    local initialD = (self.to - prevPos):Length2D() -- Multi-projectile drifting
    local resultD = (self.to - self:GetPos()):Length2D()

    if (self.to - self:GetPos()):Length() <= self:GetSpeed() / 30 or resultD >= initialD then
        if not self:TestFalling() then
            self.falling = true
            self.fallingDirection = self:GetPos() - prevPos
            return
        end

        self:TargetReached()
        self:Destroy()
    end
end

function ArcProjectile:TargetReached()
    local hit = false

    if self.hitSound then
        self:EmitSound(self.hitSound)
    end
    
    if self.hitParams then
        hit = self.hero:AreaEffect(self.hitParams)
    end

    if self.hitFunction then
        self:hitFunction(hit)
    end

    if self.hitScreenShake then
        ScreenShake(self:GetPos(), 5, 150, 0.25, 2000, 0, true)
    end
end

function ArcProjectile:GetNextPosition(pos)
    local result = pos + ((self.to - pos):Normalized() * (self:GetSpeed() / 30))
    local d = (self.from - self.to):Length2D()
    local x = (self.from - result):Length2D()

    result.z = ParabolaZ2(self.from.z, self.to.z, self.arc, d, x)

    self:SetFacing(result - pos)

    return result
end

function ArcProjectile:GetSpeed()
    local multiplier = 1

    for _, modifier in pairs(self:AllModifiers()) do
        if modifier.GetProjectileSpeedModifier then
            multiplier = multiplier * modifier:GetProjectileSpeedModifier()
        end
    end

    if self.currentMultiplier < multiplier then
        self.currentMultiplier = math.min(self.currentMultiplier + 0.05, multiplier)
    else
        self.currentMultiplier = math.max(self.currentMultiplier - 0.05, multiplier)
    end

    return self.speed * self.currentMultiplier
end

function ArcProjectile:SetSpeed(speed)
    self.speed = speed
end

function ArcProjectile:SetGraphics(graphics)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    if graphics then
        self.particle = ParticleManager:CreateParticle(graphics, PATTACH_ABSORIGIN_FOLLOW , self:GetUnit())
    end
end

function ArcProjectile:Remove()
    if self.loopingSound then
        self:StopSound(self.loopingSound)
    end

    if self.particle then
        self:SetGraphics(nil)
    end

    if self.falling then
        GridNav:DestroyTreesAroundPoint(self:GetPos(), 256, false)
        Level.KillCreepsInRadius(self:GetPos(), 512)
    end

    getbase(Projectile).Remove(self)
end