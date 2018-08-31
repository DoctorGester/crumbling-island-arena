modifier_void_q = class({})

if IsServer() then
    function modifier_void_q:OnAbilityExecuted(event)
        local target = event.unit:GetParentEntity()
        local shouldBeAffectedByAbility = target:FindModifier("modifier_void_q")

        if not event.ability.canBeSilenced then
            return
        end

        if shouldBeAffectedByAbility then
            target:AddNewModifier(target, self:GetAbility(), "modifier_void_q_root", { duration = 1.5 })
        end
    end
end

function modifier_void_q:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_void_q:GetEffectName()
    return "particles/void_q/void_q_debuff.vpcf"
end

function modifier_void_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
