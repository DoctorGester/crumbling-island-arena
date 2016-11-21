modifier_ember_r_visual = class({})

function modifier_ember_r_visual:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }

    return state
end

function modifier_ember_r_visual:RemoveOnDeath()
    return false
end

function modifier_ember_r_visual:GetEffectName()
    return "particles/ember_r/ember_r.vpcf"
end

function modifier_ember_r_visual:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
