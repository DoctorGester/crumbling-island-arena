modifier_earth_spirit_e = class({})

if IsServer() then
    function modifier_earth_spirit_e:OnCreated()
        self:StartIntervalThink(.066)
    end

    function modifier_earth_spirit_e:OnIntervalThink()
        self:StartIntervalThink(-1)
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_earth_spirit_e_animation", {})
    end

    function modifier_earth_spirit_e:OnDestroy()
        self:GetParent():RemoveModifierByName("modifier_earth_spirit_e_animation")
    end
end

function modifier_earth_spirit_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_earth_spirit_e:Airborne()
    return true
end

-- Delayed animation part

modifier_earth_spirit_e_animation = class({})

function modifier_earth_spirit_e_animation:IsHidden()
    return true
end

function modifier_earth_spirit_e_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }

    return funcs
end

function modifier_earth_spirit_e_animation:GetOverrideAnimation(params)
    return ACT_DOTA_TELEPORT
end

function modifier_earth_spirit_e_animation:GetOverrideAnimationRate(params)
    return 4
end
