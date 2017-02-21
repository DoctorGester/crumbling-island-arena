ta_r = class({})
LinkLuaModifier("modifier_ta_r", "abilities/ta/modifier_ta_r", LUA_MODIFIER_MOTION_NONE)

function ta_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_ta_r", { duration = 4 })
    hero:EmitSound("Arena.TA.CastR")
    hero:EmitSound("Arena.TA.CastR.Voice")
    self:GetCaster():StartGesture(ACT_DOTA_CAST_REFRACTION)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ta_r)