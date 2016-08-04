EarthSpiritRemnant = EarthSpiritRemnant or class({}, nil, UnitEntity)

function EarthSpiritRemnant:constructor(round, owner)
    getbase(EarthSpiritRemnant).constructor(self, round)

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.fell = false
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.enemiesHit = {}
    self.invulnerable = true
    self.targetRemoved = 0
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

function EarthSpiritRemnant:UpdateChildren()
    if self.healthCounter then
        ParticleManager:SetParticleControl(self.healthCounter, 0, self:GetPos() + Vector(0, 0, 200))
    end

    if self.hero.remnantStand == self then
        self.hero:SetPos(self:GetPos() + Vector(0, 0, 150))
    end
end

function EarthSpiritRemnant:FindClearSpace(...)
    getbase(EarthSpiritRemnant).FindClearSpace(self, ...)

    self:UpdateChildren()
end

function EarthSpiritRemnant:SetPos(pos)
    getbase(EarthSpiritRemnant).SetPos(self, pos)

    self:UpdateChildren()
end

function EarthSpiritRemnant:SetUnit(unit, fall)
    getbase(EarthSpiritRemnant).SetUnit(self, unit)

    self.fell = not fall
    self.unit.hero = self
end

function EarthSpiritRemnant:SetTarget(target)
    self.collisionType = COLLISION_TYPE_INFLICTOR

    EarthSpiritRemnantDash(self, target)
end

function EarthSpiritRemnant:RemoveTarget()
    self.targetRemoved = 2

    self.unit:EmitSound("Arena.Earth.EndW")

    self:AreaEffect({
        filter = Filters.Area(self:GetPos(), 256),
        onlyHeroes = true,
        hitAllies = true,
        action = function(target)
            if target ~= self.hero then
                target:FindClearSpace(target:GetPos(), true)
            end
        end
    })
end

function EarthSpiritRemnant:CollideWith(target)
    if self.collisionType == COLLISION_TYPE_INFLICTOR then
        self.enemiesHit[target] = 30

        target:Damage(self)
        target:EmitSound("Arena.Earth.HitW")
    end
end

function EarthSpiritRemnant:CollidesWith(target)
    local hit = self.enemiesHit[target] and self.enemiesHit[target] > 0
    return (not instanceof(target, Hero) or target.owner.team ~= self.owner.team) and not hit
end

function EarthSpiritRemnant:EarthCollision()
    local pos = self:GetPos()

    if self:TestFalling() then
        ImmediateEffectPoint("particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp.vpcf", PATTACH_CUSTOMORIGIN, self.hero, pos)
        ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earth_dust_hit.vpcf", PATTACH_CUSTOMORIGIN, self.hero, pos)

        local allyHeroFilter =
            Filters.WrapFilter(function(target)
                return instanceof(target, EarthSpiritRemnant) or target.owner.team ~= self.owner.team
            end)

        self:AreaEffect({
            filter = Filters.Area(pos, 256) + allyHeroFilter,
            damage = true,
            hitAllies = true
        })

        ScreenShake(pos, 5, 150, 0.25, 2000, 0, true)
        GridNav:DestroyTreesAroundPoint(pos, 256, true)
        Spells:GroundDamage(pos, 256)
        self.invulnerable = false
        
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

    if self.targetRemoved > 0 then
        self.targetRemoved = self.targetRemoved - 1

        if self.targetRemoved == 0 then
            self.collisionType = COLLISION_TYPE_RECEIVER
        end
    end

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

    for target, time in pairs(self.enemiesHit) do
        self.enemiesHit[target] = time - 1
    end
end

function EarthSpiritRemnant:Remove()
    if self.unit then
        self.unit:StopSound("Arena.Earth.CastW.Loop")
        self.unit:RemoveSelf()
    end

    ParticleManager:DestroyParticle(self.healthCounter, true)
    ParticleManager:ReleaseParticleIndex(self.healthCounter)

    ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_CUSTOMORIGIN, self.hero, self:GetPos())

    if not self.hero.destroyed then
        self.hero:RemnantDestroyed(self)
    end
end

function EarthSpiritRemnant:Damage(source)
    if instanceof(source, EarthSpiritRemnant) then
        source.health = source.health + self.health
        ParticleManager:SetParticleControl(source.healthCounter, 1, Vector(0, source.health, 0))

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


EarthSpiritRemnantDash = EarthSpiritRemnantDash or class({}, nil, Dash)

function EarthSpiritRemnantDash:constructor(remnant, target)
    getbase(EarthSpiritRemnantDash).constructor(self, remnant, target:GetPos(), 0, {
        loopingSound = "Arena.Earth.CastW.Loop"
    })

    self.target = target
end

function EarthSpiritRemnantDash:HasEnded()
    local minDistance = 32

    if instanceof(self.target, Hero) then
        minDistance = self.velocity * 3
    end

    return (self.to - self.hero:GetPos()):Length2D() <= minDistance or self.target.destroyed
end

function EarthSpiritRemnantDash:Update()
    getbase(EarthSpiritRemnantDash).Update(self)

    self.hero:Cracks()
    self.velocity = self.velocity + 3
    self.to = self.target:GetPos()
end

function EarthSpiritRemnantDash:End(...)
    getbase(EarthSpiritRemnantDash).End(self, ...)

    self.hero:RemoveTarget()
end