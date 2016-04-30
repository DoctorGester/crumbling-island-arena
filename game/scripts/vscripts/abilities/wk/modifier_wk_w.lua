modifier_wk_w = class({})

function modifier_wk_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_wk_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -34
end

function modifier_wk_w:IsDebuff()
    return true
end

function modifier_wk_w:GetEffectName()
    return "particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf"
end

function modifier_wk_w:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end