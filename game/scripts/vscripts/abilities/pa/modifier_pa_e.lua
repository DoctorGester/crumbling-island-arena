modifier_pa_e = class({})

function modifier_pa_e:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_pa_e:Airborne()
    return true
end