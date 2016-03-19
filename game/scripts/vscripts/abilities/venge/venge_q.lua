venge_q = class({})

function venge_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local projectile = Projectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1250,
        graphics = "particles/venge_q/venge_q.vpcf",
        distance = 950,
        hitModifier = { name = "modifier_stunned", duration = 1.0, ability = self },
        hitSound = "Arena.Venge.HitQ"
    })

    hero.round.spells:AddDynamicEntity(projectile)
    hero:EmitSound("Arena.Venge.CastQ")
end