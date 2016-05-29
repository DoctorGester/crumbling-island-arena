JuggerWard = class({}, nil, UnitEntity)

function JuggerWard:constructor(round, owner, target, ability)
    getbase(JuggerWard).constructor(self, round, "jugger_ward", target, owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.health = 1
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    unit.hero = self

    self:CreateParticles()
    self:AddNewModifier(self.hero, ability, "modifier_jugger_w", { duration = 4 })
    self:AddNewModifier(self.hero, ability, "modifier_jugger_w_visual", {})
    self:SetPos(target)

    self:EmitSound("Arena.Jugger.CastW")
    self:EmitSound("Arena.Jugger.LoopW")
end

function JuggerWard:CreateParticles()
    self.rangeIndicator = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.rangeIndicator, 1, Vector(400, 1, 1))
    ParticleManager:SetParticleControl(self.rangeIndicator, 2, Vector(0, 255, 74))
    ParticleManager:SetParticleControl(self.rangeIndicator, 3, Vector(10, 0, 0))

    self.flameParticle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControlEnt(self.flameParticle, 0, self:GetUnit(), PATTACH_POINT_FOLLOW, "flame_attachment", self:GetUnit():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.flameParticle, 1, Vector(400, 1, 1))
    ParticleManager:SetParticleControlEnt(self.flameParticle, 2, self:GetUnit(), PATTACH_POINT_FOLLOW, "flame_attachment", self:GetUnit():GetAbsOrigin(), true)
end

function JuggerWard:Remove()
    self:StopSound("Arena.Jugger.LoopW")
    self:EmitSound("Arena.Jugger.EndW")

    getbase(JuggerWard).Remove(self)

    ParticleManager:DestroyParticle(self.rangeIndicator, false)
    ParticleManager:ReleaseParticleIndex(self.rangeIndicator)

    ParticleManager:DestroyParticle(self.flameParticle, false)
    ParticleManager:ReleaseParticleIndex(self.flameParticle)

    local particle = ParticleManager:CreateParticle("particles/jugger_w/jugger_w_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(particle)
    self.hero:Heal()
end

function JuggerWard:Damage(source)
    self:Destroy()
end

function JuggerWard:CollidesWith(source)
    return true
end