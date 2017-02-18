modifier_pa_q = class({})

function modifier_pa_q:OnCreated(kv)
    self:SetStackCount(2)
end

function modifier_pa_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_pa_q:IsDebuff()
    return true
end

function modifier_pa_q:GetModifierMoveSpeedBonus_Percentage()
    return -50
end

function modifier_pa_q:GetEffectName()
    return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end

function modifier_pa_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_pa_q:OnDamageReceived(source, hero, amount, isPhysical)
    local ent = self:GetCaster():GetParentEntity()

    if source == ent or source.hero == ent then
        self:DecrementStackCount()

        if self:GetStackCount() == 0 then
            self:Destroy()
        end

        return amount + 1
    end
end
