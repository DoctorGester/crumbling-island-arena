modifier_void_q = class({})

if IsServer() then

    function modifier_void_q:OnAbilityImmediate(event)
        self:OnAbilityStart(event)
    end

    function modifier_void_q:OnAbilityStart(event)
        local hero = event.unit.hero
        local hero_void = self:GetCaster().hero
        local epic_test = hero == hero_void
        local TrueHero = hero:FindModifier("modifier_void_q")

        if not event.ability.canBeSilenced then
            return
        end

        if hero and TrueHero and not epic_test then
            if not self.destroyed then
                hero:AddNewModifier(hero, self:GetAbility(), "modifier_void_q_root", { duration = 1.0 })
            end
        end
    end
end

function modifier_void_q:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
end

function modifier_void_q:GetEffectName()
    return "particles/void_q/void_q_debuff.vpcf"
end

function modifier_void_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end