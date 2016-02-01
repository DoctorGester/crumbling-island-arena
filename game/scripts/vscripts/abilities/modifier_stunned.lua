modifier_stunned = class({})
 
function modifier_stunned:IsDebuff()
    return true
end
 
function modifier_stunned:IsStunDebuff()
    return true
end
 
function modifier_stunned:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end
 
function modifier_stunned:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
 
function modifier_stunned:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
 
    return funcs
end
 
function modifier_stunned:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end
 
function modifier_stunned:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }
 
    return state
end
 