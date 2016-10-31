gyro_q_sub = class({})
local self = gyro_q_sub

LinkLuaModifier("modifier_gyro_q_slow", "abilities/gyro/modifier_gyro_q_slow", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local modifier = hero:FindModifier("modifier_gyro_q")

    if modifier then
        modifier:DecrementStackCount()

        if modifier:GetStackCount() == 0 then
            modifier:Destroy()
        end
    end

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile.vpcf",
        distance = 750,
        hitSound = "Arena.Gyro.HitQ.Sub",
        hitFunction = function(projectile, victim)
            FX("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN, victim, {
                cp0 = projectile:GetPos(),
                release = true
            })

            ScreenShake(projectile:GetPos(), 5, 150, 0.25, 1500, 0, true)

            local modifier = victim:FindModifier("modifier_gyro_q_slow")

            if not modifier then
                modifier = victim:AddNewModifier(hero, self, "modifier_gyro_q_slow", { duration = 5 })
                modifier:SetStackCount(1)
            else
                modifier:IncrementStackCount()

                if modifier:GetStackCount() == 3 then
                    victim:Damage(hero)
                    victim:EmitSound("Arena.Gyro.HitQ.Sub")
                    modifier:Destroy()
                end
            end
        end
    }):Activate()

    SoftKnockback(hero, (hero:GetPos() - target):Normalized(), 10, { decrease = 4 })
    hero:EmitSound("Arena.Gyro.CastQ.Sub")
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function self:GetPlaybackRateOverride()
    return 2.0
end