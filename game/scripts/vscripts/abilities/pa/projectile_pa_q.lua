ProjectilePAQ = ProjectilePAQ or class({}, nil, Projectile)

ProjectilePAQ.STATE_NORMAL = 0
ProjectilePAQ.STATE_GOING_BACK = 1
ProjectilePAQ.STATE_ON_THE_GROUND = 2

function ProjectilePAQ:constructor(round, hero, target)
	getbase(ProjectilePAQ).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 100),
        to = target * Vector(1, 1, 0) + Vector(0, 0, 100),
        speed = 1300,
        graphics = "particles/pa_q/pa_q.vpcf",
        continueOnHit = true,
        disablePrediction = true
    })

    self.state = ProjectilePAQ.STATE_NORMAL
    self.vel = self.vel * self:GetSpeed()
    self.hitGroup[hero] = self.gracePeriod
    self.hitFunction = function(self, target)
        if target == self.hero then
            self.hero:WeaponRetrieved()
            target:EmitSound("Arena.PA.Catch")
            self:Destroy()
        else
            target:EmitSound("DOTA_Item.BattleFury")
            target:Damage(self)

            local direction = (target:GetPos() - self:GetPos()):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            ParticleManager:SetParticleControlEnt(blood, 0, target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)
            ParticleManager:SetParticleControlForward(blood, 0, direction)
            ParticleManager:SetParticleControl(blood, 2, direction * 1000)
        end
    end
end

function ProjectilePAQ:CanFall()
    return self.state == ProjectilePAQ.STATE_ON_THE_GROUND
end

function ProjectilePAQ:MakeFall()
    getbase(ProjectilePAQ).MakeFall(self)

    self.hero:WeaponDestroyed()
end

function ProjectilePAQ:CollidesWith(target)
    if self.state == ProjectilePAQ.STATE_ON_THE_GROUND then
        return target == self.hero
    end

    return target == self.hero or self.owner.team ~= target.owner.team
end

function ProjectilePAQ:Update()
	getbase(ProjectilePAQ).Update(self)

    if not self.hero:Alive() or self.hero.falling then
        self:Destroy()
    end
end

function ProjectilePAQ:Return()
    self.state = ProjectilePAQ.STATE_GOING_BACK
end

function ProjectilePAQ:Remove()
    self.hero:WeaponDestroyed()

    getbase(ProjectilePAQ).Remove(self)
end

function ProjectilePAQ:GetNextPosition(pos)
    local dif = ((self.hero:GetPos() - pos) * Vector(1, 1, 0)):Normalized()

    if self.state == ProjectilePAQ.STATE_NORMAL then
        self.vel = self.vel + dif * 32

        return self.position + self.vel * self.hero:GetSpeedMultiplier() / 30
    elseif self.state == ProjectilePAQ.STATE_GOING_BACK then
        dif = dif * self:GetSpeed()

        return self.position + dif * self.hero:GetSpeedMultiplier(self) / 30
    end
end