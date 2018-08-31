void_q = class({})

LinkLuaModifier("modifier_void_q", "abilities/void/modifier_void_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_q_root", "abilities/void/modifier_void_q_root", LUA_MODIFIER_MOTION_NONE)

function void_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 96),
        to = target + Vector(0, 0, 96),
        speed = 1400,
        graphics = "particles/void_q/void_q.vpcf",
        distance = 1200,
        hitSound = "Arena.Void.HitQ",
        hitModifier = { name = "modifier_void_q", duration = 2.0, ability = self },
        hitFunction = function(projectile, target)
            target:Damage(projectile, self:GetDamage())
        end,
        destroyOnDamage = false,
        damagesTrees = true,
        disablePrediction = true
    }):Activate()

    hero:EmitSound("Arena.Void.CastQ")

    if RandomInt(0, 2) == 0 then
        hero:EmitSound("Arena.Void.CastQ.Voice")
    end
end

function void_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function void_q:GetPlaybackRateOverride()
    return 1.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_q)
