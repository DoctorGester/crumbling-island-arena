tusk_q = class({})

function tusk_q:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local direction = self:GetDirection()
    local pos = hero:GetPos()

    if hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, 350, direction, math.pi),
        sound = "Arena.Tusk.HitQ",
        damage = self:GetDamage(),
        action = function(target)
            FX("particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, { release = true })
        end,
        knockback = { force = 40, decrease = 3 }
    }) then
        ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
    end

    SoftKnockback(hero, hero, -direction, 40, { decrease = 3 })

    hero:EmitSound("Arena.Tusk.CastQ")
end

function tusk_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_5
end

function tusk_q:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tusk_q)