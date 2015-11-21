sk_w = class({})

LinkLuaModifier("modifier_sk_w", "abilities/sk/modifier_sk_w", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sk_w_aura", "abilities/sk/modifier_sk_w_aura", LUA_MODIFIER_MOTION_NONE)

function sk_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local holder = CreateUnitByName(DUMMY_UNIT, target, false, hero.unit, hero.unit, hero.unit:GetTeam())
    holder:AddNewModifier(holder, self, "modifier_sk_w_aura", { duration = 5 })
end

function sk_w:GetCastAnimation()
    return ACT_DOTA_OVERRIDE_ABILITY_2
end

function sk_w:GetAOERadius()
    return 400
end