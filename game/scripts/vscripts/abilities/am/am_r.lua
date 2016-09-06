am_r = class({})
local self = am_r

LinkLuaModifier("modifier_am_r", "abilities/am/modifier_am_r", LUA_MODIFIER_MOTION_NONE)

function self:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.AM.PreR")

    return true
end

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:AreaEffect({
        onlyHeroes = true,
        filter = Filters.Area(target, 350),
        modifier = { name = "modifier_am_r", duration = 2.5, ability = self }
    })

    FX("particles/units/heroes/hero_antimage/antimage_manavoid.vpcf", PATTACH_WORLDORIGIN, hero, {
        cp0 = target,
        cp1 = Vector(350, 0, 0),
        release = true
    })

    hero:EmitSound("Arena.AM.CastR")

    ScreenShake(target, 5, 150, 0.45, 3000, 0, true)
end

function self:GetPlaybackRateOverride()
    return 2.0
end
function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end
