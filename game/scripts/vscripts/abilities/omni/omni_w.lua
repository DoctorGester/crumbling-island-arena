omni_w = class({})
local self = omni_w

function self:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local target = hero:GetPos() + self:GetDirection() * 200

    FX("particles/omni_w/omni_w.vpcf", PATTACH_WORLDORIGIN, hero, {
        cp0 = target,
        cp1 = Vector(220, 0, 0)
    })

    hero:AreaEffect({
        filter = Filters.Area(target, 220),
        filterProjectiles = true,
        modifier = { name = "modifier_stunned_lua", duration = 0.8, ability = self }
    })

    hero:EmitSound("Arena.Omni.CastW")
    ScreenShake(target, 5, 150, 0.25, 2000, 0, true)
    Spells:GroundDamage(target, 220, hero)
end

function self:GetPlaybackRateOverride()
    return 1.33
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(omni_w)