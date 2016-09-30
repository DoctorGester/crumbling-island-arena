modifier_damaged = class({})

function modifier_damaged:IsHidden()
    return true
end

function modifier_damaged:GetStatusEffectName()
    return "particles/status_effect_dmg.vpcf"
end

function modifier_damaged:StatusEffectPriority()
    return 2
end
