modifier_ld_bear = class({})

function modifier_ld_bear:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_BLIND] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
    }

    return state
end

function modifier_ld_bear:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MOVESPEED_MAX
    }

    return funcs
end

function modifier_ld_bear:GetModifierMoveSpeedOverride(params)
    return 600
end

function modifier_ld_bear:GetModifierMoveSpeed_Max(params)
    return 600
end

function modifier_ld_bear:DestroyOnExpire()
    return false
end