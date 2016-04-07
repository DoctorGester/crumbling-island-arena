TinyW = TinyW or class({}, nil, UnitEntity)

function TinyW:constructor(round, owner, ability, target, bounces, height)
    getbase(TinyW).constructor(self, round, DUMMY_UNIT, owner:GetPos())

    self.owner = owner.owner
    self.hero = owner
    self.ability = ability
    self.target = target
    self.start = owner:GetPos()
    self.startTime = GameRules:GetGameTime()
    self.bounces = bounces
    self.height = height
    self.travelTime = 1.2
    self.effectRadius = 200
    self.fallingDirection = nil

    self:SetFacing(target - self.start)

    self.particle = ParticleManager:CreateParticle("particles/tiny_w/tiny_w.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)

    self.removeOnDeath = true
    self:SetInvulnerable(true)
    self:SetPos(self.start)

    CreateAOEMarker(self, target, self.effectRadius, self.travelTime)
end

function TinyW:CanFall()
    return false
end

function TinyW:Update()
    getbase(TinyW).Update(self)

    if self.falling then
        self:SetPos(self:GetPos() + self.fallingDirection)
        return
    end

    local time = GameRules:GetGameTime() - self.startTime
    local progress = time / self.travelTime
    local delta = self.target - self.start
    local dir = delta:Normalized() * (progress * delta:Length())
    local height = ParabolaZ(self.height, delta:Length(), dir:Length())
    local result = self.start + dir
    local prevPos = self:GetPos()

    self:SetPos(result + Vector(0, 0, height))

    if progress >= 1.0 then
        local effectPosition = self:GetPos()

        if not Spells.TestPoint(effectPosition, self:GetUnit()) then
            self.falling = true
            self.fallingDirection = self:GetPos() - prevPos
            return
        end

        effectPosition.z = GetGroundHeight(effectPosition, self.unit)
        ImmediateEffectPoint("particles/tiny_w/tiny_w_explode.vpcf", PATTACH_ABSORIGIN, self, effectPosition)

        GridNav:DestroyTreesAroundPoint(result, self.effectRadius, false)

        self.hero:AreaEffect({
            filter = Filters.Area(effectPosition, self.effectRadius),
            damage = true,
            modifier = { name = "modifier_stunned_lua", duration = 1.2, ability = self.ability },
        })

        print("shake shake baby")
        ScreenShake(effectPosition, 5, 150, 0.25, 2000, 0, true)
        Spells:GroundDamage(effectPosition, self.effectRadius)

        self:EmitSound("Arena.Tiny.HitW")

        if self.bounces > 0 then
            self.start = self.position
            self.target = self.target + delta:Normalized() * delta:Length() / 2
            self.height = self.height / 2
            self.bounces = self.bounces - 1
            self.startTime = GameRules:GetGameTime()
            self.travelTime = self.travelTime * 0.75

            self.target.z = GetGroundHeight(self.target, self.unit)

            CreateAOEMarker(self, self.target, self.effectRadius, self.travelTime)
        else
            self:Destroy()
        end
    end
end

function TinyW:Remove()
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    getbase(TinyW).Remove(self)
end
