modifier_ta_e = class({})

function modifier_ta_e:OnDamageReceived()
    self:GetAbility():EndCooldown()
end

function modifier_ta_e:OnDamageReceivedPriority()
    return -1
end
