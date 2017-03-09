gyro_a = class({})
local self = gyro_a

LinkLuaModifier("modifier_gyro_a_slow", "abilities/gyro/modifier_gyro_a_slow", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1500,
        graphics = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile.vpcf",
        distance = 750,
        hitSound = "Arena.Gyro.HitA",
        nonBlockedHitAction = function(projectile, victim)
            FX("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN, victim, {
                cp0 = projectile:GetPos(),
                release = true
            })
        end,
        screenShake = { 5, 150, 0.25, 1500, 0, true },
        hitFunction = function(_, victim)
            local damage = self:GetDamage()
            local modifier = victim:FindModifier("modifier_gyro_a_slow")

            if not modifier then
                modifier = victim:AddNewModifier(hero, self, "modifier_gyro_a_slow", { duration = 3 })

                if modifier then
                    modifier:SetStackCount(1)
                end
            else
                modifier:IncrementStackCount()
                modifier:ForceRefresh()

                if modifier:GetStackCount() == 3 then
                    damage = damage * 2
                    victim:EmitSound("Arena.Gyro.HitA2")
                    modifier:Destroy()
                end
            end

            victim:Damage(hero, damage, true)
        end
    }):Activate()

    --SoftKnockback(hero, hero, (hero:GetPos() - target):Normalized(), 20, { decrease = 2 })
    hero:EmitSound("Arena.Gyro.CastA")
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function self:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(self)