modifier_hero = class({})

function modifier_hero:IsHidden()
    return true
end

function modifier_hero:IsForwardEmpty()
    local hero = self:GetParent():GetParentEntity()
    local rad = 80
    local offset = hero:GetFacing() * rad

    return not Spells.TestCircle(hero:GetPos() + offset, rad) or not Spells.TestCircle(hero:GetPos() + offset * 2, rad)
end

function modifier_hero:CheckState()
    local state = {
        [MODIFIER_STATE_BLIND] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function modifier_hero:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        MODIFIER_EVENT_ON_STATE_CHANGED
    }

    return funcs
end

if IsServer() then
    function modifier_hero:OnStateChanged(event)
        local unit = event.unit
        if unit == self:GetParent() then
            if unit:IsDisarmed() then
                local count = unit:GetAbilityCount() - 1
                for i = 0, count do
                    local ability = unit:GetAbilityByIndex(i)

                    if ability ~= nil and IsAttackAbility(ability) and ability:IsInAbilityPhase() then
                        unit:Interrupt()
                    end
                end
            end
        end
    end

    function modifier_hero:GetModifierMoveSpeed_Limit()
        if self:GetParent():GetParentEntity():CanFall() and self:IsForwardEmpty() then
            return 20
        end
    end

    function modifier_hero:OnAbilityFullyCast(event)
        if event.unit == self:GetParent() then
            local player = self:GetParent():GetParentEntity().owner
            local round = GameRules.GameMode.round

            if round and not round.ended and round.statistics then
                round.statistics:IncreaseSpellsCast(player)
            end
        end
    end

end

function modifier_hero:GetDisableHealing()
    return true
end