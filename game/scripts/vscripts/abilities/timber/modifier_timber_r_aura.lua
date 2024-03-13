modifier_timber_r_aura = class({})
local self = modifier_timber_r_aura

function self:IsAura()
    return true
end

function self:GetAuraRadius()
    return 400
end

function self:GetAuraDuration()
    return 0.1
end

function self:GetModifierAura()
    return "modifier_timber_r_target"
end

function self:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function self:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end