pugna_w = class({})
LinkLuaModifier("modifier_pugna_w", "abilities/pugna/modifier_pugna_w", LUA_MODIFIER_MOTION_NONE)

require("abilities/pugna/entity_pugna_w")

function pugna_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    EntityPugnaW(hero.round, hero, target):Activate()
    hero:EmitSound("Arena.Pugna.CastW")
end

function pugna_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end