modifier_pl_e_dash = class({})
local self = modifier_pl_e_dash

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function self:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function self:GetActivityTranslationModifiers()
    return "haste"
end

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function self:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end

function self:GetOverrideAnimationWeight(params)
    return 1.0
end

function self:GetOverrideAnimationRate(params)
    return 1.5
end