modifier_drow_e = class({})

function modifier_drow_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_drow_e:GetEffectName()
    return "particles/drow_e/drow_e.vpcf"
end

function modifier_drow_e:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end