undying_q_sub = class({})

function undying_q_sub:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
end