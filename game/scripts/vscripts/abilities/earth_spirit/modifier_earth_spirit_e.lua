modifier_earth_spirit_e = class({})

function modifier_earth_spirit_e:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function modifier_earth_spirit_e:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
 
	return funcs
end

function modifier_earth_spirit_e:GetOverrideAnimation(params)
	return ACT_DOTA_OVERRIDE_ABILITY_4
end