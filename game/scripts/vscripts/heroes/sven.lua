Sven = class({}, {}, Hero)

function Sven:IsEnraged()
    return self:FindModifier("modifier_sven_r")
end

function Sven:ResetCooldowns()
    self.unit:FindAbilityByName("sven_q"):EndCooldown()
    self.unit:FindAbilityByName("sven_w"):EndCooldown()
    self.unit:FindAbilityByName("sven_e"):EndCooldown()
end

function Sven:Damage(source)
    if source == self or not self.unit:HasModifier("modifier_sven_e") then
        Hero.Damage(self, source)
    end
end