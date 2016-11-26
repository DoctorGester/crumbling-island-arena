tiny_a = class({})

LinkLuaModifier("modifier_tiny_a", "abilities/tiny/modifier_tiny_a", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tiny_a_animation", "abilities/tiny/modifier_tiny_a_animation", LUA_MODIFIER_MOTION_NONE)

function tiny_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Tiny.CastA")

    return true
end

function tiny_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 400
    local damage = self:GetDamage()
    local force = 20
    local mod = hero:FindModifier("modifier_tiny_r")
    local sound = { "Arena.Tiny.HitA2", "Arena.Tiny.HitA" }
    local duration = 0.8

    if mod then
        damage = damage * 3
        force = force * 3
        range = 500
        duration = duration * 3

        table.insert(sound, "Arena.Tiny.HitA3")

        mod:Use()
    end

    hero:AreaEffect({
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = sound,
        damage = damage,
        knockback = { force = force, decrease = 3 },
        modifier = { name = "modifier_tiny_a", duration = duration, ability = self },
        isPhysical = true,
        action = function(target)
            if mod then
                local effectPos = target:GetPos() + Vector(0, 0, 64)
                local direction = (pos - effectPos):Normalized()

                local effect = ImmediateEffectPoint("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_dust_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero, effectPos)
                ParticleManager:SetParticleControl(effect, 1, effectPos + direction * 300)

                target:EmitSound("Arena.Tiny.HitA3")
            end
        end
    })
end

function tiny_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function tiny_a:GetPlaybackRateOverride()
    return 2.0
end

function tiny_a:GetIntrinsicModifierName()
    return "modifier_tiny_a_animation"
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(tiny_a, nil, "particles/melee_attack_blur.vpcf")