tiny_q = class({})

LinkLuaModifier("modifier_tiny_q", "abilities/tiny/modifier_tiny_q", LUA_MODIFIER_MOTION_NONE)

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

    hero.round.spells:AddDynamicEntity(TinyQ(hero, self, target, stun))
    hero:EmitSound("Arena.Tiny.CastQ")
end

function tiny_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end