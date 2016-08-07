undying_e = class({})

function undying_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function undying_e:GetCastAnimation()
    return ACT_DOTA_UNDYING_TOMBSTONE
end

function undying_e:GetPlaybackRateOverride()
    return 1.33
end