tusk_a = class({})

LinkLuaModifier("modifier_tusk_a", "abilities/tusk/modifier_tusk_a", LUA_MODIFIER_MOTION_NONE)

function tusk_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Undying.PreQ.Sub")

    return true
end

function tusk_a:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster():GetParentEntity()
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local damage = self:GetDamage()
    local force = 20
    local sound = "Arena.Tusk.HitA"
    local mod = hero:FindModifier("modifier_tusk_a")
    local action = function() end

    if mod and mod:GetRemainingTime() <= 0 then
        mod:Destroy()
        hero:StopSound("Arena.Tusk.LoopA")

        damage = damage * 2
        force = 40
        sound = { "Arena.Tusk.CastQ", "Arena.Tusk.HitQ" }

        action = function(victim)
            FX("particles/units/heroes/hero_tusk/tusk_walruspunch_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, victim, { release = true })
        end

        hero:AddNewModifier(hero, self, "modifier_tusk_a", {})
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 300, forward, math.pi),
        sound = sound,
        damage = damage,
        knockback = { force = force, decrease = 3 },
        isPhysical = true,
        action = action
    })
end

function tusk_a:GetCastAnimation()
    local hero = self:GetCaster():GetParentEntity()
    local mod = hero:FindModifier("modifier_tusk_a")

    if mod and mod:GetRemainingTime() <= 0 then
        return ACT_DOTA_CAST_ABILITY_4
    end

    return ACT_DOTA_ATTACK
end

function tusk_a:GetPlaybackRateOverride()
    return 3
end

function tusk_a:GetIntrinsicModifierName()
    return "modifier_tusk_a"
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(tusk_a, nil, "particles/melee_attack_blur.vpcf")