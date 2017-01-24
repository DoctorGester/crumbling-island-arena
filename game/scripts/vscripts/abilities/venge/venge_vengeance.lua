Vengeance = class({}, nil, WearableOwner)

function Vengeance:constructor(round, owner, target, facing, ability)
    getbase(Vengeance).constructor(self, round, "venge_vengeance", target, owner.unit:GetTeamNumber())

    self.owner = owner.owner
    self.hero = owner
    self.size = 64
    self.collisionType = COLLISION_TYPE_RECEIVER

    local unit = self:GetUnit()
    
    if owner.owner then
        unit:SetControllableByPlayer(owner.owner.id, true)
    end

    unit:AddAbility("venge_q"):SetLevel(1)
    unit.hero = self

    self:CreateParticles()
    self:AddNewModifier(self.hero, ability, "modifier_venge_r", { duration = 10 })
    self:AddNewModifier(self.hero, ability, "modifier_venge_r_visual", {})
    self:AddNewModifier(self, nil, "modifier_custom_healthbar", {})
    self:SetFacing(facing)
    self:SetPos(target)
    self:SetCustomHealth(3)
    self:EnableHealthBar()
    self:LoadItems(unpack(owner:BuildWearableStack()))

    Wrappers.WrapAbilitiesFromHeroData(unit, self.hero.data)
end

function Vengeance:GetName()
    return "npc_dota_hero_vengefulspirit"
end

function Vengeance:CreateParticles()
    self.rangeIndicator = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    ParticleManager:SetParticleControl(self.rangeIndicator, 1, Vector(550, 1, 1))
    ParticleManager:SetParticleControl(self.rangeIndicator, 2, Vector(0, 74, 255))
    ParticleManager:SetParticleControl(self.rangeIndicator, 3, Vector(10, 0, 0))
end

function Vengeance:Remove()
    getbase(Vengeance).Remove(self)

    ParticleManager:DestroyParticle(self.rangeIndicator, false)
    ParticleManager:ReleaseParticleIndex(self.rangeIndicator)

    ImmediateEffectPoint("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, self.hero, self:GetPos())
end

function Vengeance:CollidesWith()
    return true
end