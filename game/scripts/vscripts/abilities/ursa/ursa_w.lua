ursa_w = class({})

function ursa_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local pos = hero:GetPos()

    hero:AreaEffect({
        filter = Filters.Area(pos, 300),
        filterProjectiles = true,
        modifier = { name = "modifier_stunned_lua", duration = 1.3, ability = self }
    })

    local effect = ImmediateEffect("particles/units/heroes/hero_ursa/ursa_earthshock.vpcf", PATTACH_ABSORIGIN, hero)

    hero:EmitSound("Arena.Ursa.CastW")

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
end

function ursa_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

function ursa_w:GetPlaybackRateOverride()
    return 1.5
end