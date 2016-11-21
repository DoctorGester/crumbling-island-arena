EntityUndyingE = EntityUndyingE or class({}, nil, BreakableEntity)

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

    self:SetCustomHealth(5)
    self:EnableHealthBar()
end