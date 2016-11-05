tinker_w = class({})

function tinker_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local facing = hero:GetFacing()
    local from = hero:GetPos() + Vector(-facing.y, facing.x, 0) * 96

    if hero:AreaEffect({
        filter = Filters.Area(target, 300),
        onlyHeroes = true,
        action = function(victim)
            ProjectileTinkerW(hero.round, hero, victim, from):Activate()
        end
    }) then
        hero:EmitSound("Arena.Tinker.CastW")
    else
        hero:EmitSound("Arena.Tinker.MissW")
    end
end

function tinker_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function tinker_w:GetPlaybackRateOverride()
    return 1.33
end

ProjectileTinkerW = ProjectileTinkerW or class({}, nil, HomingProjectile)

function ProjectileTinkerW:constructor(round, hero, target, pos)
    getbase(ProjectileTinkerW).constructor(self, round, {
        owner = hero,
        from = pos + Vector(0, 0, 64),
        radius = 32,
        heightOffset = 64,
        target = target,
        speed = 2800,
        graphics = "particles/tinker_w/tinker_w_rocket.vpcf",
        disablePrediction = true,
        hitSound = "Arena.Tinker.HitW"
    })

    self.distanceToPass = 5000
end

function ProjectileTinkerW:Update()
    local old = self:GetPos()

    getbase(ProjectileTinkerW).Update(self)

    self:SetFacing(self:GetPos() - old)
    self.distanceToPass = self.distanceToPass - (self:GetPos() - old):Length2D()

    if self.distanceToPass <= 0 then
        self:EmitSound(self.hitSound)
        self:Destroy()
    end
end

function ProjectileTinkerW:GetNextPosition(pos)
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

function ProjectileTinkerW:Remove()
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf", PATTACH_ABSORIGIN, self.hero:GetUnit())
    ParticleManager:SetParticleControl(index, 0, self:GetPos())
    ParticleManager:ReleaseParticleIndex(index)

    getbase(ProjectileTinkerW).Remove(self)
end