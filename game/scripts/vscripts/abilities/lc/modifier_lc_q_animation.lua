modifier_lc_q_animation = class({})

function modifier_lc_q_animation:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_lc_q_animation:Airborne()
    return true
end

function modifier_lc_q_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }

    return funcs
end

function modifier_lc_q_animation:GetOverrideAnimation(params)
    return ACT_DOTA_ATTACK2
end

function modifier_lc_q_animation:GetOverrideAnimationRate(params)
    return 1.5
end