modifier_sk_a = class({})

function modifier_sk_a:GetEffectName()
    return "particles/units/heroes/hero_sandking/sandking_caustic_finale_debuff.vpcf"
end

function modifier_sk_a:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end