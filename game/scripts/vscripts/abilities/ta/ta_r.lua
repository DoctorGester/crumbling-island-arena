ta_r = class({})
LinkLuaModifier("modifier_ta_r_shield", "abilities/ta/modifier_ta_r_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ta_r_heal", "abilities/ta/modifier_ta_r_heal", LUA_MODIFIER_MOTION_NONE)

function ta_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_ta_r_shield", { duration = 4 })
    hero:EmitSound("Arena.TA.CastR")
end