modifier_knockback_lua = class({})

function modifier_knockback_lua:IsDebuff()
    return true
end
 
function modifier_knockback_lua:IsStunDebuff()
    return true
end
 
function modifier_knockback_lua:GetEffectName()
    return "particles/generic_gameplay/generic_stunned.vpcf"
end
 
function modifier_knockback_lua:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
 
function modifier_knockback_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }
 
    return funcs
end
 
function modifier_knockback_lua:GetOverrideAnimation(params)
    return ACT_DOTA_FLAIL
end
 
function modifier_knockback_lua:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
    }
 
    return state
end

function modifier_knockback_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end