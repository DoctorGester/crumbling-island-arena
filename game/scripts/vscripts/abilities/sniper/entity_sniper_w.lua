EntitySniperW = EntitySniperW or class({}, nil, DynamicEntity)

function EntitySniperW:constructor(round, owner, position, ability)
    DynamicEntity.constructor(self, round)

    self.hero = owner
    self.owner = owner.owner
    self.ability = ability
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.invulnerable = true

    self.unit = CreateUnitByName("npc_dota_techies_stasis_trap", position, false, nil, nil, owner.unit:GetTeamNumber())
    self.unit:AddNewModifier(owner.unit, self, "modifier_sniper_w_trap", {})

    self:SetPos(position)
end

function EntitySniperW:CollidesWith(target)
    return DynamicEntity.CollidesWith(self, target) and target:__instanceof__(Hero)
end

function EntitySniperW:CollideWith(target)
    target:AddNewModifier(self.hero, self.ability, "modifier_sniper_w", { duration = 1.7 })
    target:EmitSound("Arena.Sniper.HitW")
    ImmediateEffectPoint("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_ABSORIGIN, self.unit, self.unit:GetAbsOrigin())

    self:Destroy()
end

function EntitySniperW:Remove()
    self.unit:ForceKill(false)
end