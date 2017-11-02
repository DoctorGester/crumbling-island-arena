modifier_earth_spirit_w_root = class({})

function modifier_earth_spirit_w_root:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_earth_spirit_w_root:IsDebuff()
    return true
end