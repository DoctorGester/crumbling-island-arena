sniper_w = class({})
LinkLuaModifier("modifier_sniper_w", "abilities/sniper/modifier_sniper_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sniper_w_trap", "abilities/sniper/modifier_sniper_w_trap", LUA_MODIFIER_MOTION_NONE)

function sniper_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local trap = CreateUnitByName("npc_dota_techies_stasis_trap", target, false, nil, nil, hero.unit:GetTeamNumber())
    trap:AddNewModifier(hero.unit, self, "modifier_sniper_w_trap", {})
    table.insert(hero.traps, trap)
end

function sniper_w:GetCastAnimation()
    return ACT_DOTA_TELEPORT
end