venge_r = class({})

LinkLuaModifier("modifier_venge_r", "abilities/venge/modifier_venge_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_venge_r_target", "abilities/venge/modifier_venge_r_target", LUA_MODIFIER_MOTION_NONE)
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
    Spells:AddDynamicEntity(Vengeance(hero, target, direction, self))

    --local holder = CreateUnitByName(DUMMY_UNIT, target, false, hero.unit, hero.unit, hero.unit:GetTeam())
    --holder:AddNewModifier(holder, self, "modifier_cm_r", { duration = 6 })
    --holder:EmitSound("Arena.CM.CastR")
    --holder:EmitSound("Arena.CM.LoopR")

    --ImmediateEffectPoint("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_CUSTOMORIGIN, hero, target)
end

function venge_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end