modifier_wearable_visuals = class({})

if IsServer() then
    function modifier_wearable_visuals:OnCreated()
        self:StartIntervalThink(1 / 30)
        self.notDrawing = false
    end

    function modifier_wearable_visuals:OnIntervalThink( ... )
        if self:GetStackCount() > 100 then
            if not self.notDrawing then
                self:GetParent():AddNoDraw()
                self.notDrawing = true
            end
        else
            if self.notDrawing then
                self:GetParent():RemoveNoDraw()
                self.notDrawing = false
            end
        end
    end
end

function modifier_wearable_visuals:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_wearable_visuals:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }

    return funcs
end

if IsClient() then
    function modifier_wearable_visuals:GetModifierInvisibilityLevel(params)
        local stacks = self:GetStackCount()

        if (stacks > 100) then
            return (stacks - 101) / 100
        end

        return stacks / 100
    end
end

modifier_wearable_visuals_status_fx = class({})

function modifier_wearable_visuals_status_fx:GetStatusEffectName()
    return CustomNetTables:GetTableValue("wearables", tostring(self:GetParent():GetEntityIndex())).fx
end

function modifier_wearable_visuals_status_fx:StatusEffectPriority()
    return 1
end
