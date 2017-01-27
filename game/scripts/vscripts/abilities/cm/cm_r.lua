cm_r = class({})
LinkLuaModifier("modifier_cm_r", "abilities/cm/modifier_cm_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cm_r_slow", "abilities/cm/modifier_cm_r_slow", LUA_MODIFIER_MOTION_NONE)

function cm_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local holder = CreateUnitByName(DUMMY_UNIT, target, false, hero.unit, hero.unit, hero.unit:GetTeam())
    holder:AddNewModifier(holder, self, "modifier_cm_r", { duration = 6 })
    holder:EmitSound("Arena.CM.CastR")
    holder:EmitSound("Arena.CM.LoopR")

    ImmediateEffectPoint("particles/econ/items/crystal_maiden/crystal_maiden_cowl_of_ice/maiden_crystal_nova_cowlofice.vpcf", PATTACH_CUSTOMORIGIN, hero, target)
end

function cm_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end
