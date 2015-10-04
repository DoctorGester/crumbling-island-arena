modifier_storm_spirit_e = class({})

function modifier_storm_spirit_e:OnCreated(kv)
	if IsServer() then
		local index = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		ParticleManager:SetParticleControlEnt(index, 1, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetOrigin(), true)
		self:AddParticle(index, false, false, -1, false, false)
	end
end

function modifier_storm_spirit_e:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function modifier_storm_spirit_e:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}
 
	return funcs
end

function modifier_storm_spirit_e:GetOverrideAnimation(params)
	return ACT_DOTA_OVERRIDE_ABILITY_4
end