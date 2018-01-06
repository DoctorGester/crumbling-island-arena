modifier_nevermore_r = class({})

if IsServer() then
    function modifier_nevermore_r:OnCreated()
        self:GetParent():Interrupt()
        self.direction = (self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()):Normalized()
        self:StartIntervalThink(0.1)
        self:OnIntervalThink()
    end

    function modifier_nevermore_r:OnIntervalThink()
        local unit = self:GetParent()
        local position = unit:GetAbsOrigin() + self.direction * 500

        unit:MoveToPosition(position)
    end
end

function modifier_nevermore_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_nevermore_r:GetEffectName()
    return "particles/econ/items/nightstalker/nightstalker_black_nihility/nightstalker_black_nihility_void.vpcf"
end
 
function modifier_nevermore_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
 
function modifier_nevermore_r:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }
 
    return state
end

function modifier_nevermore_r:GetModifierMoveSpeedBonus_Percentage(params)
    return -40
end

function modifier_nevermore_r:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end