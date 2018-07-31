modifier_nevermore_q = class({})

function modifier_nevermore_q:IsHidden()
    return true
end

function modifier_nevermore_q:DestroyOnExpire()
    return false
end

if IsServer() then
    function modifier_nevermore_q:OnCreated()
        self:StartIntervalThink(0)
        self:OnIntervalThink()
    end

    function modifier_nevermore_q:OnIntervalThink()
        local ability = self:GetAbility()
        if self:GetRemainingTime() <= 0 and not ability:IsInAbilityPhase()then
            self:Destroy()
        end
    end

    function modifier_nevermore_q:OnDestroy()
        self:GetAbility():StartCooldown(self:GetAbility():GetCooldown(1))
    end
end