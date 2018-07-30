modifier_nevermore_q_target = class({})

function modifier_nevermore_q_target:IsDebuff()
    return true
end

function modifier_nevermore_q_target:GetEffectName()
    return "particles/units/heroes/hero_nevermore/nevermore_shadowraze_debuff.vpcf"
end

function modifier_nevermore_q_target:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end