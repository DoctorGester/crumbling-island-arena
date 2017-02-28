modifier_custom_healthbar = class({})

function modifier_custom_healthbar:IsHidden()
    return true
end

function modifier_custom_healthbar:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end
