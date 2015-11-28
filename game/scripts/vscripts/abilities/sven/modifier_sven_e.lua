modifier_sven_e = class({})

function modifier_sven_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }

    return funcs
end

function modifier_sven_e:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }

    return state
end

function modifier_sven_e:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end

function modifier_sven_e:GetOverrideAnimationWeight(params)
    return 1.0
end


function modifier_sven_e:GetOverrideAnimationRate(params)
    return 1.8
end