modifier_ta_q = class({})

function modifier_ta_q:IsDebuff()
    return true
end

function modifier_ta_q:GetEffectName()
    return "particles/ta_w/ta_w_debuff.vpcf"
end

function modifier_ta_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ta_q:OnDamageReceived(_, _, amount, isPhysical)
    if isPhysical then
        return amount + 1
    end
end
