EntityStormQ = EntityStormQ or class({}, nil, WearableOwner)

function EntityStormQ:constructor(round, owner, position, facing, ability)
    getbase(EntityStormQ).constructor(self, round, owner:GetName(), position)

    self.hero = owner
    self.owner = owner.owner
    self.invulnerable = true
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.size = 200
    self.ability = ability

    self:AddNewModifier(self, nil, "modifier_storm_spirit_remnant", {})
    self:EmitSound("Arena.Storm.HitQ")
    self:SetFacing(facing)

    self:LoadItems()

    self.playerParticle = ParticleManager:CreateParticleForTeam(
        "particles/storm_q/storm_q_hat.vpcf",
        PATTACH_ABSORIGIN_FOLLOW,
        self:GetUnit(),
        self.owner.team
    )
end

function EntityStormQ:CollidesWith(target)
    return self.owner.team ~= target.owner.team and instanceof(target, Hero)
end

function EntityStormQ:Update()
    getbase(EntityStormQ).Update(self)

    if not self.hero:Alive() then
        self:Destroy()
    elseif self.explosionStart ~= nil and GameRules:GetGameTime() - self.explosionStart > 1.0 then
        self.hero:AreaEffect({
            filter = Filters.Area(self:GetPos(), 275),
            damage = self.ability:GetDamage()
        })

        self:Destroy()
    end
end

function EntityStormQ:CollideWith()
    self.rangeIndicator = ParticleManager:CreateParticle("particles/storm_q/storm_q_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetUnit())
    ParticleManager:SetParticleControl(self.rangeIndicator, 1, Vector(275, 1, 1))

    self.collisionType = COLLISION_TYPE_NONE
    self.explosionStart = GameRules:GetGameTime()
    self:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.7)
    self:EmitSound("Arena.Storm.LoopQ")
end

function EntityStormQ:Remove()
    self:EmitSound("Arena.Storm.EndQ")
    self.hero:RemoveRemnant(self)

    if self.rangeIndicator then
        ParticleManager:DestroyParticle(self.rangeIndicator, false)
        ParticleManager:ReleaseParticleIndex(self.rangeIndicator)
    end

    self:StopSound("Arena.Storm.LoopQ")

    getbase(EntityStormQ).Remove(self)
end