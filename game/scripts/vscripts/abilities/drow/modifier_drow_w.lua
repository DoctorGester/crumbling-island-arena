modifier_drow_w = class({})

function modifier_drow_w:IsDebuff()
    return true
end

function modifier_drow_w:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true
    }

    return state
end

function modifier_drow_w:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_drow_w:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
