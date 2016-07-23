modifier_qop_r = class({})

function modifier_qop_r:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_qop_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_life_stealer_rage.vpcf"
end

function modifier_qop_r:StatusEffectPriority()
    return 10
end