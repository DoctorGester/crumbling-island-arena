ursa_q = class({})

LinkLuaModifier("modifier_ursa_q", "abilities/ursa/modifier_ursa_q", LUA_MODIFIER_MOTION_NONE)

function ursa_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(pos, 350),
        filterProjectiles = true,
        damage = self:GetDamage(),
        modifier = { name = "modifier_ursa_q", duration = 1.0, ability = self }
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