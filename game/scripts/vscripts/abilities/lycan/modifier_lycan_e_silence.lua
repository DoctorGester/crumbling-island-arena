modifier_lycan_e_silence = class({})

function modifier_lycan_e_silence:IsDebuff()
    return true
end

function modifier_lycan_e_silence:CheckState()
    local state = {
        [MODIFIER_STATE_SILENCED] = true
    }

    return state
end

function modifier_lycan_e_silence:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_lycan_e_silence:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_lycan_e_silence:GetTexture()
    return "night_stalker_darkness"
end