earth_spirit_w = class({})

function earth_spirit_w:OnSpellStart()
	local hero = self:GetCaster().hero
	local remnant = hero:FindRemnant(self:GetCursorPosition())

	if not remnant then return end
	if hero:GetRemnantStand() == remnant then return end

	if hero:HasRemnantStand() then
		hero:GetRemnantStand():SetTarget(remnant)
	else
		remnant:SetTarget(hero)
	end
end