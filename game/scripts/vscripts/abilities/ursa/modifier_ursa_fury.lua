modifier_ursa_fury = class({})

if IsServer() then
    function modifier_ursa_fury:OnCreated()
        self:StartIntervalThink(0.2)
    end

    function modifier_ursa_fury:OnIntervalThink()
        if self:GetStackCount() > 0 then
            self:DecrementStackCount()
        end
    end
end

function modifier_ursa_fury:IsHidden()
    return true
end

function modifier_ursa_fury:IncreaseStacks(amount)
    self:SetStackCount(math.min(100, self:GetStackCount() + amount * 18))

    if self:GetStackCount() == 100 then
        self:Destroy()

        local hero = self:GetParent():GetParentEntity()

        hero:AddNewModifier(hero, hero:FindAbility("ursa_a"), "modifier_ursa_frenzy", { duration = 6.0 })
    end
end

function modifier_ursa_fury:OnDamageDealt(target, source, amount)
    local parent = self:GetParent():GetParentEntity()

    if parent == source and target ~= source and instanceof(target, Hero) then
        self:IncreaseStacks(amount)
    end
end

function modifier_ursa_fury:OnDamageReceivedPriority()
    return 0
end

function modifier_ursa_fury:OnDamageReceived(_, _, amount)
    self:IncreaseStacks(amount)
end