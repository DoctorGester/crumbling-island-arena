modifier_earth_spirit_w_slow = class({})

function modifier_earth_spirit_w_slow:IsDebuff()
    return true
end

function modifier_earth_spirit_w_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_earth_spirit_w_slow:GetModifierMoveSpeedBonus_Percentage(params)
    return -90
end