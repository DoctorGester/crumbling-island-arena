undying_e = class({})

LinkLuaModifier("modifier_undying_e", "abilities/undying/modifier_undying_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undying_e_aura", "abilities/undying/modifier_undying_e_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_undying_e_target", "abilities/undying/modifier_undying_e_target", LUA_MODIFIER_MOTION_NONE)

require("abilities/undying/entity_undying_e")

function undying_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1200)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    EntityUndyingE(hero.round, hero, target, self):Activate()
    ScreenShake(target, 5, 150, 0.45, 3000, 0, true)
end

function undying_e:GetCastAnimation()
    return ACT_DOTA_UNDYING_TOMBSTONE
end

function undying_e:GetPlaybackRateOverride()
    return 1.33
end