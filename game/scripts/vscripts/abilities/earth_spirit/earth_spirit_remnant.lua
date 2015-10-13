EarthSpiritRemnant = class({}, nil, DynamicEntity)

function EarthSpiritRemnant:constructor(owner)
	DynamicEntity.constructor(self)
	
	self.owner = owner
	self.health = 2
	self.effect = nil
end

function EarthSpiritRemnant:CreateEffect(effect)
	local sky = Vector(self.position.x, self.position.y, self.position.z + 2000)
	self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(self.effect, 0, self.position)
	ParticleManager:SetParticleControl(self.effect, 1, sky)
end

function EarthSpiritRemnant:Update()
	ParticleManager:SetParticleControl(self.effect, 0, self.position)
end

function EarthSpiritRemnant:Remove()
	ParticleManager:DestroyParticle(self.effect, false)
	ParticleManager:ReleaseParticleIndex(self.effect)
end

function EarthSpiritRemnant:Damage(source)
	self.health = self.health - 1

	if self.health == 0 then
		self:Destroy()
	end
end

function EarthSpiritRemnant:Remove()
end