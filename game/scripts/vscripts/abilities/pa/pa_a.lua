pa_a = class({})

require("abilities/pa/projectile_pa_a")

function pa_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.PA.Throw")
    hero:WeaponLaunched(ProjectilePAA(hero.round, hero, target, self:GetDamage()):Activate())
end

function pa_a:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(pa_a)