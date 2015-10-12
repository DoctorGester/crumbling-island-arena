EarthSpirit = class({
	remnants = nil
}, {}, Hero)

function EarthSpirit:constructor()
	self.__base__.constructor(self)
	
	self.remnants = {}
end

function EarthSpirit:AddRemnant(remnant)
	table.insert(self.remnants, remnant)
end