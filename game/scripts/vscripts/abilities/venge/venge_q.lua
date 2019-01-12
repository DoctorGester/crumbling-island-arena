venge_q = class({})

function venge_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local trueHero = hero.hero or hero
    local ability = trueHero:FindAbility("venge_q")
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        ability = ability,
        owner = trueHero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/venge_q/venge_q.vpcf",
        distance = 950,
        hitSound = "Arena.Venge.HitQ",
        damage = ability:GetDamage(),
        hitModifier = { name = "modifier_stunned_lua", duration = 0.85, ability = ability }
    }):Activate()

    hero:EmitSound("Arena.Venge.CastQ")
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(venge_q)