Rune = Rune or class({}, nil, UnitEntity)

RuneTypes = {
    HEALING = 0,
    COLD_SNAP = 1,
    LAST = 2
}

local RUNE_MODELS = {
    [RuneTypes.HEALING] = "models/props_gameplay/rune_regeneration01.vmdl",
    [RuneTypes.COLD_SNAP] = "models/props_gameplay/rune_doubledamage01.vmdl"
}

local RUNE_SPAWN_SOUNDS = {
    [RuneTypes.HEALING] = "Arena.RuneHealingSpawn",
    [RuneTypes.COLD_SNAP] = "Arena.RuneBlueSpawn"
}

local RUNE_PARTICLES = {
    [RuneTypes.HEALING] = "particles/rune_particle.vpcf",
    [RuneTypes.COLD_SNAP] = "particles/generic_gameplay/rune_doubledamage.vpcf",
}

local RUNE_COLORS = {
    [RuneTypes.HEALING] = Vector(0, 255, 0),
    [RuneTypes.COLD_SNAP] = Vector(0, 255, 255),
}

function Rune:constructor(round, runeType)
    getbase(Rune).constructor(self, round, DUMMY_UNIT, Vector(0, 0, 0))

    self.owner = { team = 0 }
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER
    self.runeType = runeType

    local unit = self:GetUnit()
    unit:SetModel(RUNE_MODELS[runeType])
    unit:SetOriginalModel(RUNE_MODELS[runeType])
    unit:StartGesture(ACT_DOTA_IDLE)

    self:AddComponent(HealthComponent())
    self:SetCustomHealth(5)
    self:EnableHealthBar()
    self:CreateParticles()
    self:EmitSound(RUNE_SPAWN_SOUNDS[runeType])
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", {})
end

function Rune:CreateParticles()
    self.particle = ParticleManager:CreateParticle(RUNE_PARTICLES[self.runeType], PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.particle, 1, RUNE_COLORS[self.runeType])
    ParticleManager:SetParticleAlwaysSimulate(self.particle)
end

function Rune:Remove()
    getbase(Rune).Remove(self)

    ParticleManager:DestroyParticle(self.particle, false)
    ParticleManager:ReleaseParticleIndex(self.particle)
end

function Rune:Update(...)
    getbase(Rune).Update(self, ...)

    -- Thanks Valve, great tools
    if self.runeType == RuneTypes.COLD_SNAP then
        local currentAngle = (GameRules:GetGameTime() % (math.pi * 2)) * 2.0
        self:GetUnit():SetForwardVector(Vector(math.cos(currentAngle), math.sin(currentAngle)))
    end
end

function Rune:OnDeath(source)
    ScreenShake(self:GetPos(), 5, 150, 0.45, 3000, 0, true)

    local fxPosition = self:GetPos() + Vector(0, 0, 64)

    if self.runeType == RuneTypes.HEALING then
        FX("particles/items3_fx/warmage.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), { cp0 = fxPosition, release = true })
        FX("particles/items3_fx/fish_bones_active.vpcf", PATTACH_ABSORIGIN, GameRules:GetGameModeEntity(), { cp0 = fxPosition, release = true })

        self:EmitSound("Arena.Rune", self:GetPos())
    end

    for _, hero in pairs(self.round.spells:FilterEntities(
        function(target)
            return instanceof(target, Hero) and target:Alive() and source.owner.team == target.owner.team
        end)) do

        if self.runeType == RuneTypes.COLD_SNAP then
            hero:AddNewModifier(hero, nil, "modifier_rune_blue", { duration = 8.0 }):SetStackCount(4)
        elseif self.runeType == RuneTypes.HEALING then
            hero:Heal(4)

            FX("particles/items3_fx/warmage_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, { release = true })
        end
    end

    EmitAnnouncerSound("Announcer.RoundRune")
end

function Rune:CollidesWith(source)
    return true
end

function Rune:CanFall()
    return false
end