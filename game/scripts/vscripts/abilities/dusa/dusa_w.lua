dusa_w = class({})
local self = dusa_w

LinkLuaModifier("modifier_dusa_mana", "abilities/dusa/modifier_dusa_mana", LUA_MODIFIER_MOTION_NONE)

require("abilities/dusa/projectile_dusa_w")

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ProjectileDusaW(hero.round, hero, target):Activate()

    hero:EmitSound("Arena.Medusa.CastW")
    hero:EmitSound("Arena.Medusa.CastW.Voice")
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function self:GetPlaybackRateOverride()
    return 1.66
end

function self:GetIntrinsicModifierName()
    return "modifier_dusa_mana"
end