pugna_q = class({})

require("abilities/pugna/projectile_pugna_q")

function pugna_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    if not hero:IsReversed() then
        if hero:GetHealth() > 1 then
            hero:Damage(hero)
        end
    else
        hero:Heal()
    end

    ProjectilePugnaQPrimary(hero.round, hero, target):Activate()

    hero:EmitSound("Arena.Pugna.CastQ")
end

function pugna_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end