EntityPugnaW = EntityPugnaW or class({}, nil, UnitEntity)

function EntityPugnaW:constructor(round, owner, position)
    getbase(EntityPugnaW).constructor(self, round, DUMMY_UNIT, position)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_NONE
    self.invulnerable = true
    self.removeOnDeath = false
    self.size = 96

    self:AddNewModifier(owner.unit, self, "modifier_pugna_w", {})
    self:EmitSound("Arena.Pugna.CastW")
    self:GetUnit().entity = self
end

function EntityPugnaW:CollidesWith(target)
    return instanceof(target, Hero)
end

function EntityPugnaW:CollideWith(target)
    if self.hero:IsReversed() then
        target:Damage(self.hero)
    else
        target:Heal()
    end

    local effect = ImmediateEffectPoint("particles/pugna_w/pugna_w_explode.vpcf", PATTACH_ABSORIGIN, self, self:GetPos())
    ParticleManager:SetParticleControl(effect, 2, self.hero:GetTrapColor())

    self:EmitSound("Arena.Pugna.HitW")
    target:EmitSound(self.hero:GetTrapSound())

    self:Destroy()
end