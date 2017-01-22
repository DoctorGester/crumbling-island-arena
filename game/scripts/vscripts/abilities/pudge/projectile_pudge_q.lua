ProjectilePudgeQ = ProjectilePudgeQ or class({}, nil, Projectile)

function ProjectilePudgeQ:constructor(round, hero, target, ability)
	getbase(ProjectilePudgeQ).constructor(self, round, {
        ability = ability,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1600,
        graphics = hero:GetMappedParticle("particles/pudge_q/pudge_q.vpcf"),
        destroyFunction = function(projectile)
            if projectile.hitSomething then
                projectile:RetractHook()
            else
                ParticleManager:DestroyParticle(projectile.particle, true)
                ParticleManager:ReleaseParticleIndex(projectile.particle)

                projectile.hero:RemoveModifier("modifier_pudge_hook_self")
                projectile.hero:StopSound("Arena.Pudge.CastQ")
                projectile.hero:EmitSound("Arena.Pudge.EndQ")
                projectile.hero:EmitSound("Arena.Pudge.MissQ.Voice")

                if projectile.hero:Alive() then
                    projectile.hero:GetUnit():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
                end
            end
        end,
        disablePrediction = true
    })

    hero:GetWearableBySlot("weapon"):AddEffects(EF_NODRAW)

    self.ability = ability
    self.hitSomething = false
    self.goingBack = false
    self.distance = 1300
    self.distancePassed = 0
end

function ProjectilePudgeQ:CollideWith(target)
    local ally = target.owner.team == self.hero.owner.team
    local blocked = target:AllowAbilityEffect(self, self.ability) == false

    if blocked then
        if not self.goingBack then
            self:RetractHook()
        end

        self.goingBack = true
        return
    end

    if not ally then
        target:Damage(self, self.ability:GetDamage())
    end

    if not instanceof(target, Projectile) then
        self.hitSomething = true

        target.round.spells:InterruptDashes(target)
        DashPudgeQ(self.hero, target, self.ability, self.particle)

        target:EmitSound("Arena.Pudge.HitQ")

        if instanceof(target, Hero) and not ally then
            local blood = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW , target:GetUnit())
            ParticleManager:SetParticleControlEnt(blood, 0, target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)

            ParticleManager:DestroyParticle(blood, false)
            ParticleManager:ReleaseParticleIndex(blood)

            target:EmitSound("Arena.Pudge.HitQ.Voice")

            if target:HasModifier("modifier_pudge_a") then
                PudgeMeat(self.round, self.hero, target:GetPos()):Activate()
            end
        end

        self:Destroy()
    end
end

function ProjectilePudgeQ:CollidesWith(source)
    return source ~= self.hero and not instanceof(source, Projectile)
end

function ProjectilePudgeQ:SetGraphics(graphics)
    if graphics then
        self.particle = ParticleManager:CreateParticle(graphics, PATTACH_ABSORIGIN_FOLLOW , self.hero:GetUnit())

        ParticleManager:SetParticleControlEnt(self.particle, 0, self.hero:GetUnit(), PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", self.hero:GetPos(), true)
        ParticleManager:SetParticleControlEnt(self.particle, 3, self:GetUnit(), PATTACH_POINT_FOLLOW, nil, self:GetPos(), true)
    elseif not self.hitSomething then
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)

        self.hero:StopSound("Arena.Pudge.CastQ")
        self.hero:EmitSound("Arena.Pudge.EndQ")
    end
end

function ProjectilePudgeQ:RetractHook()
    self.hero:RemoveModifier("modifier_pudge_hook_self")

    if self.hero:Alive() then
        self.hero:GetUnit():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
        self.hero:GetUnit():StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
    end
end

function ProjectilePudgeQ:Update()
    local prev = self:GetPos()
    getbase(ProjectilePudgeQ).Update(self)
    local pos = self:GetPos()

    if not self.goingBack then
        if self.distance <= self.distancePassed then
            self.goingBack = true

            self:RetractHook()
        end

        self.distancePassed = self.distancePassed + (prev - pos):Length2D()
    else
        if (self.hero:GetPos() - self:GetPos()):Length2D() <= self:GetRad() then
            self:Destroy()
        end
    end
end

function ProjectilePudgeQ:GetNextPosition(pos)
    if not self.goingBack then
        return getbase(ProjectilePudgeQ).GetNextPosition(self, pos)
    else
        return pos + ((self.hero:GetPos() - pos):Normalized() * (self:GetSpeed() / 30))
    end
end

function ProjectilePudgeQ:Remove()
    getbase(ProjectilePudgeQ).Remove(self)

    if not self.hitSomething then
        self.hero:GetWearableBySlot("weapon"):RemoveEffects(EF_NODRAW)
    end
end

DashPudgeQ = DashPudgeQ or class({}, nil, Dash)

function DashPudgeQ:constructor(hero, target, ability, particle)
    getbase(DashPudgeQ).constructor(self, target, nil, 1600, {
        modifier = { name = "modifier_knockback_lua", ability = ability, source = ability:GetCaster() },
        heightFunction = heightFunction,
        interruptedByStuns = false
    })

    self.pudge = hero
    self.particle = particle

    ParticleManager:SetParticleControlEnt(self.particle, 3, target:GetUnit(), PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetPos(), true)
end

function DashPudgeQ:PositionFunction(current)
    local diff = self.pudge:GetPos() - current
    return current + (diff:Normalized() * self.velocity)
end

function DashPudgeQ:HasEnded()
    return not self.hero:Alive() or (self.pudge:GetPos() - self.hero:GetPos()):Length2D() <= self.velocity * 3
end

function DashPudgeQ:End(...)
    getbase(DashPudgeQ).End(self, ...)

    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)

    self.pudge:StopSound("Arena.Pudge.CastQ")
    self.pudge:EmitSound("Arena.Pudge.EndQ")
    self.pudge:GetWearableBySlot("weapon"):RemoveEffects(EF_NODRAW)
end