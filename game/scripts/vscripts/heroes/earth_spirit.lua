EarthSpirit = class({}, nil, Hero)

function EarthSpirit:constructor()
	self.__base__.constructor(self)
	
	self.remnants = {}
	self.remnantStand = nil
end

function EarthSpirit:AddRemnant(remnant)
	table.insert(self.remnants, remnant)
end

function EarthSpirit:RemnantDestroyed(remnant)
	if self.remanntStand == remnant then
		self.remnantStand = nil
		self:RemoveModifier("modifier_earth_spirit_stand")
	end

	table.remove(self.remnants, GetIndex(self.remnants, remnant)) 
end

function EarthSpirit:FindRemnantInArea(point, area)
	local closest = nil
	local distance = 64000

	for _, value in pairs(self.remnants) do
		local toRemnant = (point - value:GetAbsOrigin()):Length2D()

		if toRemnant <= distance and toRemnant <= area then
			closest = value
			distance = toRemnant
		end
	end

	return closest
end

function EarthSpirit:SetRemnantStand(remnant)
	local source = self.unit:FindAbilityByName("earth_spirit_q")
	
	self.remnantStand = remnant
	self:AddNewModifier(self, source, "modifier_earth_spirit_stand", {})
end

function EarthSpirit:Damage(source)
	if source == self or self.remnantStand == nil then
		Hero.Damage(self, source)
	end
end