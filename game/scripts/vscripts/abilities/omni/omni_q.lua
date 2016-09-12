omni_q = class({})
local self = omni_q

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local hit = hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 300),
        filterProjectiles = true,
        hitAllies = true,
        action = function(victim)
            if victim.owner.team ~= hero.owner.team then
                victim:Damage(hero)
            else
                victim:Heal()
            end
        end
    })

    if hit then
        hero:Heal()
    end

    FX("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
        cp1 = Vector(300, 0, 0)
    })

    hero:EmitSound("Arena.Omni.CastQ")
    ScreenShake(hero:GetPos(), 5, 150, 0.25, 2000, 0, true)
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function self:GetPlaybackRateOverride()
    return 1.33
end