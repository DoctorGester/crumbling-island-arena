ld_e = class({})

LinkLuaModifier("modifier_ld_bear", "abilities/ld/modifier_ld_bear", LUA_MODIFIER_MOTION_NONE)

require('abilities/ld/entity_ld_bear')

function ld_e:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()

    LDBear(hero.round, hero, self, hero:GetPos() + direction * 128, direction):Activate()
end

function ld_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function ld_e:GetPlaybackRateOverride()
    return 2
end