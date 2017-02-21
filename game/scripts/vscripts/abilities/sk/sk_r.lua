sk_r = class({})

LinkLuaModifier("modifier_sk_r", "abilities/sk/modifier_sk_r", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sk_r_aura", "abilities/sk/modifier_sk_r_aura", LUA_MODIFIER_MOTION_NONE)

function sk_r:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local holder = CreateUnitByName(DUMMY_UNIT, target, false, hero.unit, hero.unit, hero.unit:GetTeam())
    holder:AddNewModifier(holder, self, "modifier_sk_r_aura", { duration = 7.5 })
    CreateAOEMarker(hero, target, 400, 7.5, Vector(212, 212, 144))
end

function sk_r:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_4
end