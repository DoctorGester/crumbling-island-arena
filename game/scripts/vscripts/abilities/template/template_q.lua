template_q = class({})

function template_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function template_q:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function template_q:GetPlaybackRateOverride()
    return 1.33
end