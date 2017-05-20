modifier_cm_stun = class({})

function modifier_cm_stun:OnCreated()
    if IsServer() then
        self:GetParent():EmitSound("Arena.CM.Freeze")
    end
end

function modifier_cm_stun:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_cm_stun:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true
    }

    return state
end

function modifier_cm_stun:GetEffectName()
    return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_cm_stun:GetEffectAttachType()
    return PATTACH_ABSORIGIN
end

function modifier_cm_stun:IsDebuff()
    return true
end

function modifier_cm_stun:IsStunDebuff()
    return true
end

function modifier_cm_stun:GetTexture()
    return "crystal_maiden_frostbite"
end