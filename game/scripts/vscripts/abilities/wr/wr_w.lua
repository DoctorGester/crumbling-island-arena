wr_w = class({})

function wr_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1400,
        graphics = "particles/wr_w/wr_w.vpcf",
        distance = 1000,
        hitSound = "Arena.WR.HitW",
        hitFunction = function(projectile, target)
            if instanceof(target, Projectile) then
                target:Deflect(hero, projectile.vel)

                if instanceof(target, DistanceCappedProjectile) then
                    target.distancePassed = 0
                end

                projectile:Destroy()
            else
                target:AddNewModifier(hero, self, "modifier_stunned_lua", { duration = 1.0 })
                SoftKnockback(target, hero, projectile.vel, 50, { decrease = 4 })
            end

            ScreenShake(projectile:GetPos(), 5, 150, 0.25, 3000, 0, true)
        end,
        hitProjectiles = true
    }):Activate()

    hero:EmitSound("Arena.WR.CastW")
end

function wr_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function wr_w:GetPlaybackRateOverride()
    return 1
end
