earth_spirit_w = class({})

function earth_spirit_w:OnSpellStart()
	local hero = self:GetCaster().hero
	local remnant = EarthSpirit:FindNonStandRemnantCursor(self)

	if not remnant then return end
	if hero:GetRemnantStand() == remnant then return end

	if hero:HasRemnantStand() then
		hero:GetRemnantStand():SetTarget(remnant)
	else
		remnant:SetTarget(hero)
	end
end

function earth_spirit_w:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_3
end

function earth_spirit_w:CastFilterResultLocation(location)
	-- Remnant data can't be accessed on the client
	if not IsServer() then return UF_SUCCESS end

	if not EarthSpirit:FindNonStandRemnantCursor(self, location) then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function earth_spirit_w:GetCustomCastErrorLocation(location)
	if not IsServer() then return "" end

	if not EarthSpirit:FindNonStandRemnantCursor(self, location) then
		return "#dota_hud_error_earth_spirit_cant_cast_no_remnant"
	end

	return ""
end
