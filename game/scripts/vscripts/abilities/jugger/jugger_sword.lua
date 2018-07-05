JuggerSword = class({}, nil, UnitEntity)

function JuggerSword:constructor(round, owner, target, particle)
    getbase(JuggerSword).constructor(self, round, "jugg_sword", target, owner.unit:GetTeamNumber(), false, owner.owner)

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.size = 64
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.invulnerable = true

    local unit = self:GetUnit()
    unit.hero = self

    self.particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.unit)
    self:SetPos(target)
    self:EmitSound("Arena.Jugger.SwordAppear")

    self.playerParticle = ParticleManager:CreateParticleForTeam(
        "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5_core_rays.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self.unit,
        self.owner.team
    )
end

function JuggerSword:Remove()
    getbase(JuggerSword).Remove(self)

    if self.hero:Alive() then
        self.hero:SwordOnLevelDestroyed()
        self.hero:StartSwordTimer()
    end

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function JuggerSword:SetParticle(particle)
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, true)
        ParticleManager:ReleaseParticleIndex(self.particle)
    end

    self.particle = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.unit)
end

function JuggerSword:Damage(source)
end

function JuggerSword:CollidesWith(source)
    return source == self.hero
end

function JuggerSword:CollideWith(target)
    if target == self.hero then
        target:SwordPickedUp()
        target:EmitSound("Arena.Jugger.Pick")
        self:Destroy()
    end
end

function JuggerSword:CanFall(source)
    return true
end