Rune = Rune or class({}, nil, UnitEntity)

function Rune:constructor(round)
    getbase(Rune).constructor(self, round, DUMMY_UNIT, Vector(0, 0, 0))

    self.owner = { team = 0 }
    self.health = 3
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    unit:SetModel("models/props_gameplay/rune_regeneration01.vmdl")
    unit:SetOriginalModel("models/props_gameplay/rune_regeneration01.vmdl")
    unit:StartGesture(ACT_DOTA_IDLE)
    
    self:CreateParticles()
    self:EmitSound("Arena.RuneSpawn")
end

function Rune:CreateParticles()
    self.healthCounter = ParticleManager:CreateParticle("particles/generic_counter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))
    ParticleManager:SetParticleControl(self.healthCounter, 2, Vector(255, 255, 255))

    self.particle = ParticleManager:CreateParticle("particles/generic_gameplay/rune_regeneration.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.particle, 1, Vector(0, 255, 0))
end

function Rune:Remove()
    getbase(Rune).Remove(self)

    ParticleManager:DestroyParticle(self.healthCounter, false)
    ParticleManager:ReleaseParticleIndex(self.healthCounter)

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function Rune:Damage(source)
    self.health = self.health - 1

    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))

    if self.health == 0 then
        FX("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), { cp0 = self:GetPos() + Vector(0, 0, 64), release = true })
        FX("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), { cp0 = self:GetPos() + Vector(0, 0, 64), release = true })

        for _, hero in pairs(self.round.spells:FilterEntities(
            function(target)
                return source.owner.team == target.owner.team
            end, self.round.spells:GetHeroTargets())) do
            hero:Heal()

            FX("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })
        end
        
        self:EmitSound("Arena.Rune")
        self:Destroy()
    end
end

function Rune:CollidesWith(source)
    return true
end

function Rune:CanFall()
    return false
end