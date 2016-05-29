jugger_w = class({})

LinkLuaModifier("modifier_jugger_w", "abilities/jugger/modifier_jugger_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jugger_w_target", "abilities/jugger/modifier_jugger_w_target", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_jugger_w_visual", "abilities/jugger/modifier_jugger_w_visual", LUA_MODIFIER_MOTION_NONE)

require('abilities/jugger/jugger_ward')

function jugger_w:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    JuggerWard(hero.round, hero, target, self):Activate()
end

function jugger_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end