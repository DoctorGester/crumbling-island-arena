modifier_phoenix_q = class({})

function modifier_phoenix_q:CheckState()
    local state = {
        [MODIFIER_STATE_FLYING] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_phoenix_q:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf"
end

function modifier_phoenix_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_phoenix_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_phoenix_q:GetOverrideAnimation(params)
    return ACT_DOTA_OVERRIDE_ABILITY_3
end

function modifier_phoenix_q:Airborne()
    return true
end