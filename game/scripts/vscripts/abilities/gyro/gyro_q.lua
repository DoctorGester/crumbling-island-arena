gyro_q = class({})
local self = gyro_q

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster():GetParentEntity()

    for i = -1, 1 do
        local dir = self:GetDirection()
        local an = math.atan2(dir.y, dir.x) + 0.3 * i
        local retarget = Vector(math.cos(an), math.sin(an)) + hero:GetPos()

        DistanceCappedProjectile(hero.round, {
            ability = self,
            owner = hero,
            from = hero:GetPos() + Vector(0, 0, 128),
            to = retarget + Vector(0, 0, 128),
            speed = 1700,
            radius = 16,
            graphics = "particles/gyro_q/gyro_q.vpcf",
            distance = 550,
            hitSound = "Arena.Gyro.HitQ",
            hitFunction = function(projectile, victim)
                FX("particles/econ/items/gyrocopter/hero_gyrocopter_gyrotechnics/gyro_guided_missile_explosion.vpcf", PATTACH_ABSORIGIN, victim, {
                    cp0 = projectile:GetPos(),
                    release = true
                })

                ScreenShake(projectile:GetPos(), 5, 150, 0.25, 1500, 0, true)
                SoftKnockback(victim, hero, projectile.vel, 40, { decrease = 4.5 })

                victim:Damage(hero, self:GetDamage())
            end
        }):Activate()
    end

    ScreenShake(hero:GetPos(), 5, 150, 0.25, 3000, 0, true)

    --hero:AddNewModifier(hero, self, "modifier_gyro_q", { duration = 5.0 })
    hero:EmitSound("Arena.Gyro.CastQ")
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 1.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(gyro_q)