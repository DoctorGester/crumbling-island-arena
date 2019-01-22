modifier_timber_e = class({})

function modifier_timber_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_timber_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_timber_e:GetActivityTranslationModifiers()
    return "forcestaff_friendly"
end

function modifier_timber_e:Airborne()
    return true
end