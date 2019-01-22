timber_w = class({})
local self = timber_w

LinkLuaModifier("modifier_timber_w", "abilities/timber/modifier_timber_w", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    hero:AddNewModifier(hero, self, "modifier_timber_w", { duration = 0.8 })
    hero:EmitSound("Arena.Timber.CastW")

    hero:FindAbility("timber_a"):SetActivated(false)
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_w)