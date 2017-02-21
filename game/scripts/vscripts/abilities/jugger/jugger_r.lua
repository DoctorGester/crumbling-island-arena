jugger_r = class({})

LinkLuaModifier("modifier_jugger_r", "abilities/jugger/modifier_jugger_r", LUA_MODIFIER_MOTION_NONE)

function jugger_r:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_jugger_r", { duration = 4 })
    hero:EmitSound("Arena.Jugger.CastR")
    hero:EmitSound("Arena.Jugger.CastR2")
    hero:FindAbility("jugger_a"):EndCooldown()
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(jugger_r)