modifier_shaker_e = class({})

function modifier_shaker_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_shaker_e:Airborne()
    return true
end

function modifier_shaker_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }

    return funcs
end

function modifier_shaker_e:GetOverrideAnimation(params)
    return ACT_DOTA_OVERRIDE_ABILITY_2
end

function modifier_shaker_e:GetOverrideAnimationRate(params)
    return self:GetStackCount() / 10
end

function modifier_shaker_e:Airborne()
    return true
end