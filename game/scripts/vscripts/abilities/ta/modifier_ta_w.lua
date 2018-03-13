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

function modifier_ta_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -50
end

function modifier_ta_w:GetEffectName()
    return "particles/units/heroes/hero_templar_assassin/templar_assassin_trap_slow.vpcf"
end

function modifier_ta_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ta_w:OnDamageReceived(source, entity, amount)
    local hero = self:GetCaster():GetParentEntity()
    local proj = instanceof(source, Projectile)

    if (hero == source or (proj and source.hero == hero)) then
        hero:Heal(amount)
        hero:EmitSound("Arena.TA.HitW")

        FX("particles/ta_w_heal/ta_w_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })
    end
end

function modifier_ta_w:OnDamageReceivedPriority()
    return PRIORITY_POST_SHIELD_ACTION
end
