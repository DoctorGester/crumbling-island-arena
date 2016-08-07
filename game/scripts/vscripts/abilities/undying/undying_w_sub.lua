undying_w_sub = class({})

function undying_w_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end