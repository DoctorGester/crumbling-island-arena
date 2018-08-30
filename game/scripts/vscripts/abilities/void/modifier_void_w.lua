modifier_void_w = class({})

if IsServer() then

    function modifier_void_w:OnAbilityImmediate(event)
        self:OnAbilityStart(event)
    end

    function modifier_void_w:OnAbilityStart(event)
        local hero = event.unit.hero
        local hero_void = self:GetCaster().hero
        local epic_test = hero == hero_void
        local TrueHero = hero:FindModifier("modifier_void_w")

        if not event.ability.canBeSilenced then
            return
        end

        if hero and TrueHero and not epic_test then
            if not self.destroyed then
                hero:AddNewModifier(hero, self:GetAbility(), "modifier_silence_lua", { duration = 2.0 })
                hero:Damage(hero_void, 2)
                hero:EmitSound("Arena.Void.ProcW")
            end
            self:Destroy()
            self.destroyed = true
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