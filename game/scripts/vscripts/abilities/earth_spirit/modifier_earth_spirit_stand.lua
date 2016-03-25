modifier_earth_spirit_stand = class({})

function modifier_earth_spirit_stand:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_earth_spirit_stand:Airborne()
	return true
end