am_w = class({})
local self = am_w

LinkLuaModifier("modifier_am_w", "abilities/am/modifier_am_w", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_am_w", { duration = 1 })
    hero:EmitSound("Arena.AM.CastW")
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end