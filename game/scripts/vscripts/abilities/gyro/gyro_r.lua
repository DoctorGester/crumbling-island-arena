gyro_r = class({})
local self = gyro_r

function self:GetChannelTime()
    return 2.5
end

function self:GetChannelAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_1
end

if IsServer() then
    function self:OnChannelThink(interval)
        local hero = self:GetCaster():GetParentEntity()
        local target = self:GetCursorPosition()

        if interval == 0 then
            hero:EmitSound("Arena.Gyro.LoopR")
            hero:EmitSound("Arena.Gyro.CastR.Voice")
        end

        self.timePassed = (self.timePassed or 0) + interval

        if self.timePassed > 0.15 then
            self.timePassed = self.timePassed % 0.15

            DistanceCappedProjectile(hero.round, {
                ability = self,
                owner = hero,
                from = hero:GetPos() + Vector(0, 0, 128),
                to = target + Vector(0, 0, 128),
                speed = 1950,
                graphics = "particles/gyro_r/gyro_r.vpcf",
                distance = 1500,
                hitSound = "Arena.Gyro.HitR",
                damagesTrees = true,
                nonBlockedHitAction = function(projectile, victim)
                    FX("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN, projectile, {
                        cp0 = projectile:GetPos(),
                        release = true
                    })
                end,
                screenShake = { 5, 150, 0.25, 1500, 0, true },
                knockback = { force = 50 }
            }):Activate()

            SoftKnockback(hero, hero, (hero:GetPos() - target):Normalized(), 10, { decrease = 4 })
            hero:EmitSound("Arena.Gyro.FireR")
        end
    end

    function self:OnChannelFinish(interrupted)
        self.timePassed = 0

        local hero = self:GetCaster():GetParentEntity()
        hero:StopSound("Arena.Gyro.LoopR")
    end
end

if IsServer() then
    Wrappers.GuidedAbility(self, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(gyro_r)