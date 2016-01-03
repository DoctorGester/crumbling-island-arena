modifier_falling = class({})

function modifier_falling:IsHidden()
    return true
end

function modifier_falling:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_falling:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_falling:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end