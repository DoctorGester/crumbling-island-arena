ProjectilePAA = ProjectilePAA or class({}, nil, Projectile)

function ProjectilePAA:constructor(round, hero, target, damage, ability)
	getbase(ProjectilePAA).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 100),
        to = target * Vector(1, 1, 0) + Vector(0, 0, 100),
        speed = 5000,
        graphics = hero:IsAwardEnabled() and "particles/pa_q/pa_q_elite.vpcf" or "particles/pa_q/pa_q.vpcf",
        damagesTrees = true,
        continueOnHit = true,
        disablePrediction = true,
        isPhysical = true,
        ability = ability,
        destroyOnDamage = false
    })

    self.initialVel = Vector(self.vel.x, self.vel.y)
    self.attraction = 0.05
    self.startTime = GameRules:GetGameTime()

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

            local silenceAbilitySource = hero:FindAbility("pa_r")

            if hero:HasModifier("modifier_pa_r") and target:AllowAbilityEffect(hero, silenceAbilitySource) then
                target:AddNewModifier(hero, silenceAbilitySource, "modifier_silence_lua", { duration = 0.75 })
                target:EmitSound("Arena.PA.HitR.Silence")
            end
        end
    end

    self.timesDeflected = 0
    self.lastTimeDeflected = -1

    self.modifierImmune = false
    self:AddComponent(HealthComponent())
    self:SetCustomHealth(3)
    self:SetupUnitHealth()
    self:SetHealth(self.hero:FindModifier("modifier_pa_a"):GetStackCount())
    self:GetUnit():SetUnitName("pa_a_projectile")
    self.modifierImmune = true
end

function ProjectilePAA:CollidesWith(target)
    return target == self.hero or self.owner.team ~= target.owner.team
end

function ProjectilePAA:SetHealth(amount)
    if amount > 0 then
        self:GetUnit():SetHealth(amount)
    end

    self.health = amount
end

function ProjectilePAA:Damage(source, amount)
    self.modifierImmune = false
    self:SetHealth(math.max(self.health - amount, 0))
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", { duration = 2.0 })
    self.hero:FindModifier("modifier_pa_a"):SetStackCount(self.health)
    self.modifierImmune = true

    if self.health == 0 then
        self:Destroy()
    end
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

function ProjectilePAA:Deflect(by, direction, optionalSound)
    if GameRules:GetGameTime() - self.lastTimeDeflected < 0.1 then
        return
    end

    self.timesDeflected = self.timesDeflected + 1
    if self.timesDeflected > 3 then
        local mode = GameRules:GetGameModeEntity()
        FX("particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_ABSORIGIN, mode, {
            cp0 = self:GetPos(),
            cp1 = self:GetPos(),
            release = true
        })

        FX("particles/msg_fx/msg_deny.vpcf", PATTACH_CUSTOMORIGIN, mode, {
            cp0 = self:GetPos(),
            cp3 = Vector(200, 0, 0),
            release = true
        })

        self:Destroy()
    end

    self.lastTimeDeflected = GameRules:GetGameTime()

    self:EmitSound(optionalSound or "Arena.PA.DeflectA")

    direction.z = 0
    self.vel = direction:Normalized() * math.max(1500, self.vel:Length2D())
    self.owner = by.owner
    self.startTime = GameRules:GetGameTime()
    self.attraction = 0.05
end

function ProjectilePAA:GetNextPosition(pos)
    local v = self.speed * ((self.hero:GetPos() - pos) * Vector(1, 1, 0)):Normalized()
    self.vel = 0.95 * self.vel + self.attraction * v

    if GameRules:GetGameTime() - self.startTime >= 2 then
        self.attraction = self.attraction + 0.01
    end

    return self.position + self.vel / 30 * self.currentMultiplier
end
