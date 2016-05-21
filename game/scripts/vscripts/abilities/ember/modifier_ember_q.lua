modifier_ember_q = class({})

function modifier_ember_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_ember_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_ember_q:IsDebuff()
    return true
end

function modifier_ember_q:GetStatusEffectName()
    return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_ember_q:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_ember_q:StatusEffectPriority()
    return 1
end

function modifier_ember_q:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end