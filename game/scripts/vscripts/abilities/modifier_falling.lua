modifier_falling = class({})

if IsServer() then
    function modifier_falling:OnCreated()
        self:StartIntervalThink(.066)
    end

    function modifier_falling:OnIntervalThink()
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_falling_animation", {})
        self:StartIntervalThink(-1)
    end
end

function modifier_falling:IsStunDebuff()
    return true
end

function modifier_falling:IsHidden()
    return true
end

function modifier_falling:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

-- Animation modifiers need to have a slight delay between them
modifier_falling_animation = class({})

function modifier_falling_animation:IsHidden()
    return true
end

function modifier_falling_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_falling_animation:GetOverrideAnimation()
    return ACT_DOTA_FLAIL
end
