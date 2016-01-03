modifier_hero = class({})

function modifier_hero:IsHidden()
    return true
end

function modifier_hero:CheckState()
    local state = {
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_hero:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING
    }

    return funcs
end

function modifier_hero:GetDisableHealing()
    return true
end