modifier_tiny_a_animation = class({})

function modifier_tiny_a_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_tiny_a_animation:GetActivityTranslationModifiers()
    return "tree"
end

function modifier_tiny_a_animation:IsHidden()
    return true
end