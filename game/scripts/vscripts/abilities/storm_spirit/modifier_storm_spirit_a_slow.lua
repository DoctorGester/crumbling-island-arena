modifier_storm_spirit_a_slow = class({})

function modifier_storm_spirit_a_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_storm_spirit_a_slow:IsDebuff()
    return true
end

function modifier_storm_spirit_a_slow:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end