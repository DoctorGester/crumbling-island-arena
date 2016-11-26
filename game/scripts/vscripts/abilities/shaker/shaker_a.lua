shaker_a = class({})

LinkLuaModifier("modifier_shaker_a", "abilities/shaker/modifier_shaker_a", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shaker_a_animation", "abilities/shaker/modifier_shaker_a_animation", LUA_MODIFIER_MOTION_NONE)

function shaker_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Shaker.PreQ")

    return true
end

function shaker_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()
    local force = 20
    local mod = hero:FindModifier("modifier_shaker_a")
    local sound = "Arena.Shaker.HitA"

    if mod then
        damage = damage * 2
        force = force * 2
        sound = { "Arena.Shaker.HitA", "Arena.Shaker.HitA2" }

        mod:Destroy()
    end

    hero:AreaEffect({
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = sound,
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true
    })
end

function shaker_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function shaker_a:GetPlaybackRateOverride()
    return 2.5
end

function shaker_a:GetIntrinsicModifierName()
    return "modifier_shaker_a_animation"
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(shaker_a, nil, "particles/melee_attack_blur.vpcf")