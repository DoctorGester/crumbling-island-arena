EntityTinkerR = EntityTinkerR or class({}, nil, BreakableEntity)

function EntityTinkerR:constructor(round, owner, position, ability)
    getbase(EntityTinkerR).constructor(self, round, "tinker_cog", position, owner:GetUnit():GetTeamNumber(), true)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.removeOnDeath = false

    self:AddNewModifier(owner.unit, ability, "modifier_tinker_r", {})
    self:EmitSound("Arena.Sniper.CastW")
    self:SetCustomHealth(3)
    self:EnableHealthBar()
end