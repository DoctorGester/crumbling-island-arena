template_q = class({})
local self = template_q

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 1.33
end