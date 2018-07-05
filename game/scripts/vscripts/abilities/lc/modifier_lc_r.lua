modifier_lc_r = class({})

function modifier_lc_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_legion_commander_duel.vpcf"
end

function modifier_lc_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
    }

    return funcs
end

function modifier_lc_r:GetModifierMoveSpeedBonus_Percentage(params)
    return 30
end

function modifier_lc_r:GetModifierPercentageCooldown(params)
    return 50
end

function modifier_lc_r:OnDamageReceived(source, hero, amount)
    return hero:GetHealth() - amount > 0
end

function modifier_lc_r:OnDamageReceivedPriority()
    return PRIORITY_POST_SHIELD_ACTION
end