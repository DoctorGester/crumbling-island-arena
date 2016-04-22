modifier_drow_e = class({})

function modifier_drow_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }

    return funcs
end

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

function modifier_drow_e:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end

function modifier_drow_e:GetOverrideAnimationWeight(params)
    return 1.0
end

function modifier_drow_e:GetOverrideAnimationRate(params)
    return 2.4
end