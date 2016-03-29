modifier_sniper_w_trap = class({})

function modifier_sniper_w_trap:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_INVISIBLE] = self:GetElapsedTime() >= 3
    }

    return state
end

function modifier_sniper_w_trap:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_sniper_w_trap:GetModifierInvisibilityLevel(params)
    return math.min(self:GetElapsedTime() / 3, 3)
end
