modifier_blind = class({})

function modifier_blind:CheckState()
    local state = {
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_blind:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end