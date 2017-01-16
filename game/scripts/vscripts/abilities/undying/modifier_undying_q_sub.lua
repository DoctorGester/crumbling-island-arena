modifier_undying_q_sub = class({})
local self = modifier_undying_q_sub

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function self:IsStunDebuff()
    return true
end

function self:Airborne()
    return true
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function self:GetActivityTranslationModifiers()
    return "forcestaff_friendly"
end