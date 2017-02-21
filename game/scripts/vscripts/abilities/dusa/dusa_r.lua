dusa_r = class({})
local self = dusa_r

LinkLuaModifier("modifier_dusa_r", "abilities/dusa/modifier_dusa_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dusa_r_aura", "abilities/dusa/modifier_dusa_r_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dusa_r_target", "abilities/dusa/modifier_dusa_r_target", LUA_MODIFIER_MOTION_NONE)

function self:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:AddNewModifier(hero, self, "modifier_dusa_r_aura", { duration = 4 })
    ScreenShake(hero:GetPos(), 5, 150, 0.25, 2000, 0, true)
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(dusa_r)