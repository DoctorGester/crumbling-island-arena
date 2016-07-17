modifier_tiny_q_speed = class({})

function modifier_tiny_q_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_tiny_q_speed:GetModifierMoveSpeedBonus_Percentage(params)
    return self:GetStackCount() * 40
end

function modifier_tiny_q_speed:IsHidden()
    return self:GetStackCount() == 0
end
