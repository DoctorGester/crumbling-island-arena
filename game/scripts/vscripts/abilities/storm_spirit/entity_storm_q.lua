EntityStormQ = EntityStormQ or class({}, nil, UnitEntity)

function EntityStormQ:constructor(round, owner, position, facing)
    getbase(EntityStormQ).constructor(self, round, owner:GetName(), position)

    self.hero = owner
    self.owner = owner.owner
    self.invulnerable = true

    self:AddNewModifier(self, nil, "modifier_storm_spirit_remnant", {})
    self:EmitSound("Arena.Storm.HitQ")
    self:SetFacing(facing)

    self.rangeIndicator = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetUnit())
    ParticleManager:SetParticleControl(self.rangeIndicator, 1, Vector(300, 1, 1))
    ParticleManager:SetParticleControl(self.rangeIndicator, 2, Vector(67, 204, 250))
    ParticleManager:SetParticleControl(self.rangeIndicator, 3, Vector(600, 0, 0))
end

function EntityStormQ:Update()
    getbase(EntityStormQ).Update(self)

    if not self.hero:Alive() then
        self:Destroy()
    end
end

function EntityStormQ:Remove()
    self:EmitSound("Arena.Storm.EndQ")
    self.hero:RemoveRemnant(self)

    ParticleManager:DestroyParticle(self.rangeIndicator, false)
    ParticleManager:ReleaseParticleIndex(self.rangeIndicator)

    getbase(EntityStormQ).Remove(self)
end