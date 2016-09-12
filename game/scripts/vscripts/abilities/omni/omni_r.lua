omni_r = class({})
local self = omni_r

LinkLuaModifier("modifier_omni_r", "abilities/omni/modifier_omni_r", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local hit = hero:AreaEffect({
        filter = Filters.Area(hero:GetPos(), 1200) + Filters.WrapFilter(function(v) return v.owner.team == hero.owner.team end),
        onlyHeroes = true,
        hitSelf = true,
        hitAllies = true,
        modifier = { name = "modifier_omni_r", duration = 3.5, ability = self }
    })

    hero:EmitSound("Arena.Omni.CastR")
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function self:GetPlaybackRateOverride()
    return 2.0
end
