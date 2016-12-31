modifier_venge_r_target = class({})

function modifier_venge_r_target:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
 
    return state
end

function modifier_venge_r_target:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_venge_r_target:IsDebuff()
    return true
end

function modifier_venge_r_target:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_venge_r_target:GetEffectName()
    return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient_reduction.vpcf"
end

function modifier_venge_r_target:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_venge_r_target:OnDamageReceived(_, _, amount, isPhysical)
    if isPhysical then
        return amount + 1
    end
end