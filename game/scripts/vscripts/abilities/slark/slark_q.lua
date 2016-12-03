slark_q = class({})

LinkLuaModifier("modifier_slark_q", "abilities/slark/modifier_slark_q", LUA_MODIFIER_MOTION_NONE)

function slark_q:OnAbilityPhaseStart()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    self:GetCaster():EmitSound("Arena.Slark.PreA")

    return true
end

function slark_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        damage = self:GetDamage(),
        speed = 1650,
        graphics = "particles/slark_q/slark_q.vpcf",
        distance = 900,
        hitModifier = { name = "modifier_slark_q", duration = 1.0, ability = self },
        hitSound = "Arena.Slark.HitE"
    }):Activate()
end

function slark_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function slark_q:GetPlaybackRateOverride()
    return 2
end