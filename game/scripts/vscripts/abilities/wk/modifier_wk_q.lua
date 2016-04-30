modifier_wk_q = class({})

function modifier_wk_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_wk_q:IsDebuff()
    return true
end

function modifier_wk_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -5 * self:GetStackCount()
end

function modifier_wk_q:GetEffectName()
    return "particles/items3_fx/silver_edge_slow.vpcf"
end

function modifier_wk_q:StatusEffectPriority()
    return 2
end

function modifier_wk_q:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_wk_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end