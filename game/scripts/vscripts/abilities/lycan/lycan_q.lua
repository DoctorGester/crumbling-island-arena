lycan_q = class({})

LinkLuaModifier("modifier_lycan_q", "abilities/lycan/modifier_lycan_q", LUA_MODIFIER_MOTION_NONE)

require('abilities/lycan/lycan_wolf')

function lycan_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() < 500 then
        if direction:Length2D() == 0 then
            direction = hero:GetFacing()
        end

        target = hero:GetPos() + direction:Normalized() * 500
    end

    LycanWolf(hero.round, hero, target, 1):Activate()
    LycanWolf(hero.round, hero, target, -1):Activate()

    hero:EmitSound("Arena.Lycan.CastQ")
end

function lycan_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end