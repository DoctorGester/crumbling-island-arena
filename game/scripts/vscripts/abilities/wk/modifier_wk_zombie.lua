modifier_wk_zombie = class({})

function modifier_wk_zombie:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_BLIND] = true,
    }

    return state
end

function modifier_wk_zombie:DestroyOnExpire()
    return false
end