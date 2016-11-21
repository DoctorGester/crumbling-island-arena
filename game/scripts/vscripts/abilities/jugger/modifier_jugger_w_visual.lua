modifier_jugger_w_visual = class({})

function modifier_jugger_w_visual:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_jugger_w_visual:RemoveOnDeath()
    return false
end