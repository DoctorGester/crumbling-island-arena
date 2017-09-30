modifier_shaker_e = class({})

function modifier_shaker_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_shaker_e:Airborne()
    return true
end