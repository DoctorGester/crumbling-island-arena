undying_e_sub = class({})

function undying_e_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end