pudge_r = class({})

LinkLuaModifier("modifier_pudge_r", "abilities/pudge/modifier_pudge_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pudge_r_aura", "abilities/pudge/modifier_pudge_r_aura", LUA_MODIFIER_MOTION_NONE)

function pudge_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_pudge_r_aura", { duration = 5 })
    hero:GetUnit():StartGesture(ACT_DOTA_CAST_ABILITY_ROT)
    hero:EmitSound("Arena.Pudge.CastR.Voice")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pudge_r)