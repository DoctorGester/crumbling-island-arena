Vengeance = class({}, nil, DynamicEntity)

function Vengeance:constructor(owner, target, facing, ability)
    DynamicEntity.constructor(self)

    self.owner = owner.owner
    self.hero = owner
    self.unit = nil
    self.health = 3
    self.size = 64
    self.unit = CreateUnitByName("npc_dota_hero_vengefulspirit", target, false, nil, nil, owner.unit:GetTeamNumber())
    self.unit:SetControllableByPlayer(owner.owner.id, true)
    self.unit:AddNewModifier(owner.unit, ability, "modifier_venge_r", { duration = 10 })
    self.unit:AddNewModifier(owner.unit, ability, "modifier_venge_r_visual", {})
    self.unit:SetForwardVector(facing)
    self.unit.hero = self
    self.unit:FindAbilityByName("venge_q"):SetLevel(1)
    self:SetPos(target)
    self:CreateParticles()
end

function Vengeance:CreateParticles()
    self.healthCounter = ParticleManager:CreateParticle("particles/venge_r/venge_r_counter.vpcf", PATTACH_CUSTOMORIGIN, self.unit)
    ParticleManager:SetParticleControl(self.healthCounter, 0, Vector(self.position.x, self.position.y, self.position.z + 200))
    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))

    self.rangeIndicator = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.rangeIndicator, 0, self:GetPos())
    ParticleManager:SetParticleControl(self.rangeIndicator, 1, Vector(650, 1, 1))
    ParticleManager:SetParticleControl(self.rangeIndicator, 2, Vector(0, 74, 127))
    ParticleManager:SetParticleControl(self.rangeIndicator, 3, Vector(10, 0, 0))
end

function Vengeance:Update()
    ParticleManager:SetParticleControl(self.healthCounter, 0, Vector(self.position.x, self.position.y, self.position.z + 200))
    ParticleManager:SetParticleControl(self.rangeIndicator, 0, self:GetPos())

    self.unit:SetAbsOrigin(self:GetPos())
end

function Vengeance:Remove()
    self.unit:RemoveSelf()

    ParticleManager:DestroyParticle(self.healthCounter, false)
    ParticleManager:ReleaseParticleIndex(self.healthCounter)

    ParticleManager:DestroyParticle(self.rangeIndicator, false)
    ParticleManager:ReleaseParticleIndex(self.rangeIndicator)

    ImmediateEffectPoint("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self.hero, self:GetPos())

    --ImmediateEffectPoint("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_shockwave.vpcf", PATTACH_CUSTOMORIGIN, self.hero, self:GetPos())
end

function Vengeance:Damage(source)
    if source.owner ~= self.hero then
        self.health = self.health - 1
    end

    ParticleManager:SetParticleControl(self.healthCounter, 1, Vector(0, self.health, 0))

    if self.health == 0 then
        self:Destroy()
    end
end