EarthSpiritRemnant = class({}, nil, DynamicEntity)

function EarthSpiritRemnant:constructor(owner)
	DynamicEntity.constructor(self)
	
	self.owner = owner
	self.health = 2
	self.effect = nil
	self.size = 48
end

function EarthSpiritRemnant:CreateEffect(effect)
	local sky = Vector(self.position.x, self.position.y, self.position.z + 2000)
	self.effect = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_stoneremnant.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.effect, 0, self.position)
	ParticleManager:SetParticleControl(self.effect, 1, sky)

	self.healthCounter = ParticleManager:CreateParticle("particles/earth_spirit_q/earth_spirit_q_counter.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.healthCounter, 0, Vector(self.position.x, self.position.y, self.position.z + 200))
	ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))
end

function EarthSpiritRemnant:Update()
	ParticleManager:SetParticleControl(self.effect, 0, self.position)
end

function EarthSpiritRemnant:Remove()
	ParticleManager:DestroyParticle(self.effect, false)
	ParticleManager:ReleaseParticleIndex(self.effect)

	ParticleManager:DestroyParticle(self.healthCounter, false)
	ParticleManager:ReleaseParticleIndex(self.healthCounter)

	self.owner:RemnantDestroyed(self)
end

function EarthSpiritRemnant:Damage(source)
	if source ~= self.owner and self.owner.remnantStand == self then return end

	self.health = self.health - 1
	ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))

	if self.health == 0 then
		self:Destroy()
	end
end