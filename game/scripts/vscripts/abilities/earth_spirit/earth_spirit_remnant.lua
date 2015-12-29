EarthSpiritRemnant = class({}, nil, DynamicEntity)

function EarthSpiritRemnant:constructor(owner)
    DynamicEntity.constructor(self)

    self.owner = owner
    self.unit = nil
    self.health = 2
    self.size = 64
    self.falling = false
    self.target = nil
    self.speed = 0
    self.enemiesHit = {}
end

function EarthSpiritRemnant:CreateCounter()
    self.healthCounter = ParticleManager:CreateParticle("particles/earth_spirit_q/earth_spirit_q_counter.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(self.healthCounter, 0, Vector(self.position.x, self.position.y, self.position.z + 200))
    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))
end

function EarthSpiritRemnant:SetUnit(unit, fall)
    self.unit = unit
    self.falling = fall

    self.unit:SetAbsOrigin(self:GetPos())
end

function EarthSpiritRemnant:SetTarget(target)
    self.target = target

    self.unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Loop")
end

function EarthSpiritRemnant:RemoveTarget()
    self.target = nil
    self.speed = 0

    self.unit:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
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

function EarthSpiritRemnant:EarthCollision()
    local pos = self:GetPos()
    ImmediateEffectPoint("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, self.owner, pos)
    ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, self.owner, pos)

    GridNav:DestroyTreesAroundPoint(pos, 256, true)
    Spells:MultipleHeroesDamage(self.owner,
        function (source, target)
            local distance = (target:GetPos() - pos):Length2D()

            if target ~= source and target ~= self and distance <= 256 then
                if target:__instanceof__(EarthSpiritRemnant) then
                    target:Destroy()
                    return false
                end

                return true
            end
        end
    )

    EmitSoundOnLocationWithCaster(pos, "Arena.Earth.CastQ", nil)
end

function EarthSpiritRemnant:Cracks()
    local cracks = ParticleManager:CreateParticle("particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil_cracks_sprt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.owner.unit)
    ParticleManager:SetParticleControl(cracks, 0, self:GetPos())
    ParticleManager:SetParticleControl(cracks, 3, self:GetPos())

    Timers:CreateTimer(0.1,
        function()
            ParticleManager:DestroyParticle(cracks, false)
            ParticleManager:ReleaseParticleIndex(cracks)
        end
    )
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
            self:EarthCollision()
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
            self:RemoveTarget()
        else
            self:Cracks()

            local pos = self:GetPos()
            local diff = self.target:GetPos() - pos
            if diff:Length2D() <= self:GetRad() + self.target:GetRad() then

                if self.target:__instanceof__(EarthSpiritRemnant) then
                    self.target:Destroy()
                end

                self:RemoveTarget()
            else
                local velocity = diff:Normalized() * self.speed
                local result = pos + velocity

                self.speed = self.speed + 3

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

function EarthSpiritRemnant:SilentDestroy()
    if self.unit then
        self.unit:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
    end

    self.unit = nil
    self:Destroy()
end

function EarthSpiritRemnant:Remove()
    if self.unit then
        self.unit:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
        self.unit:EmitSound("Arena.Earth.EndQ")
        self.unit:RemoveSelf()
    end

    ParticleManager:DestroyParticle(self.healthCounter, false)
    ParticleManager:ReleaseParticleIndex(self.healthCounter)

    ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_CUSTOMORIGIN, self.owner, self:GetPos())

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