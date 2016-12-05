modifier_zeus_a = class({})

function modifier_zeus_a:IsDebuff()
    return true
end

function modifier_zeus_a:GetEffectName()
    return "particles/zeus_w_buff/zeus_w_buff.vpcf"
end

function modifier_zeus_a:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end