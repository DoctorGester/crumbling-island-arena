sniper_q = class({})

LinkLuaModifier("modifier_sniper_q", "abilities/sniper/modifier_sniper_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sniper_q_target", "abilities/sniper/modifier_sniper_q_target", LUA_MODIFIER_MOTION_NONE)

require('abilities/sniper/sniper_shrapnel')

function sniper_q:GroundEffect(position, target, effect)
    local hero = self:GetCaster().hero
    local effect = ImmediateEffect(effect or "particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf", PATTACH_POINT, hero)
    ParticleManager:SetParticleControl(effect, 0, position)
    ParticleManager:SetParticleControl(effect, 1, target or position)
end

function sniper_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1800)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.Sniper.CastQ")

    FX("particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf", PATTACH_POINT_FOLLOW, hero, {
        cp0 = { ent = hero, point = "attach_attack1" },
        cp1 = target + Vector(0, 0, 2048)
    })

    SniperShrapnel(hero.round, hero, target, self):Activate()
end

function sniper_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function sniper_q:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(sniper_q)