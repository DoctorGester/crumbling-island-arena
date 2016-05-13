template_e = class({})

function template_e:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function template_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function template_e:GetPlaybackRateOverride()
    return 2
end