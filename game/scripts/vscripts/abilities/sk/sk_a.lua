sk_a = class({})

LinkLuaModifier("modifier_sk_a", "abilities/sk/modifier_sk_a", LUA_MODIFIER_MOTION_NONE)

function sk_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.SK.CastA")

    return true
end

function sk_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 275)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 275

    hero:AreaEffect({
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.SK.HitA",
        damage = self:GetDamage(),
        knockback = { force = 20, decrease = 3 },
        modifier = { name = "modifier_sk_a", ability = self, duration = 2.0 },
        isPhysical = true
    })
end

function sk_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function sk_a:GetPlaybackRateOverride()
    return 2.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(sk_a, nil, "particles/melee_attack_blur.vpcf")