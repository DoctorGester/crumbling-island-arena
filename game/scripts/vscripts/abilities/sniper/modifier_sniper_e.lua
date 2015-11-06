modifier_sniper_e = class({})

function modifier_sniper_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_sniper_e:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_sniper_e:GetModifierMoveSpeedBonus_Percentage(params)
    return (1 - self:GetElapsedTime() / self:GetDuration()) * 200
end