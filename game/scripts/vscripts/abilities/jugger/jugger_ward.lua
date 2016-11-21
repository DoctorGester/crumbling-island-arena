JuggerWard = JuggerWard or class({}, nil, BreakableEntity)

function JuggerWard:constructor(round, owner, target, ability)
    getbase(JuggerWard).constructor(self, round, "jugger_ward", target, owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.size = 64
    self.removeOnDeath = false
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    unit.hero = self

    self:CreateParticles()
    self:AddNewModifier(self.hero, ability, "modifier_jugger_w", { duration = 2.8 })
    self:AddNewModifier(self.hero, ability, "modifier_jugger_w_visual", {})
    self:SetPos(target)

    self:EmitSound("Arena.Jugger.CastW")
    self:EmitSound("Arena.Jugger.LoopW")

    self:SetCustomHealth(3)
    self:EnableHealthBar()

    if owner:IsAwardEnabled() then
        local model = "models/items/juggernaut/ward/dc_wardupate/dc_wardupate.vmdl"
        self:GetUnit():SetOriginalModel(model)
        self:GetUnit():SetModel(model)
    end

    self.nextHealAt = GameRules:GetGameTime() + 0.9
end

function JuggerWard:CreateParticles()
    self.rangeIndicator = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.rangeIndicator, 1, Vector(400, 1, 1))
    ParticleManager:SetParticleControl(self.rangeIndicator, 2, Vector(0, 255, 74))
    ParticleManager:SetParticleControl(self.rangeIndicator, 3, Vector(10, 0, 0))

    self.flameParticle = ParticleManager:CreateParticle("particles/econ/items/juggernaut/jugg_fortunes_tout/jugg_healling_ward_fortunes_tout_ward.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControlEnt(self.flameParticle, 0, self:GetUnit(), PATTACH_POINT_FOLLOW, "flame_attachment", self:GetUnit():GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(self.flameParticle, 1, Vector(400, 1, 1))
    ParticleManager:SetParticleControlEnt(self.flameParticle, 2, self:GetUnit(), PATTACH_POINT_FOLLOW, "flame_attachment", self:GetUnit():GetAbsOrigin(), true)
end

function JuggerWard:Update()
    getbase(JuggerWard).Update(self)

    if GameRules:GetGameTime() >= self.nextHealAt then
        self:AreaEffect({
            filter = Filters.Area(self:GetPos(), 400) + Filters.WrapFilter(function(v) return v.owner.team == self.owner.team end),
            filterProjectiles = true,
            hitAllies = true,
            action = function(victim)
                victim:Heal(1)
            end
        })

        self.nextHealAt = self.nextHealAt + 0.9
    end
end

function JuggerWard:Remove()
    self:StopSound("Arena.Jugger.LoopW")
    self:EmitSound("Arena.Jugger.EndW")

    getbase(JuggerWard).Remove(self)

    ParticleManager:DestroyParticle(self.rangeIndicator, false)
    ParticleManager:ReleaseParticleIndex(self.rangeIndicator)

    ParticleManager:DestroyParticle(self.flameParticle, false)
    ParticleManager:ReleaseParticleIndex(self.flameParticle)
end

function JuggerWard:OnDeath()
    self.damaged = true
end

function JuggerWard:CollidesWith(source)
    return true
end