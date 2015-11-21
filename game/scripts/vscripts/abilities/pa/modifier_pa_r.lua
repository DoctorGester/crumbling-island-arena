modifier_pa_r = class({})

modifier_pa_r.fadeTime = 0.7

function modifier_pa_r:OnCreated(params)
    self.invisBrokenAt = 0
end

function modifier_pa_r:OnDestroy()
    if IsServer() then
        self:GetParent():RemoveModifierByName("modifier_persistent_invisibility")
    end
end

function modifier_pa_r:OnAbilityExecuted()
    self.invisBrokenAt = self:GetElapsedTime()
    self:GetModifierInvisibilityLevel()
end

function modifier_pa_r:CheckState()
    local state = {}

    if IsServer() then
        state[MODIFIER_STATE_INVISIBLE] = self:CalculateInvisibilityLevel() == 1.0
    end

    return state
end

function modifier_pa_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

function modifier_pa_r:CalculateInvisibilityLevel()
    return math.min((self:GetElapsedTime() - self.invisBrokenAt) / self.fadeTime, 1.0)
end

function modifier_pa_r:GetModifierInvisibilityLevel(params)
    if IsClient() then
        return self:GetStackCount() / 100
    end

    local level = self:CalculateInvisibilityLevel()

    if IsServer() then
        self:SetStackCount(math.ceil(level * 100))
    end

    return level
end

function modifier_pa_r:GetModifierMoveSpeedBonus_Percentage(params)
    return 100
end