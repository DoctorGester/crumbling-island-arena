modifier_preview = class({})

function modifier_preview:IsHidden()
    return true
end

function modifier_preview:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
    }

    return state
end