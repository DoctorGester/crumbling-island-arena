modifier_tower = class({})

function modifier_tower:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function modifier_tower:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE 
    }

    return funcs
end

function modifier_tower:GetModifierConstantHealthRegen()
    return 100
end

function modifier_tower:GetModifierBaseAttack_BonusDamage()
    return 10000
end