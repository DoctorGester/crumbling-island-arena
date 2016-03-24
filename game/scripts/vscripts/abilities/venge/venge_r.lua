venge_r = class({})

LinkLuaModifier("modifier_venge_r", "abilities/venge/modifier_venge_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_r_target", "abilities/venge/modifier_venge_r_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_r_visual", "abilities/venge/modifier_venge_r_visual", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_r_animation", "abilities/venge/modifier_venge_r_animation", LUA_MODIFIER_MOTION_NONE)

require('abilities/venge/venge_vengeance')

function venge_r:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_venge_r_animation", {})

    return true
end

function venge_r:OnAbilityPhaseInterrupted()
    local hero = self:GetCaster().hero
    hero:RemoveModifier("modifier_venge_r_animation")
end

function venge_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = (target - hero:GetPos()):Normalized()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    hero:RemoveModifier("modifier_venge_r_animation")
    hero:EmitSound("Arena.Venge.CastR")
    
    Vengeance(hero.round, hero, target, direction, self):Activate()
end

function venge_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end