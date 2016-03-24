ProjectilePugnaQ = ProjectilePugnaQ or class({}, nil, Projectile)

function ProjectilePugnaQ:constructor(round, hero, target, secondary)
	Projectile.constructor(self, round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 900,
        graphics = "particles/pugna_q/pugna_q.vpcf",
        distance = 1400,
        hitFunction = function(projectile, target)
            if not projectile.owner:IsReversed() then
                target:Damage(projectile)
            else
                target:Heal()
            end

            self:CreateSecondProjectile(target, projectile.owner)

            target:EmitSound(projectile.owner:GetProjectileSound())
        end
    })
end

function ProjectilePugnaQ:Update()
	Projectile.Update(self)

	ParticleManager:SetParticleControl(self.graphics, 5, self.hero:GetProjectileColor())
end