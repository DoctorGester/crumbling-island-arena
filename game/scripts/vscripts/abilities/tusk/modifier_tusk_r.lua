modifier_tusk_r = class({})

function modifier_tusk_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_tusk_r:GetKnockbackMultiplier()
    return 2
end

function modifier_tusk_r:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
