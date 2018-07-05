earth_spirit_q = class({})

require('abilities/earth_spirit/earth_spirit_remnant')
LinkLuaModifier("modifier_earth_spirit_remnant", "abilities/earth_spirit/modifier_earth_spirit_remnant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_earth_spirit_stand", "abilities/earth_spirit/modifier_earth_spirit_stand", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_q:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    Wrappers.DirectionalAbility(self, hero:HasModifier("modifier_earth_spirit_stand") and 1400 or 700)

    local cursor = self:GetCursorPosition()
    local dir = self:GetDirection()

    EarthSpiritRemnant(hero, cursor + Vector(0, 0, 6000), dir, self):Activate();
    CreateEntityAOEMarker(cursor, 220, 0.7, { 34, 177, 76 }, 0.5, true)

    hero:EmitSound("Arena.Earth.CastQ.Voice")
end

function earth_spirit_q:GetCastPoint()
    return 0.1
end

function earth_spirit_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(earth_spirit_q)