modifier_silence_lua = class({})

function modifier_silence_lua:IsDebuff()
    return true
end

function modifier_silence_lua:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_silence_lua:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
