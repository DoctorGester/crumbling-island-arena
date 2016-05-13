template_r = class({})

function template_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function template_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end
