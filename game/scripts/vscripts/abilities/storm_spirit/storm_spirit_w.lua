storm_spirit_w = class({})

function storm_spirit_w:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local remnant = caster.hero:FindClosestRemnant(target)

	if remnant then
		Spells:AreaDamage(caster, remnant:GetAbsOrigin(), 256)
		caster.hero:DestroyRemnant(remnant)
	end
end

function storm_spirit_w:CastFilterResultLocation(location)
	-- Remnant data can't be accessed on the client
	if not IsServer() then return UF_SUCCESS end

	if not self:GetCaster().hero:HasRemnants() then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function storm_spirit_w:GetCustomCastErrorLocation(location)
	if not IsServer() then return "" end

	if not self:GetCaster().hero:HasRemnants() then
		return "#dota_hud_error_cant_cast_no_remnants"
	end

	return ""
end