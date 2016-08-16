modifier_dusa_w = class({})
local self = modifier_dusa_w

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function self:IsDebuff()
    return true
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function self:GetEffectName()
    return "particles/items_fx/diffusal_slow.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end