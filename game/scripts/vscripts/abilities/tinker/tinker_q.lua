tinker_q = class({})

function tinker_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local facing = hero:GetFacing()
    local from = hero:GetPos() + Vector(-facing.y, facing.x, 0) * 96

    if hero:AreaEffect({
        filter = Filters.Area(target, 300),
        onlyHeroes = true,
        action = function(victim)
            ProjectileTinkerQ(hero.round, hero, victim, from, self:GetDamage()):Activate()
        end
    }) then
        hero:EmitSound("Arena.Tinker.CastW")
    else
        hero:EmitSound("Arena.Tinker.MissW")
    end
end

function tinker_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function tinker_q:GetPlaybackRateOverride()
    return 1.33
end

ProjectileTinkerQ = ProjectileTinkerQ or class({}, nil, HomingProjectile)

function ProjectileTinkerQ:constructor(round, hero, target, pos, damage)
    getbase(ProjectileTinkerQ).constructor(self, round, {
        ability = self,
        owner = hero,
        from = pos + Vector(0, 0, 64),
        radius = 32,
        heightOffset = 64,
        target = target,
        speed = 2800,
        graphics = "particles/tinker_w/tinker_w_rocket.vpcf",
        disablePrediction = true,
        hitSound = "Arena.Tinker.HitW",
        damage = damage
    })

    self.distanceToPass = 5000
end

function ProjectileTinkerQ:Update()
    local old = self:GetPos()

    getbase(ProjectileTinkerQ).Update(self)

    self:SetFacing(self:GetPos() - old)
    self.distanceToPass = self.distanceToPass - (self:GetPos() - old):Length2D()

    if self.distanceToPass <= 0 then
        self:EmitSound(self.hitSound)
        self:Destroy()
    end
end

function ProjectileTinkerQ:Deflect(by, direction)
    self.vel = direction:Normalized() * self.vel:Length()
end

function ProjectileTinkerQ:GetNextPosition(pos)
    local function PortalFilter(p)
        return instanceof(p, EntityTinkerE) and p:Alive() and p.link and p.link:Alive() and p.primary
    end

    local tpos = self.target:GetPos()
    local distance = (pos - tpos):Length2D()
    local closestPos = nil

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

    tpos = closestPos or tpos

    local v = self.speed * ((tpos - pos) * Vector(1, 1, 0)):Normalized()
    self.vel = 0.98 * self.vel + 0.02 * v

    return pos + self.vel / 30 * self.currentMultiplier
end

function ProjectileTinkerQ:Remove()
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_ABSORIGIN, self.hero:GetUnit())
    ParticleManager:SetParticleControl(index, 0, self:GetPos())
    ParticleManager:ReleaseParticleIndex(index)

    getbase(ProjectileTinkerQ).Remove(self)
end