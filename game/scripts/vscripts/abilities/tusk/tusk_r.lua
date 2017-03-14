tusk_r = class({})

LinkLuaModifier("modifier_tusk_r", "abilities/tusk/modifier_tusk_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_r_aura", "abilities/tusk/modifier_tusk_r_aura", LUA_MODIFIER_MOTION_NONE)

function tusk_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:AddNewModifier(hero, self, "modifier_tusk_r_aura", { duration = 10 })
    hero:EmitSound("Arena.Tusk.CastR.Voice")
end

function tusk_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tusk_r)