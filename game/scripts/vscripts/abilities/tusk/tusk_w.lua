tusk_w = class({})

LinkLuaModifier("modifier_tusk_w", "abilities/tusk/modifier_tusk_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tusk_w_aura", "abilities/tusk/modifier_tusk_w_aura", LUA_MODIFIER_MOTION_NONE)

function tusk_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:AddNewModifier(hero, self, "modifier_tusk_w_aura", { duration = 3 })
end

function tusk_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_3
end

function tusk_w:GetPlaybackRateOverride()
    return 1.33
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(tusk_w)