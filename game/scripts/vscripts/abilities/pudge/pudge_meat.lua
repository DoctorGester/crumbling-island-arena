PudgeMeat = PudgeMeat or class({}, nil, UnitEntity)

PudgeMeat.USE_PARTICLE = "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf"

function PudgeMeat:constructor(round, owner, target)
    getbase(PudgeMeat).constructor(self, round, DUMMY_UNIT, target, owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.size = 64
    self.collisionType = COLLISION_TYPE_INFLICTOR

    local unit = self:GetUnit()
    unit.hero = self

    self.particle = ParticleManager:CreateParticle("particles/pudge_meat/pudge_meat.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    self:SetPos(target)
end

function PudgeMeat:Remove()
    getbase(PudgeMeat).Remove(self)

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function PudgeMeat:Damage(source)
end

function PudgeMeat:CollidesWith(source)
    return instanceof(source, Pudge) or instanceof(source, ProjectilePudgeQ)
end

function PudgeMeat:CollideWith(target)
    if instanceof(target, Pudge)then
        local particle = ParticleManager:CreateParticle(PudgeMeat.USE_PARTICLE, PATTACH_ABSORIGIN_FOLLOW, target:GetUnit())
        ParticleManager:SetParticleControl(particle, 1, target:GetPos())
        ParticleManager:ReleaseParticleIndex(particle)

        target:EmitSound("Arena.Pudge.Meat.Voice")
        target:EmitSound("Arena.Pudge.Meat")
        target:Heal()
        self:Destroy()
    end
end

function PudgeMeat:CanFall(source)
    return true
end