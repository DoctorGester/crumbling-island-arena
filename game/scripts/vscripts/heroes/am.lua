AM = class({}, {}, Hero)

function AM:SetUnit(unit)
    getbase(AM).SetUnit(self, unit)

    self:AddNewModifier(self, unit:FindAbilityByName("am_e"), "modifier_charges",
        {
            max_count = 3,
            replenish_time = 3
        }
    )
end