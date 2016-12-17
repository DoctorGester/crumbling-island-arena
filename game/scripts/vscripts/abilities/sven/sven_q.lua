sven_q = class({})

function sven_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local force = 60

    if SvenUtil.IsEnraged(hero) then
        force = 100
    end

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/sven_q/sven_q.vpcf",
        distance = 700,
        destroyFunction = function(projectile)
            hero:AreaEffect({
                filter = Filters.Area(projectile:GetPos(), 275),
                damage = self:GetDamage(),
                modifier = { name = "modifier_stunned_lua", duration = 0.6, ability = self },
                knockback = {
                    force = force,
                    direction = function(v) return v:GetPos() - projectile:GetPos() end
                }
            })

            projectile:EmitSound("Arena.Sven.HitQ")
        end
    }):Activate()

    hero:EmitSound("Arena.Sven.CastQ")
    hero:EmitSound("Arena.Sven.CastQ.Voice")
end

function sven_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function sven_q:GetPlaybackRateOverride()
    return 1.66
end