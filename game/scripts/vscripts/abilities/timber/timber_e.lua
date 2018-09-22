timber_e = class({})

LinkLuaModifier("modifier_timber_chain_self", "abilities/timber/modifier_timber_chain_self", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timber_e", "abilities/timber/modifier_timber_e", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_timber_e_root", "abilities/timber/modifier_timber_e_root", LUA_MODIFIER_MOTION_NONE)

require("abilities/timber/projectile_timber_e")

function timber_e:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
    return true
end

function timber_e:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
end

function timber_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1450, 1450)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:SetFacing((target - hero:GetPos()) * Vector(1, 1, 0))

    ProjectileTimberE(hero.round, hero, target, self):Activate()

    hero:AddNewModifier(hero, self, "modifier_timber_chain_self", {})
    hero:EmitSound("Arena.Timber.CastE")
end

function timber_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function timber_e:GetPlaybackRateOverride()
    return 1.33
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(timber_e)