storm_spirit_w = class({})

require("abilities/storm_spirit/projectile_storm_w")

function storm_spirit_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:AddNewModifier(hero, hero:FindAbility("storm_spirit_a"), "modifier_storm_spirit_a", { duration = 5 })
    hero:EmitSound("Arena.Storm.CastW")

    ProjectileStormW(hero.round, hero, target, self):Activate()
end