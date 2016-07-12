EntityTinkerR = EntityTinkerR or class({}, nil, UnitEntity)

function EntityTinkerR:constructor(round, owner, position, ability)
    getbase(EntityTinkerR).constructor(self, round, "tinker_cog", position, owner:GetUnit():GetTeamNumber(), true)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.removeOnDeath = false

    self:AddNewModifier(owner.unit, ability, "modifier_tinker_r", {})
    self:EmitSound("Arena.Sniper.CastW")
end

function EntityTinkerR:Damage(source)
    self:Destroy()
end