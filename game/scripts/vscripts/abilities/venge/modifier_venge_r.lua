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
        local dist = (event.unit:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D()
        if event.unit:HasModifier("modifier_venge_r_target") and dist <= self:GetAuraRadius() and event.ability:ProcsMagicStick() then
            local unit = self:GetParent()
            unit:CastAbilityOnPosition(event.unit:GetAbsOrigin(), unit:FindAbilityByName("venge_q"), -1)
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