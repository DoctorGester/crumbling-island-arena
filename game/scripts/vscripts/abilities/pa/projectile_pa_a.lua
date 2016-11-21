ProjectilePAA = ProjectilePAA or class({}, nil, Projectile)

function ProjectilePAA:constructor(round, hero, target, damage)
	getbase(ProjectilePAA).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 100),
        to = target * Vector(1, 1, 0) + Vector(0, 0, 100),
        speed = 5000,
        graphics = "particles/pa_q/pa_q.vpcf",
        continueOnHit = true,
        disablePrediction = true,
        isPhysical = true
    })

    self.initialVel = Vector(self.vel.x, self.vel.y)
    self.attraction = 0.05
    self.startTime = GameRules:GetGameTime()

    self.state = ProjectilePAA.STATE_NORMAL
    self.vel = self.vel * self:GetSpeed()
    self.hitGroup[hero] = self.gracePeriod
    self.hitFunction = function(self, target)
        if target == self.hero then
            self.hero:WeaponRetrieved()
            target:EmitSound("Arena.PA.Catch")
            self:Destroy()
        else
            target:EmitSound("Arena.PA.HitQ")
            target:Damage(self, damage, self.isPhysical)

            local direction = (target:GetPos() - self:GetPos()):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(blood, 0, target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)
            ParticleManager:SetParticleControlForward(blood, 0, direction)
            ParticleManager:SetParticleControl(blood, 2, direction * 1000)
        end
    end
end

function ProjectilePAA:CollidesWith(target)
    return target == self.hero or self.owner.team ~= target.owner.team
end

function ProjectilePAA:Update()
	getbase(ProjectilePAA).Update(self)

    if self.vel:Normalized():Dot(self.initialVel) < 0 then
        self.initialVel = self.vel:Normalized()
        self.hitGroup = {}
    end

    if not self.hero:Alive() or self.hero.falling then
        self:Destroy()
    end
end

function ProjectilePAA:Remove()
    self.hero:WeaponDestroyed()

    getbase(ProjectilePAA).Remove(self)
end

function ProjectilePAA:GetNextPosition(pos)
    local v = self.speed * ((self.hero:GetPos() - pos) * Vector(1, 1, 0)):Normalized()
    self.vel = 0.95 * self.vel + self.attraction * v

    if GameRules:GetGameTime() - self.startTime >= 2 then
        self.attraction = self.attraction + 0.01
    end

    return self.position + self.vel * self.hero:GetSpeedMultiplier() / 30 * self.currentMultiplier
end