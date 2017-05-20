SniperShrapnel = SniperShrapnel or class({}, nil, UnitEntity)

function SniperShrapnel:constructor(round, owner, target, ability)
    getbase(SniperShrapnel).constructor(self, round, DUMMY_UNIT, target, owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.removeOnDeath = false
    self.collisionType = COLLISION_TYPE_NONE
    self.ability = ability

    self:AddNewModifier(self.hero, ability, "modifier_sniper_q", {})
    self:SetPos(target)
    self:SetInvulnerable(true)
    self:EmitSound("Arena.Sniper.LoopQ")

    self:AddComponent(PlayerCircleComponent(400, false, 0.8))

    self.ticksPassed = 0
    self.nextDamageAt = GameRules:GetGameTime() + 1.2

    self.particle = FX("particles/units/heroes/hero_sniper/sniper_shrapnel.vpcf", PATTACH_WORLDORIGIN, self.hero, {
        cp0 = target,
        cp1 = Vector(400, 0, 0),
        cp2 = target,
        release = false
    })
end

function SniperShrapnel:Update()
    getbase(SniperShrapnel).Update(self)

    if GameRules:GetGameTime() >= self.nextDamageAt then
        if self.ticksPassed == 2 then
            self:Destroy()
        else
            self:AreaEffect({
                ability = self.ability,
                filter = Filters.Area(self:GetPos(), 400),
                damage = self.ability:GetDamage()
            })

            self.nextDamageAt = self.nextDamageAt + 1.2
            self.ticksPassed = self.ticksPassed + 1
        end
    end
end

function SniperShrapnel:Remove()
    self:StopSound("Arena.Sniper.LoopQ")

    getbase(SniperShrapnel).Remove(self)

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end