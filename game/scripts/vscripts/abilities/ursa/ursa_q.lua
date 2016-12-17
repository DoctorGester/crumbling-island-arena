ursa_q = class({})

function ursa_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()

    hero:AreaEffect({
        filter = Filters.Area(pos, 350),
        filterProjectiles = true,
        modifier = { name = "modifier_stunned_lua", duration = 1.3, ability = self }
    })

    ImmediateEffect("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, hero)

    hero:EmitSound("Arena.Ursa.CastQ")

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
end

function ursa_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function ursa_q:GetPlaybackRateOverride()
    return 1.5
end