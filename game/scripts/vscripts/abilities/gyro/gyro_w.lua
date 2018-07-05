gyro_w = class({})
local self = gyro_w

LinkLuaModifier("modifier_gyro_w", "abilities/gyro/modifier_gyro_w", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, hero:FindAbility("gyro_w_sub"), "modifier_gyro_w", { duration = 6.0 })
end

function self:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end

function self:GetBehavior()
    if self:GetCaster():HasModifier("modifier_gyro_e") then
        return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
    end

    return self.BaseClass.GetBehavior(self)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(gyro_w)