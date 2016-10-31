gyro_w_sub = class({})
local self = gyro_w_sub

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local modifier = hero:FindModifier("modifier_gyro_w")

    if modifier then
        modifier:Destroy()

        local particle = -1
        local projectile = DistanceCappedProjectile(hero.round, {
            owner = hero,
            from = hero:GetPos(),
            to = target,
            speed = 1250,
            distance = 300 + modifier:GetRemainingTime() * 250,
            hitModifier = { name = "modifier_stunned_lua", duration = 1.2, ability = self },
            hitSound = "Arena.Gyro.HitW.Sub",
            destroyFunction = function(projectile)
                FX("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, projectile, {
                    cp0 = projectile:GetPos() + Vector(0, 0, 128),
                    release = true
                })

                ParticleManager:DestroyParticle(particle, false)
                ParticleManager:ReleaseParticleIndex(particle)

                ScreenShake(projectile:GetPos(), 5, 150, 0.25, 2000, 0, true)

                projectile:EmitSound("Arena.Gyro.EndW.Sub")
            end
        }):Activate()

        projectile:GetUnit():SetModel("models/heroes/gyro/gyro_missile.vmdl")

        particle = FX("particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", PATTACH_POINT_FOLLOW, projectile, {
            cp0 = { ent = projectile, point = "attach_hitloc" }
        })

        hero:EmitSound("Arena.Gyro.CastW.Sub")
    end
end

function self:GetCastAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_4
end