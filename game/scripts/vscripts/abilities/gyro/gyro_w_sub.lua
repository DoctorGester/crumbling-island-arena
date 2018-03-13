gyro_w_sub = class({})
local self = gyro_w_sub

function self:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()
    local target = self:GetCursorPosition()

    local modifier = hero:FindModifier("modifier_gyro_w")

    if modifier then
        modifier:Destroy()

        local projectile
        local particle

        if (hero:HasModifier("modifier_gyro_e")) then
            local rocketTarget = hero:GetPos() * Vector(1, 1, 0) + hero:GetFacing() * 300.0
            local dropRadius = 250

            CreateEntityAOEMarker(rocketTarget + Vector(0, 0, 32), dropRadius, 0.4, { 255, 147, 0 }, 0.1, true)

            projectile = ArcProjectile(self.round, {
                ability = self,
                owner = hero,
                from = hero:GetPos(),
                to =  rocketTarget,
                speed = 1400,
                arc = 100,
                radius = 64,
                hitParams = {
                    ability = self,
                    filter = Filters.Area(rocketTarget, dropRadius),
                    damage = self:GetDamage(),
                    damagesTrees = true,
                    modifier = { name = "modifier_stunned_lua", duration = 1.2, ability = self }
                },
                hitSound = "Arena.Gyro.HitW.Sub",
                hitFunction = function(projectile, hit)
                    local particleTarget = rocketTarget + Vector(0, 0, 128)
                    FX("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, projectile, {
                        cp0 = particleTarget,
                        release = true
                    })

                    FX("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_ABSORIGIN, projectile, {
                        cp0 = particleTarget,
                        cp3 = particleTarget,
                        release = true
                    })

                    DFX(particle, false)

                    Spells:GroundDamage(rocketTarget, dropRadius, hero)

                    ScreenShake(rocketTarget, 5, 150, 0.25, 2000, 0, true)

                    projectile:SetModel("models/development/invisiblebox.vmdl")
                    projectile:EmitSound("Arena.Gyro.EndW.Sub")
                end
            }):Activate()
        else
            projectile = DistanceCappedProjectile(hero.round, {
                ability = self,
                owner = hero,
                from = hero:GetPos(),
                to = target,
                speed = 1250,
                distance = 300 + math.min(4.5, modifier:GetElapsedTime()) * 250,
                hitModifier = { name = "modifier_stunned_lua", duration = 1.2, ability = self },
                hitSound = "Arena.Gyro.HitW.Sub",
                destroyFunction = function(projectile)
                    FX("particles/units/heroes/hero_gyrocopter/gyro_guided_missile_explosion.vpcf", PATTACH_CUSTOMORIGIN, projectile, {
                        cp0 = projectile:GetPos() + Vector(0, 0, 128),
                        release = true
                    })

                    DFX(particle, false)

                    ScreenShake(projectile:GetPos(), 5, 150, 0.25, 2000, 0, true)

                    -- Doesn't disappear otherwise
                    projectile:SetModel("models/development/invisiblebox.vmdl")
                    projectile:EmitSound("Arena.Gyro.EndW.Sub")
                end,
                damage = self:GetDamage()
            }):Activate()

            SoftKnockback(hero, hero, (hero:GetPos() - target):Normalized(), 30, { decrease = 4 })
            ScreenShake(hero:GetPos(), 5, 150, 0.25, 3000, 0, true)
        end

        projectile:SetModel("models/heroes/gyro/gyro_missile.vmdl")

        particle = FX("particles/units/heroes/hero_gyrocopter/gyro_guided_missile.vpcf", PATTACH_POINT_FOLLOW, projectile, {
            cp0 = { ent = projectile, point = "attach_hitloc" }
        })

        hero:EmitSound("Arena.Gyro.CastW.Sub")
    end
end

function self:GetBehavior()
    if self:GetCaster():HasModifier("modifier_gyro_e") then
        return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end

    return self.BaseClass.GetBehavior(self)
end

function self:GetCastAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_4
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(gyro_w_sub)