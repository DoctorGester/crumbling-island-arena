modifier_pa_w_sub = class({})

function modifier_pa_w_sub:OnCreated(kv)
end

function modifier_pa_w_sub:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
 
	return funcs
end

function modifier_pa_w_sub:IsDebuff()
	return true
end

function modifier_pa_w_sub:GetModifierMoveSpeedBonus_Percentage(params)
	return -50
end