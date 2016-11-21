invoker_a = class({})

function invoker_a:OnAbilityPhaseStart()
    self:GetCaster():GetParentEntity():EmitSound("Arena.Invoker.PreA")

    return true
end

function invoker_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local p = DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        damage = self:GetDamage(),
        speed = 1250,
        radius = 48,
        graphics = "particles/invoker_a/invoker_a.vpcf",
        distance = 800,
        hitSound = "Arena.Invoker.HitA",
        isPhysical = true
    }):Activate()

    ParticleManager:SetParticleControl(p.particle, 9, hero:GetPos() + Vector(0, 0, 64))

    hero:EmitSound("Arena.Invoker.CastA")
end

function invoker_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function invoker_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(invoker_a)