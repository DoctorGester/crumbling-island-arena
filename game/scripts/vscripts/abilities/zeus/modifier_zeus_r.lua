modifier_zeus_r = class({})

function modifier_zeus_r:CheckState()
    local state = {
        [MODIFIER_STATE_OUT_OF_GAME] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_zeus_r:IsHidden()
    return true
end

function modifier_zeus_r:IsInvulnerable()
    return true
end

function modifier_zeus_r:Airborne()
    return true
end