modifier_sniper_q_target = class({})

function modifier_sniper_q_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_sniper_q_target:IsDebuff()
    return true
end

function modifier_sniper_q_target:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end