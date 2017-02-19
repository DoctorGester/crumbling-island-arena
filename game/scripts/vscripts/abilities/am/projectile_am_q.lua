ProjectileAMQ = ProjectileAMQ or class({}, nil, Projectile)

function ProjectileAMQ:constructor(round, hero, target, ability, particle, slot, side)
    self.direction = (target * Vector(1, 1, 0) - hero:GetPos() * Vector(1, 1, 0))
    self.perp = Vector(-self.direction.y, self.direction.x, 0):Normalized() * side

	getbase(ProjectileAMQ).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() * Vector(1, 1, 0) + Vector(0, 0, 100) + self.perp * 100,
        to = target * Vector(1, 1, 0) + Vector(0, 0, 100),
        speed = 5000,
        graphics = particle,
        continueOnHit = true,
        disablePrediction = true,
        ability = ability
    })

    self.startTime = GameRules:GetGameTime()
    self.startPosition = self:GetPos()
    self.localTime = self.startTime
    self.distance = self.direction:Length2D()
    self.direction = self.direction:Normalized()
    self.time = 0.75
    self.slot = slot

    hero:GetWearableBySlot(slot):AddEffects(EF_NODRAW)
    hero:DestroySlotVisuals(slot)

    self:EmitSound("Arena.AM.LoopQ")

    self.hitGroup[hero] = self.gracePeriod
    self.hitFunction = function(self, target)
        target:EmitSound("Arena.AM.Hit")
        target:Damage(self, self.ability:GetDamage(), self.isPhysical)

        local direction = (target:GetPos() - self:GetPos()):Normalized()

        FX("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
            cp0 = { ent = target, point = "attach_hitloc" },
            cp0f = direction,
            cp2 = direction * 1000,
            release = true
        })
    end
end

function ProjectileAMQ:SetSecondBlade(blade)
    self.secondBlade = blade
end

function ProjectileAMQ:Update()
	getbase(ProjectileAMQ).Update(self)

    self.localTime = self.localTime + 0.03  * self.currentMultiplier

    if (self.localTime - self.startTime) > self.time + 0.1 then
        self:Destroy()
    end
end

function ProjectileAMQ:Remove()
    getbase(ProjectileAMQ).Remove(self)

    if not self.secondBlade:Alive() then
        self.hero:FindAbility("am_a"):SetActivated(true)
        self.hero:FindAbility("am_e"):SetActivated(true)
        self.hero:FindAbility("am_r"):SetActivated(true)
    end

    self:StopSound("Arena.AM.LoopQ")
    self:EmitSound("Arena.AM.EndQ")

    local wearable = self.hero:GetWearableBySlot(self.slot)
    wearable:RemoveEffects(EF_NODRAW)
    wearable:AddNewModifier(wearable, nil, "modifier_damaged", { duration = 0.4 })

    self.hero:RecreateSlotVisuals(self.slot)
end

function ProjectileAMQ:CalculatePositionLocalSpace()
    local progress = (self.localTime - self.startTime) / self.time
    local yOffset = (4 * 200) * (progress - progress * progress) -- x - x^2
    local eased = EaseOutCircular(progress, 0, 0.55, 1) + progress * 0.45

    return self.direction * eased * self.distance + self.perp * yOffset
end

function ProjectileAMQ:FindClearSpace(position, force)
    self.startPosition = position - self:CalculatePositionLocalSpace()

    getbase(ProjectileAMQ).FindClearSpace(self, position, force)
end

function ProjectileAMQ:Deflect(by, direction)
    direction.z = 0
    self.direction = direction:Normalized()
    self.startPosition = self:GetPos()
    self.startTime = GameRules:GetGameTime()
    self.owner = by.owner
end

function ProjectileAMQ:GetNextPosition()
    return self.startPosition + self:CalculatePositionLocalSpace()
end