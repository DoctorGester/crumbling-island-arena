modifier_venge_w = class({})

if IsServer() then
    function modifier_venge_w:OnCreated(kv)
        local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        self:AddParticle(effect, false, false, 0, true, false)
    end
end

function modifier_venge_w:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
 
    return state
end

function modifier_venge_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_venge_w:IsDebuff()
    return true
end

function modifier_venge_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_venge_w:GetEffectName()
    return "particles/units/heroes/hero_vengeful/vengeful_wave_of_terror_recipient_reduction.vpcf"
end

function modifier_venge_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_venge_w:OnDamageReceived(_, _, amount, isPhysical)
    if isPhysical then
        return amount + 1
    end
end

function modifier_venge_w:OnDamageReceivedPriority()
    return PRIORITY_AMPLIFY_DAMAGE
end

function modifier_venge_w:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end