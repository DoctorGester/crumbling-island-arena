modifier_sven_w_slow = class({})

function modifier_sven_w_slow:IsDebuff()
    return true
end

function modifier_sven_w_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_sven_w_slow:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_sven_w_slow:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sven_w_slow:GetModifierMoveSpeedBonus_Percentage(params)
    return -80
end