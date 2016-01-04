TA = class({}, {}, Hero)

function TA:Damage(source)
    if self:HasModifier("modifier_ta_r_shield") then
        self:EmitSound("Arena.TA.HitR")
        self:AddNewModifier(self, self:FindAbility("ta_r"), "modifier_ta_r_heal", { duration = 3 })
    end

    self:FindAbility("ta_e"):EndCooldown()

    Hero.Damage(self, source)
end