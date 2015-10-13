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
	end

	table.remove(self.remnants, GetIndex(self.remnants, remnant))
end

function EarthSpirit:SetRemnantStand(remnant)
	self.remnantStand = remnant
end

function EarthSpirit:Damage(source)
	if source == self or self.remnantStand == nil then
		Hero.Damage(self, source)
	end
end