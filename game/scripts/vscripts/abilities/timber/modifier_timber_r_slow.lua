modifier_timber_r_slow = class({})
local self = modifier_timber_r_slow

function self:GetTexture()
    return "disruptor_thunder_strike"
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
    return -30 - 10 * self:GetStackCount()
end

function self:StatusEffectPriority()
    return 2
end

function self:GetStatusEffectName()
    return "particles/status_fx/status_effect_shredder_whirl.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end