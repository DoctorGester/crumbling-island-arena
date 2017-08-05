tinker_a = class({})

function tinker_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local facing = hero:GetFacing()
    local from = hero:GetPos() + Vector(-facing.y, facing.x, 0) * 96

    ProjectileTinkerA(hero.round, hero, target, from, self:GetDamage(), self):Activate()

    hero:EmitSound("Arena.Tinker.CastW")
end

function tinker_a:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function tinker_a:GetPlaybackRateOverride()
    return 1.33
end

ProjectileTinkerA = ProjectileTinkerA or class({}, nil, DistanceCappedProjectile)

function ProjectileTinkerA:constructor(round, hero, target, pos, damage, ability)
    getbase(ProjectileTinkerA).constructor(self, round, {
        ability = ability,
        owner = hero,
        from = pos + Vector(0, 0, 64),
        to = target,
        heightOffset = 64,
        speed = 2800,
        distance = 1800, -- No target distance
        graphics = "particles/tinker_w/tinker_w_rocket.vpcf",
        disablePrediction = true,
        hitSound = "Arena.Tinker.HitW",
        damage = damage,
        destroyFunction = function()
            if self.distancePassed > self.distance then
                self:EmitSound(self.hitSound)
            end
        end,
        isPhysical = true
    })

    self.homingDistance = 5000
    self.target = nil
    self.deflectedAt = 0
end

function ProjectileTinkerA:Update()
    local old = self:GetPos()

    getbase(ProjectileTinkerA).Update(self)

    if self.target == nil and GameRules:GetGameTime() - self.deflectedAt > 0.4 then
        local s = self.round.spells
        local closest = s:FindClosest(self:GetPos(), 400, s:FilterEntities(
            function(t) return t.owner.team ~= self.owner.team end,
            s:GetHeroTargets()
        ))

        if closest then
            self.target = closest
            self.distance = self.homingDistance
        end
    elseif self.target and not self.target:Alive() then
        self:Destroy()
    end

    self:SetFacing(self:GetPos() - old)
end

function ProjectileTinkerA:Deflect(by, direction)
    direction.z = 0
    self.target = nil
    self.vel = direction:Normalized() * self.vel:Length2D() * 0.8
    self.deflectedAt = GameRules:GetGameTime()
end

function ProjectileTinkerA:GetNextPosition(pos)
    local normalPos

    if self.target == nil then
        normalPos = getbase(ProjectileTinkerA).GetNextPosition(self, pos)
    end

    local function PortalFilter(p)
        return instanceof(p, EntityTinkerE) and p:Alive() and p.link and p.link:Alive() and p.primary
    end

    local closestPos
    local tpos

    if self.target ~= nil then
        tpos = self.target:GetPos()
        local distance = (pos - tpos):Length2D()

        for _, portal in pairs(self.round.spells:FilterEntities(PortalFilter)) do
            local firstPortal = portal
            local secondPortal = portal.link

            local fdistance = (firstPortal:GetPos() - pos):Length2D()
            local sdistance = (secondPortal:GetPos() - pos):Length2D()
            local closest = nil

            if fdistance < sdistance and not firstPortal:Arrived(self) then
                sdistance = (secondPortal:GetPos() - tpos):Length2D()
                closest = firstPortal
            elseif not secondPortal:Arrived(self) then
                fdistance = (firstPortal:GetPos() - tpos):Length2D()
                closest = secondPortal
            end

            if closest and fdistance + sdistance < distance then
                closestPos = closest:GetPos()
                distance = fdistance + sdistance
            end
        end
    end

    tpos = normalPos or closestPos or tpos

    local v = self.speed * ((tpos - pos) * Vector(1, 1, 0)):Normalized()
    self.vel = 0.98 * self.vel + 0.02 * v

    return pos + self.vel / 30 * self.currentMultiplier
end

function ProjectileTinkerA:Remove()
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_ABSORIGIN, self.hero:GetUnit())
    ParticleManager:SetParticleControl(index, 0, self:GetPos())
    ParticleManager:ReleaseParticleIndex(index)

    ScreenShake(self:GetPos(), 5, 150, 0.25, 3000, 0, true)

    getbase(ProjectileTinkerA).Remove(self)
end

Wrappers.AttackAbility(tinker_a)