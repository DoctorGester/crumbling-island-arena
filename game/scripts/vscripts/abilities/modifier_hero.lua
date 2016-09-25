modifier_hero = class({})

function modifier_hero:IsHidden()
    return true
end

function modifier_hero:IsForwardEmpty()
    local parent = self:GetParent()
    local forward = parent:GetForwardVector() * parent:GetBaseMoveSpeed() / 5 + parent:GetAbsOrigin()
    return not Spells.TestPoint(forward, parent)
end

function modifier_hero:CheckState()
    local state = {
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_hero:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
    }

    return funcs
end

if IsServer() then
    function modifier_hero:GetModifierMoveSpeed_Limit()
        if self:IsForwardEmpty() then
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