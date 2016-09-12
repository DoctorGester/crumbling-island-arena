omni_e = class({})
local self = omni_e

LinkLuaModifier("modifier_omni_e", "abilities/omni/modifier_omni_e", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_omni_e", { duration = 2.0 })
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function self:GetPlaybackRateOverride()
    return 2
end