modifier_earth_spirit_remnant = class({})

function modifier_earth_spirit_remnant:GetStatusEffectName()
	return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
end

function modifier_earth_spirit_remnant:CheckState()
	local state = {
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

function modifier_earth_spirit_remnant:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT
	}
 
	return funcs
end

function modifier_earth_spirit_remnant:GetOverrideAnimation(params)
	return ACT_DOTA_VICTORY
end

function modifier_earth_spirit_remnant:GetOverrideAnimationWeight(params)
	return 1.0
end