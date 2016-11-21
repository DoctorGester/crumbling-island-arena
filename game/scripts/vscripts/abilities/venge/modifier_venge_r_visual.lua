modifier_venge_r_visual = class({})

function modifier_venge_r_visual:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_venge_r_visual:GetStatusEffectName()
    return "particles/status_fx/status_effect_illusion.vpcf"
end

function modifier_venge_r_visual:StatusEffectPriority()
    return 10
end

function modifier_venge_r_visual:RemoveOnDeath()
    return false
end