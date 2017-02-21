jugger_q = class({})

LinkLuaModifier("modifier_jugger_q", "abilities/jugger/modifier_jugger_q", LUA_MODIFIER_MOTION_NONE)

function jugger_q:OnSpellStart()
    local hero = self:GetCaster():GetParentEntity()

    hero:AddNewModifier(hero, self, "modifier_jugger_q", { duration = 2.5 })
    hero:EmitSound("Arena.Jugger.CastQ.Voice")
end

function jugger_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(jugger_q)