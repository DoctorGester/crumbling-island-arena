modifier_undying_q_health = class({})
local self = modifier_undying_q_health

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_SCALE
    }

    return funcs
end

function self:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function self:GetModifierModelScale()
    return 15 * self:GetStackCount()
end

function self:OnDamageReceived(_, _, amount)
    self:SetStackCount(self:GetStackCount() - amount)

    if self:GetStackCount() <= 0 then
        self:Destroy()
    end

    if self:GetStackCount() < 0 then
        return -self:GetStackCount()
    end

    return false
end

function self:OnDamageReceivedPriority()
    return PRIORITY_SHIELD
end