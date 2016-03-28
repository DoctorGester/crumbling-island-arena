pa_q = class({})

require("abilities/pa/projectile_pa_q")

function pa_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.PA.Throw")
    hero:WeaponLaunched(ProjectilePAQ(hero.round, hero, target):Activate())
end

function pa_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end