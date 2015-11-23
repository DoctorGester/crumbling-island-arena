modifier_cm_r_slow = class({})

function modifier_cm_r_slow:IsDebuff()
    return true
end

function modifier_cm_r_slow:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost_lich.vpcf"
end

function modifier_cm_r_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_cm_r_slow:GetModifierMoveSpeedBonus_Percentage(params)
    local parent = self:GetParent()
    local caster = self:GetCaster()

    if not caster then
        return 0
    end

    local distance = (parent:GetAbsOrigin() - caster:GetAbsOrigin()):Length2D()

    return -90 * (1 - (distance / 600))
end