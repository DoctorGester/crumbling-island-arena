modifier_slark_e = class({})

function modifier_slark_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_slark_e:IsStunDebuff()
    return true
end

function modifier_slark_e:Airborne()
    return true
end

function modifier_slark_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_slark_e:GetOverrideAnimation(params)
    return ACT_DOTA_SLARK_POUNCE
end

function modifier_slark_e:GetEffectName()
    return "particles/units/heroes/hero_slark/slark_pounce_trail.vpcf"
end