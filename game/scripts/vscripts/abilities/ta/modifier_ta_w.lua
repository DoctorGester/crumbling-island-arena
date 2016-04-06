modifier_ta_w = class({})

function modifier_ta_w:IsDebuff()
    return true
end

function modifier_ta_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_ta_w:OnAbilityExecuted(event)
    if event.unit == self:GetParent() then
        local hero = self:GetCaster().hero
        hero:Heal()
        hero:EmitSound("Arena.TA.HitW")

        ImmediateEffect("particles/ta_w_heal/ta_w_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
    end
end

function modifier_ta_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -20
end

function modifier_ta_w:GetEffectName()
    return "particles/ta_w/ta_w_debuff.vpcf"
end

function modifier_ta_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end