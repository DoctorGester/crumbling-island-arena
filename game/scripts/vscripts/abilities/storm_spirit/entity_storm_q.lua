EntityStormQ = EntityStormQ or class({}, nil, UnitEntity)

function EntityStormQ:constructor(round, owner, position, facing)
    getbase(EntityStormQ).constructor(self, round, owner:GetName(), position)

    self.hero = owner
    self.owner = owner.owner
    self.invulnerable = true

    self:AddNewModifier(self, nil, "modifier_storm_spirit_remnant", {})
    self:EmitSound("Hero_StormSpirit.StaticRemnantPlant")
    self:SetFacing(facing)
end

function EntityStormQ:Remove()
    self:EmitSound("Hero_StormSpirit.StaticRemnantExplode")
    getbase(EntityStormQ).Remove(self)
end