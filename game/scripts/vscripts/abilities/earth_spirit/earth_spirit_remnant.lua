EarthSpiritRemnant = class({
	health = 2,
	effect = nil
}, nil, DynamicEntity })

function EarthSpiritRemnant:SetEffect(effect)
	self.effect = effect
end

function EarthSpiritRemnant:Damage(source)
	self.health = self.health - 1

	if self.health == 0 then
		self:Destroy()
	end
end