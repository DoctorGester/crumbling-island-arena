earth_spirit_e = class({})
LinkLuaModifier("modifier_earth_spirit_e", "abilities/storm_spirit/modifier_earth_spirit_e", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_e:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	local hero = caster.hero
	local targetRemnant = hero:FindRemnantInArea(target, 200)

	if targetRemnant then
		target = targetRemnant:GetPos()
	end

	hero:AddNewModifier(hero, self, "modifier_earth_spirit_e", {})
	hero:SetFacing(target - hero:GetPos())

	local dashData = {}
	dashData.unit = caster
	dashData.to = targetRemnant
	dashData.velocity = 1200
	dashData.onArrival = 
		function (unit)
			hero:RemoveModifierByName("modifier_earth_spirit_e")

			if not targetRemnant.destroyed then
				hero:SetRemnantStand(remnant)
			end
		end

	Spells:Dash(dashData)
end