template_w = class({})

function template_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function template_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end