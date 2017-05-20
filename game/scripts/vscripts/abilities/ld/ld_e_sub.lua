ld_e_sub = class({})

LinkLuaModifier("modifier_ld_e_sub", "abilities/ld/modifier_ld_e_sub", LUA_MODIFIER_MOTION_NONE)

function ld_e_sub:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:GetUnit():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
    hero:AddNewModifier(hero, self, "modifier_ld_e_sub", { duration = 4.5 })
    hero:EmitSound("Arena.LD.CastESub")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(ld_e_sub)