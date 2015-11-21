sk_e = class({})

LinkLuaModifier("modifier_sk_e", "abilities/sk/modifier_sk_e", LUA_MODIFIER_MOTION_NONE)

function sk_e:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    local position = hero:GetPos()

    local effect = ImmediateEffect("particles/units/heroes/hero_sandking/sandking_burrowstrike_eruption.vpcf", PATTACH_POINT, hero)
    ParticleManager:SetParticleControl(effect, 0, position)
    ParticleManager:SetParticleControl(effect, 1, position)

    hero:EmitSound("Arena.SK.CastE")

    return true
end

function sk_e:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_sk_e", { duration = 4 })

    local effect = ImmediateEffect("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos())
end

function sk_e:GetCastAnimation()
    return ACT_DOTA_SAND_KING_BURROW_IN
end