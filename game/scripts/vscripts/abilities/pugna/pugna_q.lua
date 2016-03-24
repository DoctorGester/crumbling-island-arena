pugna_q = class({})

function pugna_q:CreateSecondProjectile(owner, originalOwner)
    local projectileData = {}
    projectileData.owner = owner
    projectileData.from = owner:GetPos() + Vector(0, 0, 64)
    projectileData.graphics = "particles/pugna_q/pugna_q.vpcf"
    projectileData.radius = 64
    projectileData.positionMethod =
        function(self)
            local dif = (originalOwner:GetPos() - self.position)
            dif = Vector(dif.x, dif.y, 0):Normalized() * 800

            return self.position + dif / 30
        end

    projectileData.heroBehaviour =
        function(self, target)
            if originalOwner:IsReversed() then
                Spells:ProjectileDamage(self, target)
            else
                target:Heal()
            end

            target:EmitSound(originalOwner:GetTrapSound())

            return true
        end

    projectileData.onMove =
        function(self, prev, pos)
            ParticleManager:SetParticleControl(self.effectId, 5, originalOwner:GetTrapColor())
        end

    local p = Spells:CreateProjectile(projectileData)
    ParticleManager:SetParticleControl(p.effectId, 5, originalOwner:GetTrapColor())
end

function pugna_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()
    local ability = self

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    if not hero:IsReversed() then
        if hero:GetHealth() > 1 then
            hero:Damage(hero)
        end
    else
        hero:Heal()
    end

    Projectile(hero.round, {
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
    }):Activate()

    local projectileData = {}
    projectileData.owner = hero
    projectileData.from = hero:GetPos() + Vector(0, 0, 64)
    projectileData.to = target + Vector(0, 0, 64)
    projectileData.velocity = 900
    projectileData.graphics = "particles/pugna_q/pugna_q.vpcf"
    projectileData.distance = 1400
    projectileData.radius = 64
    projectileData.heroBehaviour =
        function(self, target)
            if not self.owner:IsReversed() then
                Spells:ProjectileDamage(self, target)
            else
                target:Heal()
            end

            Timers:CreateTimer(0.05,
                function()
                    ability:CreateSecondProjectile(target, self.owner)
                end
            )

            target:EmitSound(self.owner:GetProjectileSound())

            return true
        end

    projectileData.onMove =
        function(self, prev, pos)
            ParticleManager:SetParticleControl(self.effectId, 5, self.owner:GetProjectileColor())

            if (pos - projectileData.from):Length2D() >= self.distance then
                self:Destroy()
            end
        end

    local p = Spells:CreateProjectile(projectileData)
    ParticleManager:SetParticleControl(p.effectId, 5, hero:GetProjectileColor())

    hero:EmitSound("Arena.Pugna.CastQ")
end

function pugna_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end