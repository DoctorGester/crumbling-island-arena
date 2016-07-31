Tusk = class({}, {}, Hero)

function Tusk:IsInvulnerable()
    return self.invulnerable or self:HasModifier("modifier_tusk_e")
end