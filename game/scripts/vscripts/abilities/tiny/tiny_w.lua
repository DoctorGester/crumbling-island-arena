tiny_w = class({})

require('abilities/tiny/tiny_w_entity')

function tiny_w:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.Tiny.CastW")
    return true
end

function tiny_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local height = 600
    local bounces = 0
    local mod = hero:FindModifier("modifier_tiny_r")

    if mod and not mod.used then
        bounces = 2
        height = 900

        mod:Use()
    end

    TinyW(hero.round, hero, self, self:GetDamage(), target, bounces, height):Activate()
end

function tiny_w:GetCastAnimation()
    return ACT_TINY_TOSS
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tiny_w)