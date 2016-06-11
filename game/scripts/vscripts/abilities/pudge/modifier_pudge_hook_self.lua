modifier_pudge_hook_self = class({})

function modifier_pudge_hook_self:IsHidden()
    return true
end

function modifier_pudge_hook_self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end
