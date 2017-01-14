modifier_ursa_q = class({})

function modifier_ursa_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_ursa_q:IsDebuff()
    return true
end

function modifier_ursa_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_ursa_q:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_earthshock_modifier.vpcf"
end

function modifier_ursa_q:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end