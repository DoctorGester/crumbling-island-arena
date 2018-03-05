pa_a = class({})

LinkLuaModifier("modifier_pa_a", "abilities/pa/modifier_pa_a", LUA_MODIFIER_MOTION_NONE)

require("abilities/pa/projectile_pa_a")

function pa_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.PA.Throw")
    hero:WeaponLaunched(ProjectilePAA(hero.round, hero, target, self:GetDamage(), self):Activate())
end

function pa_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function pa_a:GetIntrinsicModifierName()
    return "modifier_pa_a"
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(pa_a)