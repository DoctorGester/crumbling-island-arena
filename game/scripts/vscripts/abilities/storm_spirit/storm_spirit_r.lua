storm_spirit_r = class({})

function HasDeadRemnants(unit)
	return unit.lastRemnants and #unit.lastRemnants > 0
end

function storm_spirit_r:OnSpellStart()
	local caster = self:GetCaster()
	
	if caster.lastRemnants then
		for _, data in pairs(caster.lastRemnants) do
			Misc:CreateStormRemnant(caster, data.position, data.facing)
		end

		caster.lastRemnants = {}
	end
end

function storm_spirit_r:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end

function storm_spirit_r:CastFilterResult()
	-- Remnant data can't be accessed on the client
	if not IsServer() then return UF_SUCCESS end

	if not HasDeadRemnants(self:GetCaster()) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function storm_spirit_r:GetCustomCastError()
	if not IsServer() then return "" end

	if not HasDeadRemnants(self:GetCaster()) then
		return "#dota_hud_error_cant_cast_no_dead_remnants"
	end

	return ""
end
