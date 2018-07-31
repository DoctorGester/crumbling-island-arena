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
        if self:GetRemainingTime() <= 0 then
            local ability = self:GetAbility()
            if not ability:IsInAbilityPhase() then
                ability:StartCooldown(ability:GetCooldown(1))
                self:Destroy()
            end
        end
    end
end

if IsServer() then
    function modifier_nevermore_q:OnDestroy()
    	local ability = self:GetAbility()
    	if not ability:IsInAbilityPhase() then
        	ability:StartCooldown(ability:GetCooldown(1))
        end
    end
end