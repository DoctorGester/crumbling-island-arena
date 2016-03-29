cm_q = class({})

function cm_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1500)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 128),
        to = target + Vector(0, 0, 128),
        speed = 1200,
        graphics = "particles/cm/cm_q.vpcf",
        distance = 1500,
        hitSound = "Arena.CM.HitQ",
        hitFunction = function(projectile, target)
            if hero:IsFrozen(target) then
                target:Damage(hero)
            end

            hero:Freeze(target, self)
        end
    }):Activate()

    hero:EmitSound("Arena.CM.CastQ")
end

function cm_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end