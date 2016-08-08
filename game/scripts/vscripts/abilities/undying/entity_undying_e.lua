EntityUndyingE = EntityUndyingE or class({}, nil, UnitEntity)

function EntityUndyingE:constructor(round, owner, position, ability)
    getbase(EntityUndyingE).constructor(self, round, "undying_tombstone", position, owner:GetUnit():GetTeamNumber(), true)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.removeOnDeath = false
    self.size = 96

    self:AddNewModifier(owner.unit, ability, "modifier_undying_e", { duration = 6.0 })
    self:AddNewModifier(self:GetUnit(), ability, "modifier_undying_e_aura", {})
    self:EmitSound("Arena.Undying.CastE")
end

function EntityUndyingE:Damage(source)
    self:Destroy()
end

function EntityUndyingE:Update()
    getbase(EntityUndyingE).Update(self)

    if not self:Alive() then
        self:Destroy()
    end
end

function EntityUndyingE:Alive()
    return IsValidEntity(self:GetUnit()) and self:GetUnit():IsAlive()
end

function EntityUndyingE:Damage(source)
    if not self:Alive() or self.falling then
        return
    end

    local damageTable = {
        victim = self.unit,
        attacker = source.unit,
        damage = 1,
        damage_type = DAMAGE_TYPE_PURE,
    }

    ApplyDamage(damageTable)

    local sign = ParticleManager:CreateParticle("particles/msg_fx/msg_damage.vpcf", PATTACH_CUSTOMORIGIN, mode)
    ParticleManager:SetParticleControl(sign, 0, self:GetPos())
    ParticleManager:SetParticleControl(sign, 1, Vector(0, 1, 3))
    ParticleManager:SetParticleControl(sign, 2, Vector(2, 2, 0))
    ParticleManager:SetParticleControl(sign, 3, Vector(200, 0, 0))
    ParticleManager:ReleaseParticleIndex(sign)
end
