modifier_undying_r = class({})
self = modifier_undying_r

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MODEL_CHANGE
    }

    return funcs
end

function self:GetModifierMoveSpeedOverride(params)
    return 450
end

function self:GetModifierModelChange()
    return "models/heroes/undying/undying_flesh_golem.vmdl"
end

function self:GetActivityTranslationModifiers()
    return "haste"
end

function self:RemoveOnDeath()
    return false
end