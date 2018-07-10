modifier_nevermore_q = class({})

function modifier_nevermore_q:IsHidden()
    return true
end

if IsServer() then
    function modifier_nevermore_q:OnDestroy()
    	local ability = self:GetAbility()
    	if not ability:IsInAbilityPhase() then
        	ability:StartCooldown(ability:GetCooldown(1))
        else
        	print("Too late! self:", self)
        	self:SetDuration(2, true)
        end
    end
end