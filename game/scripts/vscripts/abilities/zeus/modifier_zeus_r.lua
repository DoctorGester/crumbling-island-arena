modifier_zeus_r = class({})

function modifier_zeus_r:IsDebuff()
    return true
end

function modifier_zeus_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_zeus_r:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end