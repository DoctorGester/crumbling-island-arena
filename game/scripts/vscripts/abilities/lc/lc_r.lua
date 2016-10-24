lc_r = class({})

LinkLuaModifier("modifier_lc_r", "abilities/lc/modifier_lc_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lc_r_aura", "abilities/lc/modifier_lc_r_aura", LUA_MODIFIER_MOTION_NONE)

function lc_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local holder = CreateUnitByName(DUMMY_UNIT, target, false, hero.unit, hero.unit, hero.unit:GetTeam())
    holder:AddNewModifier(hero:GetUnit(), self, "modifier_lc_r_aura", { duration = 5 })

    hero:EmitSound("Arena.LC.CastR.Voice")
end

function lc_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function lc_r:GetPlaybackRateOverride()
    return 2
end