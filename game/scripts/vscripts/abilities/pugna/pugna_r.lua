pugna_r = class({})
LinkLuaModifier("modifier_pugna_r", "abilities/pugna/modifier_pugna_r", LUA_MODIFIER_MOTION_NONE)

function pugna_r:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_pugna_r", { duration = 4.5 })
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pugna_r)