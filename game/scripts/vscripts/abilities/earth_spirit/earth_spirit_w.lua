earth_spirit_w = class({})

function earth_spirit_w:OnSpellStart()
	local hero = self:GetCaster().hero
	local exclude = {}

	if hero:HasRemnantStand() then
		exclude[hero:GetRemnantStand()] = true
	end

	local remnant = hero:FindRemnant(self:GetCursorPosition(), 200, exclude)

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