lycan_q = class({})

LinkLuaModifier("modifier_lycan_q", "abilities/lycan/modifier_lycan_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_instinct", "abilities/lycan/modifier_lycan_instinct", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lycan_bleed", "abilities/lycan/modifier_lycan_bleed", LUA_MODIFIER_MOTION_NONE)

require('abilities/lycan/lycan_wolf')

function lycan_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1600, 500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition() * Vector(1, 1, 0)

    LycanWolf(hero.round, hero, target, 1, self):Activate()
    LycanWolf(hero.round, hero, target, -1, self):Activate()

    hero:EmitSound("Arena.Lycan.CastQ")
    hero:EmitSound("Arena.Lycan.CastQ.Voice")
end

function lycan_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function lycan_q:GetIntrinsicModifierName()
    return "modifier_lycan_instinct"
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(lycan_q)