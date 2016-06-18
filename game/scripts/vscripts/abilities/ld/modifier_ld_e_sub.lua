modifier_ld_e_sub = class({})

function modifier_ld_e_sub:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_ld_e_sub:GetModifierMoveSpeedBonus_Percentage(params)
    return 50
end

function modifier_ld_e_sub:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_battle_cry_overhead.vpcf"
end

function modifier_ld_e_sub:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ld_e_sub:GetOverrideAnimationRate()
    return 8
end

function modifier_ld_e_sub:GetActivityTranslationModifiers()
    return "haste"
end
