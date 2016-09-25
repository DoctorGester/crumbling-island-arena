pudge_q = class({})

LinkLuaModifier("modifier_pudge_hook_self", "abilities/pudge/modifier_pudge_hook_self", LUA_MODIFIER_MOTION_NONE)

require("abilities/pudge/pudge_meat")
require("abilities/pudge/projectile_pudge_q")

function pudge_q:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    return true
end

function pudge_q:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
end

function pudge_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1300, 1300)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ProjectilePudgeQ(hero.round, hero, target, self):Activate()

    hero:AddNewModifier(hero, self, "modifier_pudge_hook_self", {})
    hero:EmitSound("Arena.Pudge.CastQ")
end

function pudge_q:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function pudge_q:GetPlaybackRateOverride()
    return 1.33
end