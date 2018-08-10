modifier_invoker_w = class({})

if IsServer() then
    function modifier_invoker_w:OnCreated(kv)
        local effect = ParticleManager:CreateParticle("particles/items_fx/ethereal_blade_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(effect, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        self:AddParticle(effect, false, false, 0, true, false)
    end
end

function modifier_invoker_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_invoker_w:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_invoker_w:OnDamageReceived(source, hero, amount, isPhysical)
    if not isPhysical then
        local hero = self:GetCaster():GetParentEntity()
        local proj = instanceof(source, Projectile)
        if (hero == source or (proj and source.hero == hero)) then
            return amount * 2
        else
            return amount
        end
    end

    return false
end

function modifier_invoker_w:OnDamageReceivedPriority()
    return PRIORITY_AMPLIFY_DAMAGE
end

function modifier_invoker_w:IsDebuff()
    return true
end

function modifier_invoker_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -40
end

function modifier_invoker_w:GetStatusEffectName()
    return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_invoker_w:StatusEffectPriority()
    return 10
end

function modifier_invoker_w:GetEffectName()
    return "particles/items_fx/ghost.vpcf"
end

function modifier_invoker_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end