lc_w = class({})

LinkLuaModifier("modifier_lc_w_shield", "abilities/lc/modifier_lc_w_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lc_w_speed", "abilities/lc/modifier_lc_w_speed", LUA_MODIFIER_MOTION_NONE)

function lc_w:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_lc_w_shield", { duration = 2 })
    hero:EmitSound("Arena.LC.CastW")
end

function lc_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end