modifier_rune_double_damage = class({})

function modifier_rune_double_damage:IsHidden()
    return true
end

function modifier_rune_double_damage:GetEffectName()
    return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_rune_double_damage:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
