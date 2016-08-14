template_e = class({})
local self = template_e

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function self:GetPlaybackRateOverride()
    return 2
end