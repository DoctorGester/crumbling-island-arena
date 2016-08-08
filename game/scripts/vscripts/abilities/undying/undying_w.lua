undying_w = class({})

LinkLuaModifier("modifier_undying_w", "abilities/undying/modifier_undying_w", LUA_MODIFIER_MOTION_NONE)

function undying_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local projectile = DistanceCappedProjectile(hero.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target ,
        speed = 800,
        distance = 1500,
        radius = 150,
        graphics = "particles/undying_w/undying_w.vpcf",
        continueOnHit = true,
        invulnerable = true,
        hitModifier = { name = "modifier_undying_w", duration = 1.5, ability = self },
        hitCondition = function(projectile, target)
            return projectile.owner.team ~= target.owner.team and not instanceof(target, Projectile)
        end
    }):Activate()

    projectile.Update = function(self)
        DistanceCappedProjectile.Update(self)

        self.soundTick = (self.soundTick or 0) + 1

        if self.soundTick % 8 == 0 and self.distancePassed <= self.distance * 0.8 then
            self:EmitSound("Arena.Undying.LoopW")
        end
    end
end

function undying_w:GetCastAnimation()
    return ACT_DOTA_UNDYING_SOUL_RIP
end

function undying_w:GetPlaybackRateOverride()
    return 1.66
end