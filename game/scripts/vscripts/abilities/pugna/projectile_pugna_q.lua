ProjectilePugnaQPrimary = ProjectilePugnaQPrimary or class({}, nil, DistanceCappedProjectile)

function ProjectilePugnaQPrimary:constructor(round, hero, target)
	getbase(ProjectilePugnaQPrimary).constructor(self, round, {
        owner = hero,
        from = hero:GetPos() + Vector(0, 0, 64),
        to = target + Vector(0, 0, 64),
        speed = 1200,
        graphics = "particles/pugna_q/pugna_q.vpcf",
        distance = 1200,
        hitFunction = function(projectile, target)
            if not hero:IsReversed() then
                target:Damage(hero)
            else
                target:Heal()
            end

            local newOwner = target.hero

            if instanceof(target, Hero) then
                newOwner = target
            end

            if newOwner then
                ProjectilePugnaQSecondary(round, newOwner, hero, target:GetPos()):Activate()
            end

            target:EmitSound(hero:GetProjectileSound())

            self:Destroy()
        end
    })
end

function ProjectilePugnaQPrimary:Update()
	getbase(ProjectilePugnaQPrimary).Update(self)

	ParticleManager:SetParticleControl(self.particle, 5, self.hero:GetProjectileColor())
end

-- Secondary projectile class

ProjectilePugnaQSecondary = ProjectilePugnaQSecondary or class({}, nil, HomingProjectile)

function ProjectilePugnaQSecondary:constructor(round, hero, originalOwner, pos)
    getbase(ProjectilePugnaQSecondary).constructor(self, round, {
        owner = hero,
        from = pos + Vector(0, 0, 64),
        heightOffset = 64,
        target = originalOwner,
        speed = 900,
        graphics = "particles/pugna_q/pugna_q.vpcf",
        hitFunction = function(projectile, target)
            if originalOwner:IsReversed() then
                target:Damage(hero)
            else
                target:Heal()
            end

            target:EmitSound(originalOwner:GetTrapSound())
        end
    })
end

function ProjectilePugnaQSecondary:Update()
    getbase(ProjectilePugnaQSecondary).Update(self)

    ParticleManager:SetParticleControl(self.particle, 5, self.target:GetTrapColor())
end
