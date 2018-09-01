modifier_void_e_counter = class ({})

function modifier_void_e_counter:IsHidden()
    return self:GetStackCount() == 0
end

if IsServer() then
    function modifier_void_e_counter:OnCreated()
        self:StartIntervalThink(0.1)

        self.healthHistory = {}

        local health = self:GetCaster():GetParentEntity():GetHealth()

        for i = 1, 20 do
            table.insert(self.healthHistory, health)
        end
    end

    function modifier_void_e_counter:OnIntervalThink()
        local health = self:GetCaster():GetParentEntity():GetHealth()

        table.insert(self.healthHistory, health)

        if #self.healthHistory > 20 then
            table.remove(self.healthHistory, 1)
        end

        local healthAfterTimeWalk = self:TimeWalkHP()
        local healthRestored = math.max(0, healthAfterTimeWalk - health)

        self:SetStackCount(healthRestored)
    end
end

function modifier_void_e_counter:TimeWalkHP()
    return self.healthHistory[1]
end

