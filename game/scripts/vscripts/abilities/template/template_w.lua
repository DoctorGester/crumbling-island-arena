template_w = class({})
local self = template_w

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end