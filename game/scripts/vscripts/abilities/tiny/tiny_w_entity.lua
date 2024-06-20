TinyW = TinyW or class({}, nil, ArcProjectile)

function TinyW:constructor(round, owner, ability, damage, target, bounces, height)
    getbase(TinyW).constructor(self,round, {
        ability = self,
        owner = owner,
        from = owner:GetPos(),
        to = target,
        graphics = "particles/tiny_w/tiny_w.vpcf",
        arc = height,
    })

    self.bounces = bounces
    self.effectRadius = 200
    self.Traveltime = 0.85
    self.damage = damage
    self.speed = (self.to - self.from):Length2D() / self.Traveltime
    self.arc = height

    CreateEntityAOEMarker(self.to, self.effectRadius, (self.to - self.from):Length2D() / self.speed, { 255, 255, 255 }, 0.65, true)
end

function TinyW:Update()
    getbase(ArcProjectile).Update(self)

    local pos = self:GetPos()

    if self.falling then
        self:SetPos(self:GetPos() + self.fallingDirection)
        self:SetFacing(self:GetPos() - pos)
        return
    end

    if IsOutOfTheMap(pos) then
        self:Destroy()
        return
    end

    self:SetPos(self:GetNextPosition(pos))

    local initialD = (self.to - pos):Length2D()
    local resultD = (self.to - self:GetPos()):Length2D()

    if (self.to - self:GetPos()):Length() <= self:GetSpeed() / 30 or resultD >= initialD then
        if not Spells.TestPoint(self:GetPos()) then
            self.falling = true
            self.fallingDirection = self:GetPos() - pos
            return
        end

        self:hitFunction()
    end
end

function TinyW:hitFunction()
    local effectPosition = self:GetPos()

    self:EmitSound("Arena.Tiny.HitW")

    ScreenShake(effectPosition, 5, 150, 0.25, 2000, 0, true)
    Spells:GroundDamage(effectPosition, self.effectRadius, self.hero, false, 0.5)

    effectPosition.z = GetGroundHeight(effectPosition, self.unit)
    ImmediateEffectPoint("particles/tiny_w/tiny_w_explode.vpcf", PATTACH_ABSORIGIN, self, effectPosition)

    GridNav:DestroyTreesAroundPoint(self:GetPos() + (self.to - self.from):Normalized() * self.speed / 30, self.effectRadius, false)

    self.hero:AreaEffect({
        ability = self.ability,
        filter = Filters.Area(effectPosition, self.effectRadius),
        damage = self.damage,
        modifier = { name = "modifier_stunned_lua", duration = 0.7, ability = self.ability },
    })

    if self.bounces > 0 then
        local delta = self.to - self.from

        self.damage = math.max(self.damage - 1, 1)
        self.from = self.position
        self.to = self.to + delta:Normalized() * delta:Length() / 2
        self.arc = self.arc / 2
        self.bounces = self.bounces - 1
        self.speed = self.speed * (self.Traveltime * 0.75)
        self.to.z = GetGroundHeight(self.to, self.unit)

        CreateEntityAOEMarker(self.to, self.effectRadius, (self.from - self.to):Length2D() / self.speed + 0.1, { 255, 255, 255 }, 0.65, true)
    else
        self:Destroy()
    end
end

function TinyW:GetNextPosition(pos)
    local result = pos + ((self.to - self.from):Normalized() * (self:GetSpeed() / 30))
    local d = (self.from - self.to):Length2D()
    local x = (self.from - result):Length2D()

    result.z = ParabolaZ(self.arc, d, x)

    return result
end
