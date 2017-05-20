modifier_jugger_w_target = class({})

function modifier_jugger_w_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_jugger_w_target:IsDebuff()
    return true
end

function modifier_jugger_w_target:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_jugger_w_target:GetEffectName()
    return "particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_hero_heal.vpcf"
end

function modifier_jugger_w_target:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end