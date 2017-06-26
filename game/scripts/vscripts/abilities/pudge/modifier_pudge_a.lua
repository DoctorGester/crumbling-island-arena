modifier_pudge_a = class({})

function modifier_pudge_a:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_pudge_a:IsPermanent()
    return true
end

function modifier_pudge_a:IsDebuff()
    return true
end

function modifier_pudge_a:GetModifierMoveSpeedBonus_Percentage(params)
    return -80 + self:GetElapsedTime() / self:GetDuration() * 80
end

function modifier_pudge_a:StatusEffectPriority()
    return 2
end

function modifier_pudge_a:GetStatusEffectName()
    return "particles/status_fx/status_effect_bloodrage.vpcf"
end