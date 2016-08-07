undying_r = class({})

function undying_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function undying_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
