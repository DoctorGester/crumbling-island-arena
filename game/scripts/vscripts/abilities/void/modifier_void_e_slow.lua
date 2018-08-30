modifier_void_e_slow = class({})
local self = modifier_void_e_slow

function self:GetEffectName()
    return "particles/econ/items/faceless_void/faceless_void_jewel_of_aeons/fv_time_walk_debuff_jewel.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

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
    return -20
end