modifier_gyro_a_slow = class({})
local self = modifier_gyro_a_slow

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
    return -12 * self:GetStackCount()
end

function self:GetEffectName()
    return "particles/units/heroes/hero_doom_bringer/doom_infernal_blade_debuff.vpcf"
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