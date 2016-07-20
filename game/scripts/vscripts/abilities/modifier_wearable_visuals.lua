modifier_wearable_visuals = class({})

function modifier_wearable_visuals:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_wearable_visuals:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

if IsClient() then
    function modifier_wearable_visuals:GetModifierInvisibilityLevel(params)
        return self:GetStackCount() / 100
    end
end