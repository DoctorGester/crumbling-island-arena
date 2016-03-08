modifier_venge_r = class({})

function modifier_venge_r:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }

    return state
end

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
        if event.unit:HasModifier("modifier_venge_r_target") then
            local unit = self:GetParent()
            unit:CastAbilityOnPosition(event.unit:GetAbsOrigin(), unit:FindAbilityByName("venge_q"), -1)
        end
    end

    function modifier_venge_r:GetModifierPercentageCooldown()
        return 60
    end

    function modifier_venge_r:OnDestroy()
        self:GetParent().hero:Destroy()
    end
end

function modifier_venge_r:IsAura()
    return true
end

function modifier_venge_r:GetAuraRadius()
    return 650
end

function modifier_venge_r:GetAuraDuration()
    return 0.1
end

function modifier_venge_r:GetModifierAura()
    return "modifier_venge_r_target"
end

function modifier_venge_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_illusion.vpcf"
end

function modifier_venge_r:GetStatusEffectPriority()
    return 10
end

function modifier_venge_r:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_venge_r:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end