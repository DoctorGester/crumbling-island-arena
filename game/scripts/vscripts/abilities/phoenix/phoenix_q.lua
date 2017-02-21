phoenix_q = class({})

if IsClient() then
    require('heroes/hero_util')
end

LinkLuaModifier(PhoenixUtil.EGG_MODIFIER, "abilities/phoenix/modifier_phoenix_egg", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_egg_tooltip", "abilities/phoenix/modifier_phoenix_egg_tooltip", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_q", "abilities/phoenix/modifier_phoenix_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_q_slow", "abilities/phoenix/modifier_phoenix_q_slow", LUA_MODIFIER_MOTION_NONE)

PhoenixUtil.CastFitersLocation(phoenix_q)

function phoenix_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 900)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    if hero:GetHealth() > 1 then
        hero:Damage(hero)
    end

    Dash(hero, target, 900, {
        loopingSound = "Arena.Phoenix.CastQ",
        modifier = { name = "modifier_phoenix_q", ability = self },
        forceFacing = true,
        hitParams = {
            modifier = { name = "modifier_phoenix_q_slow", ability = self, duration = 1.5 },
            damage = true
        }
    })
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(phoenix_q)