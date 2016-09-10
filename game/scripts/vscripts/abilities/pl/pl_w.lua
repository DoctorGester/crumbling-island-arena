pl_w = class({})
local self = pl_w

LinkLuaModifier("modifier_pl_w", "abilities/pl/modifier_pl_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pl_w_invul", "abilities/pl/modifier_pl_w_invul", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:AddNewModifier(hero, self, "modifier_pl_w", { duration = 1.4 })
    hero:GetUnit():Interrupt()

    hero:EmitSound("Arena.PL.CastW")
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end