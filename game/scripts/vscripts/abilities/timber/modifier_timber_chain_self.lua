modifier_timber_chain_self = class({})

function modifier_timber_chain_self:IsHidden()
    return true
end

function modifier_timber_chain_self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end
