pa_q = class({})

function pa_q:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorPosition()
    local direction = target - caster:GetOrigin()
    local ability = self

    local maxSpeed = 1300

    if direction:Length2D() == 0 then
        direction = caster:GetForwardVector()
    end

    local projectileData = {}
    projectileData.owner = caster
    projectileData.from = caster:GetOrigin()
    projectileData.to = target
    projectileData.graphics = "particles/pa_q/pa_q.vpcf"
    projectileData.radius = 64

    Misc:SetUpPAProjectile(projectileData)

    projectileData.positionMethod =
        function(self)
            local dif = (self.owner:GetPos() - self.position)
            dif = Vector(dif.x, dif.y, 0):Normalized()

            self.velocity = self.velocity + dif * 32

            return self.position + (self.velocity * Misc:GetPASpeedMultiplier(self)) / 30
        end

    local projectile = Spells:CreateProjectile(projectileData)
    projectile.direction = Vector(direction.x, direction.y, 0):Normalized()
    projectile.velocity = projectile.direction * maxSpeed
    projectile.gracePeriod = {}
    projectile.gracePeriod[projectile.owner] = 30

    caster.paQProjectile = projectile
    caster:EmitSound("Arena.PA.Throw")

    Misc:RemovePAWeapon(caster)
end

function pa_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end