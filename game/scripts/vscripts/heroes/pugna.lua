Pugna = class({}, {}, Hero)

function Pugna:constructor()
    self.__base__.constructor(self)

    self.traps = {}
end

function Pugna:Delete()
    self.__base__.Delete(self)

    for _, trap in pairs(self.traps) do
        if IsValidEntity(trap) then
            trap:RemoveSelf()
        end
    end
end

function Pugna:IsReversed()
    return self:FindAbility("pugna_e"):GetToggleState()
end

function Pugna:Damage(source)
    if source == self or not self.unit:HasModifier("modifier_pugna_r") then
        Hero.Damage(self, source)
    end
end

function Pugna:Heal()
    if not self.unit:HasModifier("modifier_pugna_r") then
        Hero.Heal(self)
    end
end

function Pugna:GetProjectileColor()
    if self:IsReversed() then
        return Vector(58, 193, 0)
    end

    return Vector(255, 128, 0)
end

function Pugna:GetTrapColor()
    if self:IsReversed() then
        return Vector(255, 128, 0)
    end

    return Vector(58, 193, 0)
end