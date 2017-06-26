modifier_sven_e = class({})

function modifier_sven_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end