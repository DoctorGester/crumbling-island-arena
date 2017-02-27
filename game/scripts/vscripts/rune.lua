Rune = Rune or class({}, nil, UnitEntity)

function Rune:constructor(round)
    getbase(Rune).constructor(self, round, DUMMY_UNIT, Vector(0, 0, 0))

    self.owner = { team = 0 }
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    unit:SetModel("models/props_gameplay/rune_regeneration01.vmdl")
    unit:SetOriginalModel("models/props_gameplay/rune_regeneration01.vmdl")
    unit:StartGesture(ACT_DOTA_IDLE)

    self:AddComponent(HealthComponent())
    self:SetCustomHealth(6)
    self:EnableHealthBar()
    self:CreateParticles()
    self:EmitSound("Arena.RuneSpawn")
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", {})
end

function Rune:CreateParticles()
    self.particle = ParticleManager:CreateParticle("particles/rune_particle.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(0, 255, 0))
end

function Rune:Remove()
    getbase(Rune).Remove(self)

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function Rune:OnDeath(source)
    FX("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), { cp0 = self:GetPos() + Vector(0, 0, 64), release = true })
    FX("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), { cp0 = self:GetPos() + Vector(0, 0, 64), release = true })
    ScreenShake(self:GetPos(), 5, 150, 0.45, 3000, 0, true)

    for _, hero in pairs(self.round.spells:FilterEntities(
        function(target)
            return instanceof(target, Hero) and target:Alive() and source.owner.team == target.owner.team
        end)) do

        hero:Heal(5)

        FX("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })
    end

    self:EmitSound("Arena.Rune")

    EmitAnnouncerSound("Announcer.RoundRune")
end

function Rune:CollidesWith(source)
    return true
end

function Rune:CanFall()
    return false
end