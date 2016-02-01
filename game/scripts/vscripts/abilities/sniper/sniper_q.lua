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

    local projectileData = {}
    projectileData.owner = hero
    projectileData.from = hero:GetPos() + Vector(0, 0, 64)
    projectileData.to = target + Vector(0, 0, 64)
    projectileData.velocity = 2000
    projectileData.graphics = "particles/sniper_q/sniper_q.vpcf"
    projectileData.distance = 15000
    projectileData.empowered = false
    projectileData.radius = 48
    projectileData.heroBehaviour =
        function(self, target)
            Spells:ProjectileDamage(self, target)
            target:EmitSound("Arena.Sniper.HitQ")
            hero:StopSound("Arena.Sniper.FlyQ")
            return true
        end

    Spells:CreateProjectile(projectileData)
    hero:EmitSound("Arena.Sniper.CastQ")
    hero:EmitSound("Arena.Sniper.FlyQ")
end

function sniper_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function sniper_q:GetPlaybackRateOverride()
    return 3.5
end