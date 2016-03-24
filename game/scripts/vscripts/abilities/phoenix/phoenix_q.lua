phoenix_q = class({})

LinkLuaModifier("modifier_phoenix_q", "abilities/phoenix/modifier_phoenix_q", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_phoenix_q_slow", "abilities/phoenix/modifier_phoenix_q_slow", LUA_MODIFIER_MOTION_NONE)

if IsClient() then
    require("heroes/phoenix")
end

phoenix_q.CastFilterResult = Phoenix.CastFilterResultLocation
phoenix_q.GetCustomCastError = Phoenix.GetCustomCastErrorLocation

function phoenix_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = hero:GetPos() + hero:GetFacing() * 900

    if hero:GetHealth() > 1 then
        hero:Damage(hero)
    end

    Dash(hero, target, 900, {
        loopingSound = "Arena.Phoenix.CastQ",
        modifier = { name = "modifier_phoenix_q", ability = self },
        hitParams = {
            modifier = { name = "modifier_phoenix_q_slow", ability = self, duration = 1.5 },
            damage = true
        }
    })
end