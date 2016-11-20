modifier_shaker_a_animation = class({})

function modifier_shaker_a_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_shaker_a_animation:GetActivityTranslationModifiers()
    return "enchant_totem"
end

function modifier_shaker_a_animation:IsHidden()
    return true
end