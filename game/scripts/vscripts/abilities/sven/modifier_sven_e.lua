modifier_sven_e = class({})

function modifier_sven_e:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }

    return state
end

function modifier_sven_e:OnDamageReceived()
    return false
end