modifier_storm_spirit_e = class({})

function modifier_storm_spirit_e:OnCreated(kv)
	if IsServer() then
		local index = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_ball_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
		-- ParticleManager:SetParticleControlEnt(index, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin(), true)
		self:AddParticle(index, false, false, -1, false, false)
	end
	print("GOGOGO")
end

function modifier_storm_spirit_e:CheckState()
	local state = {
		[MODIFIER_STATE_FLYING] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
