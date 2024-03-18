slark_w = class({})

LinkLuaModifier("modifier_slark_w", "abilities/slark/modifier_slark_w", LUA_MODIFIER_MOTION_NONE)

function slark_w:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:EmitSound("Arena.Slark.PreW")
    hero:AddNewModifier(hero, self, "modifier_slark_w", { duration = 1.5 })
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(slark_w)