TinyW = class({}, nil, DynamicEntity)

function TinyW:constructor(owner, ability, target, bounces, height)
    DynamicEntity.constructor(self)

    self.owner = owner
    self.ability = ability
    self.target = target
    self.start = owner:GetPos()
    self.startTime = GameRules:GetGameTime()
    self.bounces = bounces
    self.height = height
    self.travelTime = 1.2
    self.effectRadius = 200

    self.unit = CreateUnitByName(DUMMY_UNIT, self.start, false, nil, nil, DOTA_TEAM_NOTEAM)
    self.unit:SetForwardVector(target - self.start)

    self.particle = ParticleManager:CreateParticle("particles/tiny_w/tiny_w.vpcf", PATTACH_ABSORIGIN_FOLLOW , self.unit)

    self:SetInvulnerable(true)
    self:SetPos(self.start)

    CreateAOEMarker(owner, target, self.effectRadius, self.travelTime)
end

function TinyW:Update()
    local time = GameRules:GetGameTime() - self.startTime
    local progress = math.min(time / self.travelTime, 1.0)
    local delta = self.target - self.start
    local dir = delta:Normalized() * (progress * delta:Length())
    local height = ParabolaZ(self.height, delta:Length(), dir:Length())
    local result = self.start + dir

    self:SetPos(result + Vector(0, 0, height))

    self.unit:SetAbsOrigin(self:GetPos())

    if progress == 1.0 then
        local effectPosition = self:GetPos()
        effectPosition.z = GetGroundHeight(effectPosition, self.unit)
        ImmediateEffectPoint("particles/tiny_w/tiny_w_explode.vpcf", PATTACH_ABSORIGIN, self.owner, effectPosition)

        GridNav:DestroyTreesAroundPoint(result, self.effectRadius, false)

        Spells:AreaModifier(self.owner, self.ability, "modifier_stunned", { duration = 1.2 }, effectPosition, self.effectRadius,
            function (hero, target)
                return hero ~= target
            end
        )

        Spells:AreaDamage(self.owner, effectPosition, self.effectRadius)

        self.owner:EmitSound("Arena.Tiny.HitW")

        if self.bounces > 0 then
            self.start = self.position
            self.target = self.target + delta:Normalized() * delta:Length() / 2
            self.height = self.height / 2
            self.bounces = self.bounces - 1
            self.startTime = GameRules:GetGameTime()
            self.travelTime = self.travelTime * 0.75

            self.target.z = GetGroundHeight(self.target, self.unit)

            CreateAOEMarker(self.owner, self.target, self.effectRadius, self.travelTime)
        else
            self:Destroy()
        end
    end
end

function TinyW:Remove()
    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)

    self.unit:RemoveSelf()
end
