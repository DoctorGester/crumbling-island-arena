modifier_venge_r = class({})

if IsServer() then
    function modifier_venge_r:OnCreated()
        local unit = self:GetParent()
        ImmediateEffectPoint("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, unit, unit:GetAbsOrigin())
    end

    function modifier_venge_r:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_EXECUTED,
            MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
        }

        return funcs
    end

    function modifier_venge_r:OnAbilityExecuted(event)
        local vengeanceSummon = self:GetParent()
        local castTarget = event.unit
        local distanceToTarget = (castTarget:GetAbsOrigin() - vengeanceSummon:GetAbsOrigin()):Length2D()
        local summonAbility =  vengeanceSummon:FindAbilityByName("venge_q")
        local summonCanCast = vengeanceSummon:GetCurrentActiveAbility() == nil and summonAbility:IsCooldownReady()

        local targetIsEligible =
                castTarget:HasModifier("modifier_venge_r_target") and
                distanceToTarget <= self:GetAuraRadius() and
                not vengeanceSummon.hero.isFalling and
                event.ability:ProcsMagicStick()

        if targetIsEligible and summonCanCast then
            local effect = FX("particles/units/heroes/hero_silencer/silencer_curse_aoe.vpcf", PATTACH_ABSORIGIN_FOLLOW, event.unit, {
                cp1 = Vector(175, 0, 0)
            })

            self:AddParticle(effect, false, false, 0, true, false)

            castTarget:EmitSound("Arena.Venge.TargetR")
            vengeanceSummon:CastAbilityOnPosition(castTarget:GetAbsOrigin(), summonAbility, -1)
        end
    end

    function modifier_venge_r:GetModifierPercentageCooldown()
        return 60
    end

    function modifier_venge_r:OnDestroy()
        self:GetParent():EmitSound("Arena.Venge.EndR")
        self:GetParent().hero:Destroy()
    end
end

function modifier_venge_r:IsAura()
    return true
end

function modifier_venge_r:GetAuraRadius()
    return 550
end

function modifier_venge_r:GetAuraDuration()
    return 0.1
end

function modifier_venge_r:GetModifierAura()
    return "modifier_venge_r_target"
end

function modifier_venge_r:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_venge_r:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end