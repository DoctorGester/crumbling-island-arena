ta_e = class({})

LinkLuaModifier("modifier_ta_e", "abilities/ta/modifier_ta_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_e_counter", "abilities/ta/modifier_ta_e_counter", LUA_MODIFIER_MOTION_NONE)

function ta_e:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.TA.CastE")
    return true
end

function ta_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 400)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ImmediateEffectPoint("particles/econ/events/ti4/blink_dagger_start_ti4.vpcf", PATTACH_ABSORIGIN, hero, hero:GetPos() + Vector(0, 0, 32))

    GridNav:DestroyTreesAroundPoint(target, 128, true)
    hero:FindClearSpace(target, true)

    ImmediateEffectPoint("particles/econ/events/ti4/blink_dagger_end_ti4.vpcf", PATTACH_ABSORIGIN, hero, hero:GetPos() + Vector(0, 0, 32))

    StartAnimation(self:GetCaster(), { duration = 0.3, activity = ACT_DOTA_ATTACK, rate = 2, translate = "meld" })
    hero:EmitSound("Arena.TA.EndE")
end

function ta_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function ta_e:GetPlaybackRateOverride()
    return 2
end

function ta_e:GetIntrinsicModifierName()
    return "modifier_ta_e"
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ta_e)