EntityUndyingE = EntityUndyingE or class({}, nil, BreakableEntity)

function EntityUndyingE:constructor(round, owner, position, ability)
    getbase(EntityUndyingE).constructor(self, round, "undying_tombstone", position, owner:GetUnit():GetTeamNumber(), true)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.removeOnDeath = false
    self.size = 96
    self.startTime = GameRules:GetGameTime()

    self:AddNewModifier(owner.unit, ability, "modifier_undying_e", {})
    self:AddNewModifier(self:GetUnit(), ability, "modifier_undying_e_aura", {})
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", {})
    self:EmitSound("Arena.Undying.CastE")

    self:SetCustomHealth(4)
    self:EnableHealthBar()

    self:GetUnit():SetControllableByPlayer(self.owner.id, true)
end

function EntityUndyingE:Update()
    getbase(EntityUndyingE).Update(self)

    if GameRules:GetGameTime() - (self.startTime or 0) > 6 then
        self:Destroy()
    end
end
