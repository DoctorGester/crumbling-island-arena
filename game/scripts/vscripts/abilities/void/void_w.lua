void_w = class({})

LinkLuaModifier("modifier_void", "abilities/void/modifier_void", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_void_w", "abilities/void/modifier_void_w", LUA_MODIFIER_MOTION_NONE)

function void_w:OnSpellStart()

    local hero = self:GetCaster().hero

    --[[FX("particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf", PATTACH_WORLDORIGIN, hero, {
        cp0 = hero:GetAbsOrigin(),
        cp1 = Vector(350, 1, 1),
        release = true
    })]]--

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(hero:GetPos(), 350),
        onlyHeroes = true,
        modifier = { name = "modifier_void_w", ability = self, duration = 1.3 }
    })


    ImmediateEffect("particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf", PATTACH_ABSORIGIN, hero)
    ImmediateEffect("particles/units/heroes/hero_faceless_void/faceless_void_timedialate.vpcf", PATTACH_ABSORIGIN, hero)
    ImmediateEffect("particles/econ/items/faceless_void/faceless_void_bracers_of_aeons/fv_bracers_of_aeons_timedialate.vpcf", PATTACH_ABSORIGIN, hero)
    hero:EmitSound("Arena.Void.CastW")
end

function void_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function void_w:GetPlaybackRateOverride()
    return 2.0
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(void_w)