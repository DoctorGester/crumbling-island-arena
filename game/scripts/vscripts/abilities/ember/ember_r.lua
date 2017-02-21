ember_r = class({})

LinkLuaModifier("modifier_ember_r", "abilities/ember/modifier_ember_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ember_r_visual", "abilities/ember/modifier_ember_r_visual", LUA_MODIFIER_MOTION_NONE)

require('abilities/ember/ember_remnant')

function ember_r:OnSpellStart()
    Wrappers.DirectionalAbility(self, 600)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.Ember.CastR")
    EmberRemnant(hero.round, hero, target, self):Activate()
end

function ember_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function ember_r:GetPlaybackRateOverride()
    return 1.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ember_r)