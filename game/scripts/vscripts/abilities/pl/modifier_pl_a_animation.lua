modifier_pl_a_animation = class({})

function modifier_pl_a_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_pl_a_animation:GetActivityTranslationModifiers()
    return "loadout"
end

function modifier_pl_a_animation:IsHidden()
    return true
end

--function modifier_pl_a_animation:GetPlaybackRateOverride()
--    return 2.0
--end

--function modifier_pl_a_animation:GetOverrideAnimation(params)
--    return ACT_DOTA_OVERRIDE_ABILITY_3
--end

