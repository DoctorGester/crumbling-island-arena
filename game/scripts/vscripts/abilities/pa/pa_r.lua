pa_r = class({})

LinkLuaModifier("modifier_pa_r", "abilities/pa/modifier_pa_r", LUA_MODIFIER_MOTION_NONE)

function pa_r:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_pa_r", { fadeTime = 0.7, duration = 5.0 })
    hero:EmitSound("Item.GlimmerCape.Activate")
    hero:EmitSound("Arena.PA.CastR.Voice")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(pa_r)