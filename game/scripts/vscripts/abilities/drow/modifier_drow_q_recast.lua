modifier_drow_q_recast = class({})

if IsServer() then
    function modifier_drow_q_recast:OnDestroy()
        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(1))
    end
end