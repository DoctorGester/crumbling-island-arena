lc_q = class({})

LinkLuaModifier("modifier_lc_q", "abilities/lc/modifier_lc_q", LUA_MODIFIER_MOTION_NONE)

function lc_q:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.LC.CastQ")

    return true
end

function lc_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = hero:GetPos() + hero:GetFacing() * 200

    local effect = ImmediateEffect("particles/units/heroes/hero_centaur/centaur_warstomp.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, target)
    ParticleManager:SetParticleControl(effect, 1, Vector(600, 1, 1))

    hero:AreaEffect({
        filter = Filters.Area(target, 200),
        damage = true,
        modifier = { name = "modifier_lc_q", duration = 1.5, ability = self },
    })
    
    Spells:GroundDamage(target, 200)
    hero:EmitSound("Arena.LC.HitQ")
end

function lc_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end