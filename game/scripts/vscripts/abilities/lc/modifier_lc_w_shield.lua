modifier_lc_w_shield = class({})

function modifier_lc_w_shield:GetEffectName()
    return "particles/lc_w/lc_w.vpcf"
end

function modifier_lc_w_shield:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end