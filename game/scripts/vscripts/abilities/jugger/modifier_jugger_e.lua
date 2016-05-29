modifier_jugger_e = class({})

function modifier_jugger_e:OnAbilityExecuted(event)
    if event.unit == self:GetParent() then
        self:Destroy()
    end
end

function modifier_jugger_e:CheckState()
    local state = {}

    if IsServer() then
        state[MODIFIER_STATE_INVISIBLE] = self:GetModifierInvisibilityLevel() == 1.0
    end

    return state
end

if IsServer() then
    function modifier_jugger_e:OnDestroy()
        self:GetParent().hero:SwapAbilities("jugger_e_sub", "jugger_e")
    end
end

function modifier_jugger_e:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_jugger_e:GetModifierInvisibilityLevel(params)
    return math.min(self:GetElapsedTime() / 0.3, 1.0)
end