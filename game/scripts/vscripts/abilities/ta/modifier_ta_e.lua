modifier_ta_e = class({})

function modifier_ta_e:OnDamageReceived()
    self:GetAbility():EndCooldown()
end