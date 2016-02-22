pugna_w = class({})
LinkLuaModifier("modifier_pugna_w", "abilities/pugna/modifier_pugna_w", LUA_MODIFIER_MOTION_NONE)

function pugna_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local trap = CreateUnitByName(DUMMY_UNIT, target, false, nil, nil, hero.unit:GetTeamNumber())
    trap:AddNewModifier(hero.unit, self, "modifier_pugna_w", {})
    table.insert(hero.traps, trap)
    --hero:EmitSound("Arena.Sniper.CastW")
end

function pugna_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end