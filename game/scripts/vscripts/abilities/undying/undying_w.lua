undying_w = class({})

function undying_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function undying_w:GetCastAnimation()
    return ACT_DOTA_UNDYING_SOUL_RIP
end

function undying_w:GetPlaybackRateOverride()
    return 1.66
end