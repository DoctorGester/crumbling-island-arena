ta_r = class({})
LinkLuaModifier("modifier_ta_r_shield", "abilities/ta/modifier_ta_r_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_r_heal", "abilities/ta/modifier_ta_r_heal", LUA_MODIFIER_MOTION_NONE)

function ta_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_ta_r_shield", { duration = 4 })
    hero:EmitSound("Arena.TA.CastR")
    hero:EmitSound("Arena.TA.CastR.Voice")
    self:GetCaster():StartGesture(ACT_DOTA_CAST_REFRACTION)
end