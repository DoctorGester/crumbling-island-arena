EarthSpiritRemnant = class({}, nil, DynamicEntity)

function EarthSpiritRemnant:constructor(owner)
	DynamicEntity.constructor(self)
	
	self.owner = owner
	self.unit = nil
	self.health = 2
	self.size = 48
	self.falling = false
	self.target = nil
	self.enemiesHit = {}
end

function EarthSpiritRemnant:CreateCounter()
	self.healthCounter = ParticleManager:CreateParticle("particles/earth_spirit_q/earth_spirit_q_counter.vpcf", PATTACH_CUSTOMORIGIN, nil)
	ParticleManager:SetParticleControl(self.healthCounter, 0, Vector(self.position.x, self.position.y, self.position.z + 200))
	ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))
end

function EarthSpiritRemnant:SetUnit(unit)
	self.unit = unit
	self.falling = true
	
	self.unit:SetAbsOrigin(self:GetPos())
end

function EarthSpiritRemnant:SetTarget(target)
	self.target = target
end

function EarthSpiritRemnant:FilterTarget(prev, pos, source, target)
	if target == self or target == self.owner then return false end
	if self.enemiesHit[target] and self.enemiesHit[target] > 0 then return false end

	if SegmentCircleIntersection(prev, pos, target:GetPos(), self:GetRad() + target:GetRad()) then
		if target:__instanceof__(EarthSpiritRemnant) then
			target:Destroy()
			return false
		end

		self.enemiesHit[target] = 30

		return true
	end
end

function EarthSpiritRemnant:Update()
	ParticleManager:SetParticleControl(self.healthCounter, 0, Vector(self.position.x, self.position.y, self.position.z + 200))

	if self.falling then
		local pos = self:GetPos()
		local ground = GetGroundHeight(pos, self.unit)
		local z = math.max(ground, pos.z - 200)
		self:SetPos(Vector(pos.x, pos.y, z))

		if z == ground then
			self.falling = false
		end
	end

	if self.owner.remnantStand == self then
		self.owner:SetPos(Vector(self.position.x, self.position.y, self.position.z + 150))
	end

	self.unit:SetAbsOrigin(self:GetPos())

	for target, time in pairs(self.enemiesHit) do
		self.enemiesHit[target] = time - 1
	end

	if self.target then
		if self.target.destroyed then
			self.target = nil
		else
			local pos = self:GetPos()
			local diff = self.target:GetPos() - pos
			if diff:Length2D() <= self:GetRad() + self.target:GetRad() then

				if self.target:__instanceof__(EarthSpiritRemnant) then
					self.target:Destroy()
				end

				self.target = nil
			else
				local velocity = diff:Normalized() * (800 / 30)
				local result = pos + velocity

				Spells:MultipleHeroesDamage(self, 
					function (attacker, target)
						return self:FilterTarget(pos, result, attacker, target)
					end
				)

				self:SetPos(result)
			end
		end
	end
end

function EarthSpiritRemnant:Remove()
	self.unit:RemoveSelf()

	ParticleManager:DestroyParticle(self.healthCounter, false)
	ParticleManager:ReleaseParticleIndex(self.healthCounter)

	if not self.owner.destroyed then
		self.owner:RemnantDestroyed(self)
	end
end

function EarthSpiritRemnant:Damage(source)
	if source ~= self.owner and self.owner.remnantStand == self then return end

	self.health = self.health - 1
	ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))

	if self.health == 0 then
		self:Destroy()
	end
end