storm_spirit_w = class({})

function storm_spirit_w:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local remnant = Misc:FindClosestStormRemnant(caster, target)

	if remnant then
		Spells:AreaDamage(caster, remnant:GetAbsOrigin(), 256)
		Misc:DestroyStormRemnant(caster, remnant)
	end
end

function storm_spirit_w:CastFilterResultLocation(location)
	-- Remnant data can't be accessed on the client
	if not IsServer() then return UF_SUCCESS end

	if not Misc:HasRemnants(self:GetCaster()) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function storm_spirit_w:GetCustomCastErrorLocation(location)
	if not IsServer() then return "" end

	if not Misc:HasRemnants(self:GetCaster()) then
		return "#dota_hud_error_cant_cast_no_remnants"
	end

	return ""
end