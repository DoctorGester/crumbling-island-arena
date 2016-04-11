sniper_q = class({})

function sniper_q:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sniper.PreQ")

    return true
end

function sniper_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    Projectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 2000,
        graphics = "particles/sniper_q/sniper_q.vpcf",
        radius = 48,
        hitSound = "Arena.Sniper.HitQ",
        hitFunction = function(projectile, target)
            hero:StopSound("Arena.Sniper.FlyQ")
            target:Damage(projectile)
        end
    }):Activate()

    hero:EmitSound("Arena.Sniper.CastQ")
    hero:EmitSound("Arena.Sniper.FlyQ")

    ScreenShake(hero:GetPos(), 4, 50, 0.35, 2000, 0, true)
end

function sniper_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function sniper_q:GetPlaybackRateOverride()
    return 3.5
end