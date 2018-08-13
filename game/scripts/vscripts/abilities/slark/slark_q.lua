slark_q = class({})

LinkLuaModifier("modifier_slark_q", "abilities/slark/modifier_slark_q", LUA_MODIFIER_MOTION_NONE)

function slark_q:OnAbilityPhaseStart()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
    self:GetCaster():EmitSound("Arena.Slark.PreA")

    return true
end

function slark_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        damage = self:GetDamage(),
        speed = 1650,
        graphics = hero:IsAwardEnabled() and "particles/slark_q/slark_q_elite.vpcf" or "particles/slark_q/slark_q.vpcf",
        distance = 900,
        hitModifier = { name = "modifier_slark_q", duration = 1.0, ability = self },
        hitSound = "Arena.Slark.HitE"
    }):Activate()

    hero:GetWearableBySlot("weapon"):AddEffects(EF_NODRAW)
    hero:FindAbility("slark_a"):StartCooldown(2.0)

    TimedEntity(2.0, function()
        hero:FindAbility("slark_a"):SetActivated(true)
        hero:GetWearableBySlot("weapon"):RemoveEffects(EF_NODRAW)
    end):Activate()
end

function slark_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function slark_q:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(slark_q)
