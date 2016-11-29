sniper_a = class({})

function sniper_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sniper.PreA")

    return true
end

function sniper_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    Projectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 2300,
        graphics = "particles/sniper_q/sniper_q.vpcf",
        radius = 48,
        hitSound = "Arena.Sniper.HitA",
        hitFunction = function(projectile, target)
            hero:StopSound("Arena.Sniper.FlyA")
            target:Damage(projectile, self:GetDamage(), true)
            SoftKnockback(target, hero, projectile.vel, 20, { decrease = 3 })
        end
    }):Activate()

    hero:EmitSound("Arena.Sniper.CastA")
    hero:EmitSound("Arena.Sniper.FlyA")

    ScreenShake(hero:GetPos(), 4, 50, 0.35, 2000, 0, true)
end

function sniper_a:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function sniper_a:GetPlaybackRateOverride()
    return 3.5
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(sniper_a, 0.5)