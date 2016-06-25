brew_r = class({})

function brew_r:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    PointTargetProjectile(self.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 1900,
        parabola = 300,
        graphics = "particles/brew_r/brew_r.vpcf",
        invulnerable = true,
        hitCondition = 
            function(self, target)
                return false
            end,
        targetReachedFunction =
            function(projectile)
                hero:AreaEffect({
                    filter = Filters.Area(target, 400),
                    filterProjectiles = true,
                    hitSelf = true,
                    hitAllies = true,
                    action = function(victim)
                        local q = hero:FindAbility("brew_q")

                        q:AddBeerModifier(victim)
                        q:AddBeerModifier(victim)

                        Knockback(victim, self, victim:GetPos() - target, 350, 1500, DashParabola(80))

                        if victim.owner.team ~= hero.owner.team then
                            victim:Damage(hero)
                        end
                    end
                })

                ScreenShake(target, 5, 250, 0.45, 3000, 0, true)
                self:EmitSound("Arena.Brew.HitR")
            end
    }):Activate()

    hero:EmitSound("Arena.Brew.CastR")
end

function brew_r:GetCastAnimation()
    return ACT_DOTA_ATTACK_EVENT
end

function brew_r:GetPlaybackRateOverride()
    return 2
end