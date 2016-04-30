modifier_wk_skeleton = class({})

function modifier_wk_skeleton:CheckState()
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

function modifier_wk_skeleton:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE
    }

    return funcs
end

function modifier_wk_skeleton:GetModifierMoveSpeedOverride(params)
    return 700
end

function modifier_wk_skeleton:DestroyOnExpire()
    return false
end