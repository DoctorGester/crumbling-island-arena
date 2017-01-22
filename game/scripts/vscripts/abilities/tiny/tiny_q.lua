tiny_q = class({})

LinkLuaModifier("modifier_tiny_q", "abilities/tiny/modifier_tiny_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiny_q_speed", "abilities/tiny/modifier_tiny_q_speed", LUA_MODIFIER_MOTION_NONE)

require('abilities/tiny/tiny_q_entity')

function tiny_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local stun = false
    local mod = hero:FindModifier("modifier_tiny_r")

    if mod and not mod.used then
        stun = true

        mod:Use()
    end

    TinyQ(hero.round, hero, self, target, stun, self:GetDamage(), self):Activate()
    hero:EmitSound("Arena.Tiny.CastQ")

    local speed = hero:FindModifier("modifier_tiny_q_speed")

    if speed then
        speed:SetStackCount(1)
    end
end

function tiny_q:GetIntrinsicModifierName()
    return "modifier_tiny_q_speed"
end

function tiny_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function tiny_q:GetPlaybackRateOverride()
    return 2
end