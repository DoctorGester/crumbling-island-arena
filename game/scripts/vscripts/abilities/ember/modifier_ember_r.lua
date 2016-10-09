modifier_ember_r = class({})

if IsServer() then
    function modifier_ember_r:DeclareFunctions()
        local funcs = {
            MODIFIER_EVENT_ON_ABILITY_START,
            MODIFIER_EVENT_ON_ABILITY_EXECUTED
        }

        return funcs
    end

    function modifier_ember_r:OnAbilityStart(event)
        if event.unit == self:GetCaster() then
            local unit = self:GetParent()
            unit:CastAbilityOnPosition(event.ability:GetCursorPosition(), unit:FindAbilityByName(event.ability:GetName()), -1)
        end
    end

    function modifier_ember_r:OnAbilityExecuted(event)
        if event.ability:GetName() == "ember_e" then
            self:OnAbilityStart(event)
        end
    end

    function modifier_ember_r:OnDestroy()
        self:GetParent():EmitSound("Arena.Ember.EndR")
        self:GetParent().hero:Destroy()
    end
end