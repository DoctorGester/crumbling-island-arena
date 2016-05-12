drow_w = class({})
LinkLuaModifier("modifier_drow_w", "abilities/drow/modifier_drow_w", LUA_MODIFIER_MOTION_NONE)

function drow_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local startPos = hero:GetPos()
    local direction = (target - startPos):Normalized()
    local position = startPos + direction * 2000

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_drow/drow_silence_wave.vpcf", PATTACH_CUSTOMORIGIN, hero:GetUnit())
    ParticleManager:SetParticleControl(particle, 0, hero:GetPos())
    ParticleManager:SetParticleControl(particle, 1, direction * 2000)

    DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target ,
        speed = 2000,
        distance = 1500,
        radius = 256,
        continueOnHit = true,
        invulnerable = true,
        hitModifier = { name = "modifier_drow_w", duration = 2.0, ability = self },
        hitCondition = function(projectile, target)
            return projectile.owner.team ~= target.owner.team and not instanceof(target, Projectile)
        end,
        hitFunction = function(projectile, target)
            local delta = 1 - math.min(1, (target:GetPos() - startPos):Length2D() / 1000)
            Knockback(target, self, direction, 500 * delta, 1000 * delta)
        end
    }):Activate()

    hero:EmitSound("Arena.Drow.CastW")
end

function drow_w:GetPlaybackRateOverride()
    return 2
end
