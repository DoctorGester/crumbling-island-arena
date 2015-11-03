modifier_cm_frozen = class({})

function modifier_cm_frozen:OnCreated()
    if IsServer() then
        self:GetParent():EmitSound("Arena.CM.Freeze")
    end
end

function modifier_cm_frozen:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_cm_frozen:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true
    }

    return state
end

function modifier_cm_frozen:GetEffectName()
    return "particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf"
end

function modifier_cm_frozen:GetEffectAttachType()
    return PATTACH_ABSORIGIN
end

function modifier_cm_frozen:IsDebuff()
    return true
end

function modifier_cm_frozen:IsStunDebuff()
    return true
end

function modifier_cm_frozen:GetTexture()
    return "crystal_maiden_frostbite"
end