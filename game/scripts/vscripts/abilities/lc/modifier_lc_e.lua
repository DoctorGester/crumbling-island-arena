modifier_lc_e = class({})
 
function modifier_lc_e:IsDebuff()
    return true
end
 
function modifier_lc_e:IsStunDebuff()
    return true
end
 
function modifier_lc_e:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end
 
function modifier_lc_e:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
 
function modifier_lc_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
 
    return funcs
end
 
function modifier_lc_e:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end
 
function modifier_lc_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }
 
    return state
end
 