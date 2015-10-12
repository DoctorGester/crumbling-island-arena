EarthSpirit = class({
	remnants = {}
}, {}, Hero)

function EarthSpirit:AddRemnant(remnant)
	table.insert(self.remnants, remnant)
end