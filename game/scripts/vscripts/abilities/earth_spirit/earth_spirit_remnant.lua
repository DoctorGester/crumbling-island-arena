EarthSpiritRemnant = EarthSpiritRemnant or class({}, nil, UnitEntity)

function EarthSpiritRemnant:constructor(round, owner)
    getbase(EarthSpiritRemnant).constructor(self, round)

    self.owner = owner.owner
    self.hero = owner
    self.health = 2
    self.fell = false
    self.target = nil
    self.speed = 0
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.enemiesHit = {}
end

function EarthSpiritRemnant:CreateCounter()
    self.healthCounter = ParticleManager:CreateParticle("particles/earth_spirit_q/earth_spirit_q_counter.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))
end

function EarthSpiritRemnant:CanFall()
    return self.fell
end

function EarthSpiritRemnant:MakeFall()
    getbase(EarthSpiritRemnant).MakeFall(self)

    if not self.hero.destroyed then
        self.hero:RemnantDestroyed(self)
    end
end

function EarthSpiritRemnant:SetPos(pos)
    getbase(EarthSpiritRemnant).SetPos(self, pos)

    if self.unit then
        self.unit:SetAbsOrigin(pos)
    end

    if self.healthCounter then
        ParticleManager:SetParticleControl(self.healthCounter, 0, self:GetPos() + Vector(0, 0, 200))
    end
end

function EarthSpiritRemnant:SetUnit(unit, fall)
    self.unit = unit
    self.fell = not fall
end

function EarthSpiritRemnant:SetTarget(target)
    self.target = target
    self.collisionType = COLLISION_TYPE_INFLICTOR

    self.unit:EmitSound("Hero_EarthSpirit.RollingBoulder.Loop")
end

function EarthSpiritRemnant:RemoveTarget()
    self.target = nil
    self.speed = 0
    self.collisionType = COLLISION_TYPE_RECEIVER

    self.unit:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
end

function EarthSpiritRemnant:CollideWith(target)
    self.enemiesHit[target] = 30

    target:Damage(self)
end

function EarthSpiritRemnant:CollidesWith(target)
    local hit = self.enemiesHit[target] and self.enemiesHit[target] > 0
    return target ~= self.hero and not hit
end

function EarthSpiritRemnant:EarthCollision()
    local pos = self:GetPos()

    if Spells.TestEntity(self) then
        ImmediateEffectPoint("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, self.hero, pos)
        ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, self.hero, pos)

        self:AreaEffect({
            filter = Filters.And(Filters.Area(pos, 256), Filters.NotEquals(self.hero)),
            damage = true
        })

        GridNav:DestroyTreesAroundPoint(pos, 256, true)
        Spells:GroundDamage(pos, 256)
        
        EmitSoundOnLocationWithCaster(pos, "Arena.Earth.CastQ", nil)
    else
        self.fallingSpeed = 200
    end
end

function EarthSpiritRemnant:Cracks()
    local cracks = ParticleManager:CreateParticle("particles/econ/items/magnataur/shock_of_the_anvil/magnataur_shockanvil_cracks_sprt.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hero.unit)
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
    getbase(EarthSpiritRemnant).Update(self)

    if self.falling then
        return
    end

    if not self.fell then
        local pos = self:GetPos()
        local ground = GetGroundHeight(pos, self.unit)
        local z = math.max(ground, pos.z - 200)
        self:SetPos(Vector(pos.x, pos.y, z))

        if z == ground then
            self.fell = true
            self:EarthCollision()
        end
    end

    if self.hero.remnantStand == self then
        self.hero:SetPos(self:GetPos() + Vector(0, 0, 150))
    end

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

                if instanceof(self.target, EarthSpiritRemnant) then
                    self.target:Destroy()
                end

                self:RemoveTarget()
            else
                local velocity = diff:Normalized() * self.speed
                local result = pos + velocity

                self.speed = self.speed + 3
                self:SetPos(result)
            end
        end
    end
end

function EarthSpiritRemnant:Remove()
    if self.unit then
        self.unit:StopSound("Hero_EarthSpirit.RollingBoulder.Loop")
        self.unit:RemoveSelf()
    end

    ParticleManager:DestroyParticle(self.healthCounter, false)
    ParticleManager:ReleaseParticleIndex(self.healthCounter)

    ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_CUSTOMORIGIN, self.hero, self:GetPos())

    if not self.hero.destroyed then
        self.hero:RemnantDestroyed(self)
    end
end

function EarthSpiritRemnant:Damage(source)
    if instanceof(source, EarthSpiritRemnant) and self.collisionType == COLLISION_TYPE_RECEIVER then
        self.unit:EmitSound("Arena.Earth.EndQ")
        self:Destroy()
        return
    end

    self.health = self.health - 1
    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))

    if self.health == 0 then
        self.unit:EmitSound("Arena.Earth.EndQ")
        self:Destroy()
    end
end