undying_a = class({})

function undying_a:OnAbilityPhaseStart()
    local hero = self:GetCaster()
    local mod = hero:FindModifierByName("modifier_undying_q_health")
    local stacks = 0

    if mod then
        stacks = mod:GetStackCount()
    end

    hero:EmitSound("Arena.Undying.PreA")

    FX("particles/melee_attack_blur_configurable.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
        cp1 = Vector(300 + stacks * 30, 0, 0),
        release = true
    })

    return true
end

function undying_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local damage = self:GetDamage()
    local shield = hero:FindModifier("modifier_undying_q_health")
    local stacks = 0
    local force = 20
    local specialSound = hero:IsAwardEnabled() and hero:HasModifier("modifier_undying_r")

    if shield then
        stacks = shield:GetStackCount()
    end

    if stacks >= 3 then
        damage = damage + 1
        force = force + 10
    end

    if stacks >= 6 then
        damage = damage + 1
        force = force + 10
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300 + stacks * 30, forward, math.pi),
        sound = specialSound and "Arena.Pudge.HitA" or "Arena.Undying.HitA",
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true
    })

    hero:EmitSound("Arena.Undying.CastA")

    if stacks >= 3 then
        ScreenShake(hero:GetPos(), 5, 150, 0.45, 3000, 0, true)
    end
end

function undying_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function undying_a:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(undying_a)