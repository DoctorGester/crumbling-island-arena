modifier_launched = class({})

function modifier_launched:Airborne()
    return true
end

function modifier_launched:IsHidden()
    return true
end

function modifier_launched:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
        MODIFIER_PROPERTY_VISUAL_Z_DELTA
    }

    return funcs
end

function modifier_launched:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end

function modifier_launched:GetOverrideAnimationRate(params)
    return 2.5
end

function modifier_launched:GetVisualZDelta()
    return math.sin(self:GetElapsedTime() / self:GetDuration() * 3.14) * 180
end