modifier_sniper_q = class({})

function modifier_sniper_q:IsAura()
    return true
end

function modifier_sniper_q:GetAuraRadius()
    return 400
end

function modifier_sniper_q:GetAuraDuration()
    return 0.1
end

function modifier_sniper_q:GetModifierAura()
    return "modifier_sniper_q_target"
end

function modifier_sniper_q:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_sniper_q:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end