modifier_lc_q_animation = class({})

function modifier_lc_q_animation:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_lc_q_animation:Airborne()
    return true
end