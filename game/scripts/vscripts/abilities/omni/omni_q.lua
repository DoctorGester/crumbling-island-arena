omni_q = class({})
local self = omni_q

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 300) + Filters.WrapFilter(function(v) return v.owner.team == hero.owner.team end),
        filterProjectiles = true,
        hitAllies = true,
        action = function(victim)
            victim:Heal()
        end
    })

    local hit = false

    hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 300),
        damage = true,
        action = function(victim)
            if instanceof(victim, Hero) then
                hit = true
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

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(omni_q)