modifier_nevermore_q = class({})

function modifier_nevermore_q:IsHidden()
    return true
end

if IsServer() then
    function modifier_nevermore_q:OnDestroy()
        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(1))
    end
end