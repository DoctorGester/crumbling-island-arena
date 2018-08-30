modifier_void_w = class({})

if IsServer() then
    function modifier_void_w:OnAbilityImmediate(event)
        self:OnAbilityStart(event)
    end

    function modifier_void_w:OnAbilityStart(event)
        local target = event.unit:GetParentEntity()
        local shouldBeAffectedByAbility = target:FindModifier("modifier_void_w")
        local caster = self:GetCaster():GetParentEntity()

        if not event.ability.canBeSilenced then
            return
        end

        if shouldBeAffectedByAbility then
            target:AddNewModifier(target, self:GetAbility(), "modifier_silence_lua", { duration = 2.0 })
            target:Damage(caster, 2)
            target:EmitSound("Arena.Void.ProcW")

            self:Destroy()
        end
    end
end

function modifier_void_w:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
end

function modifier_void_w:GetEffectName()
    return "particles/void_w/void_w.vpcf"
end

function modifier_void_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end