EntitySniperW = EntitySniperW or class({}, nil, UnitEntity)

function EntitySniperW:constructor(round, owner, position, ability)
    getbase(EntitySniperW).constructor(self, round, "npc_dota_techies_stasis_trap", position)

    self.hero = owner
    self.owner = owner.owner
    self.ability = ability
    self.collisionType = COLLISION_TYPE_INFLICTOR
    self.invulnerable = true
    self.removeOnDeath = false

    self:AddNewModifier(owner.unit, self, "modifier_sniper_w_trap", {})
    self:EmitSound("Arena.Sniper.CastW")
end

function EntitySniperW:CollidesWith(target)
    return self.owner ~= target.owner and instanceof(target, Hero)
end

function EntitySniperW:CollideWith(target)
    target:AddNewModifier(self.hero, self.ability, "modifier_sniper_w", { duration = 1.7 })
    target:EmitSound("Arena.Sniper.HitW")
    ImmediateEffectPoint("particles/units/heroes/hero_techies/techies_stasis_trap_explode.vpcf", PATTACH_ABSORIGIN, self.unit, self.unit:GetAbsOrigin())

    self:Destroy()
end