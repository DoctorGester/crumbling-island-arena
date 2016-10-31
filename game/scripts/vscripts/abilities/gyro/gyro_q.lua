gyro_q = class({})
local self = gyro_q

LinkLuaModifier("modifier_gyro_q", "abilities/gyro/modifier_gyro_q", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero

    hero:AddNewModifier(hero, self, "modifier_gyro_q", { duration = 5.0 })
    hero:EmitSound("Arena.Gyro.CastQ.Voice")
end

function self:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function self:GetPlaybackRateOverride()
    return 1.33
end