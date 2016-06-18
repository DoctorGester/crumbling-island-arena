Ursa = class({}, {}, Hero)

function Ursa:Damage(source)
    if source == self then
        Hero.Damage(self, source)
        return
    end

    if self:HasModifier("modifier_ursa_r") then
        return
    end

    Hero.Damage(self, source)
end

function Ursa:AddNewModifier(source, ability, modifier, params)
    if self:HasModifier("modifier_ursa_r") and modifier ~= "modifier_ursa_e" then
        return
    end

    return Hero.AddNewModifier(self, source, ability, modifier, params)
end