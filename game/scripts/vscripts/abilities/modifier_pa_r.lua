modifier_pa_r = class({})

function modifier_pa_r:OnDestroy()
	self:GetCaster():RemoveModifierByName("modifier_invisible")
end

function modifier_pa_r:CheckState()
	local state = {
		[MODIFIER_STATE_INVISIBLE] = true
	}

	return state
end

function modifier_pa_r:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED 
	}
 
	return funcs
end

function modifier_pa_r:OnAbilityExecuted()
	self:Destroy()
end

function modifier_pa_r:GetModifierMoveSpeedBonus_Percentage(params)
	return 100
end