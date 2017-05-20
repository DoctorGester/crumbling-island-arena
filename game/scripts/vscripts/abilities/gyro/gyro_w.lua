gyro_w = class({})
local self = gyro_w

LinkLuaModifier("modifier_gyro_w", "abilities/gyro/modifier_gyro_w", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, hero:FindAbility("gyro_w_sub"), "modifier_gyro_w", { duration = 3.0 })
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(gyro_w)