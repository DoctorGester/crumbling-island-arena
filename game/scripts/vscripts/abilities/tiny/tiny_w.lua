tiny_w = class({})

require('abilities/tiny/tiny_w_entity')

function tiny_w:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.Tiny.CastW")
    return true
end

function tiny_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        target = hero:GetPos() + hero:GetFacing()
    end

    local height = 600
    local bounces = 0
    local mod = hero:FindModifier("modifier_tiny_r")

    if mod and not mod.used then
        bounces = 2
        height = 900

        mod:Use()
    end

    Spells:AddDynamicEntity(TinyW(hero, self, target, bounces, height))
end

function tiny_w:GetCastAnimation()
    return ACT_TINY_TOSS
end