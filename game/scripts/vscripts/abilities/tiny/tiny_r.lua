tiny_r = class({})

LinkLuaModifier("modifier_tiny_r", "abilities/tiny/modifier_tiny_r", LUA_MODIFIER_MOTION_NONE)

function tiny_r:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_tiny_r", { duration = 6 })
    hero:EmitSound("Arena.Tiny.CastR")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tiny_r)