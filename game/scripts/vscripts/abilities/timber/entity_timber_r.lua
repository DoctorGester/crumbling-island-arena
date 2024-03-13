EntityTimberR = EntityTimberR or class({}, nil, UnitEntity)

function EntityTimberR:constructor(round, owner, position, ability)
    getbase(EntityTimberR).constructor(self, round, "timber_cog", position, owner:GetUnit():GetTeamNumber(), true)

    self.hero = owner
    self.owner = owner.owner
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.removeOnDeath = false
    self.startTime = GameRules:GetGameTime()
    self.ability = ability
    self.unit = self:GetUnit()

    self:AddNewModifier(owner.unit, ability, "modifier_timber_r", {})
    self:AddNewModifier(self:GetUnit(), ability, "modifier_timber_r_aura", {})

    self:EmitSound("Arena.Timber.ActivatingR")
    self:AddComponent(HealthComponent())
    self:SetCustomHealth(4)
    self:EnableHealthBar()

    StartAnimation(self:GetUnit(), { duration = 6.0, activity = ACT_DOTA_IDLE, rate = 2.0 })
end

function EntityTimberR:Update()
    getbase(EntityTimberR).Update(self)

    if self.falling then
        return
    end

    if GameRules:GetGameTime() - (self.startTime or 0) > 6 then
        self:Destroy()
    end
end