venge_q = class({})

function venge_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/venge_q/venge_q.vpcf",
        distance = 950,
        hitModifier = { name = "modifier_stunned_lua", duration = 0.85, ability = self },
        hitSound = "Arena.Venge.HitQ"
    }):Activate()

    hero:EmitSound("Arena.Venge.CastQ")
end