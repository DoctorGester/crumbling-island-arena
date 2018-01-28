ProjectileStormW = ProjectileStormW or class({}, nil, DistanceCappedProjectile)

function ProjectileStormW:constructor(round, hero, target, ability)
    getbase(ProjectileStormW).constructor(self, round, {
        ability = ability,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1300,
        distance = 600,
        graphics = hero:GetMappedParticle("particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf"),
        disablePrediction = true,
        hitFunction = function(projectile, victim)
            projectile.hitSomething = true
            victim.round.spells:InterruptDashes(victim)
            DashStormW(hero, victim, ability, projectile.particle)
        end
    })
end

function ProjectileStormW:SetGraphics(path)
    if path ~= nil or not self.hitSomething then
        getbase(ProjectileStormW).SetGraphics(self, path)
    end

    if path ~= nil then
        local u = self.hero:GetUnit()
        ParticleManager:SetParticleControlEnt(self.particle, 0, u, PATTACH_POINT_FOLLOW, "attach_attack1", u:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetUnit(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetPos(), true)
    end
end

DashStormW = DashStormW or class({}, nil, Dash)

function DashStormW:constructor(hero, target, ability, particle)
    getbase(DashStormW).constructor(self, target, nil, 300, {
        modifier = { name = "modifier_knockback_lua", ability = ability, source = ability:GetCaster() },
        interruptedByStuns = false,
        loopingSound = "Arena.Storm.HitW"
    })

    self.caster = hero
    self.particle = particle
    self.startTime = GameRules:GetGameTime()

    target:AddKnockbackSource(hero)

    ParticleManager:SetParticleControlEnt(self.particle, 1, target:GetUnit(), PATTACH_ABSORIGIN_FOLLOW, nil, target:GetPos(), true)
end

function DashStormW:PositionFunction(current)
    local diff = self.caster:GetPos() - current

    if diff:Length2D() < 128 then
        return current
    end

    return current + (diff:Normalized() * self.velocity)
end

function DashStormW:HasEnded()
    return not self.hero:Alive() or GameRules:GetGameTime() - self.startTime > 1.0
end

function DashStormW:End(...)
    getbase(DashStormW).End(self, ...)

    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
end