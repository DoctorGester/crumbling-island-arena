modifier_pudge_r = class({})

function modifier_pudge_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_pudge_r:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_pudge_r:GetEffectName()
    return "particles/units/heroes/hero_pudge/pudge_rot_recipient.vpcf"
end
