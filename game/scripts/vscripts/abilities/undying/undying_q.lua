undying_q = class({})

function undying_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function undying_q:GetCastAnimation()
    return ACT_DOTA_UNDYING_DECAY
end

function undying_q:GetPlaybackRateOverride()
    return 1.66
end