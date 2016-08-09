modifier_lycan_w = class({})

function modifier_lycan_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_lycan_w:GetEffectName()
    return "particles/units/heroes/hero_night_stalker/nightstalker_void.vpcf"
end
 
function modifier_lycan_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_lycan_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end