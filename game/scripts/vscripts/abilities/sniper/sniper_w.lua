sniper_w = class({})

function sniper_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local trap = CreateUnitByName("npc_dota_techies_stasis_trap", target, false, nil, nil, hero.unit:GetTeamNumber())
end

function sniper_w:GetCastAnimation()
    return ACT_DOTA_TELEPORT
end