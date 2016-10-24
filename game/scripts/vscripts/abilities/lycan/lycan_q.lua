lycan_q = class({})

LinkLuaModifier("modifier_lycan_q", "abilities/lycan/modifier_lycan_q", LUA_MODIFIER_MOTION_NONE)

require('abilities/lycan/lycan_wolf')

function lycan_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition() * Vector(1, 1, 0)
    local direction = self:GetDirection()

    if direction:Length2D() < 500 then
        target = hero:GetPos() + direction:Normalized() * 500
    end

    LycanWolf(hero.round, hero, target, 1):Activate()
    LycanWolf(hero.round, hero, target, -1):Activate()

    hero:EmitSound("Arena.Lycan.CastQ")
    hero:EmitSound("Arena.Lycan.CastQ.Voice")
end

function lycan_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end