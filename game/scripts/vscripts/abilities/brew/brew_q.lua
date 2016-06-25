brew_q = class({})

LinkLuaModifier("modifier_brew_beer", "abilities/brew/modifier_brew_beer", LUA_MODIFIER_MOTION_NONE)

function brew_q:AddBeerModifier(target)
    local previous = target:FindModifier("modifier_brew_beer")
    local stacks = 0

    if previous then
        stacks = previous:GetStackCount()
    end

    local new = target:AddNewModifier(self:GetCaster().hero, self, "modifier_brew_beer", { duration = 5 })

    if new then
        new:SetStackCount(math.min(stacks + 1, 6))
    end
end

function brew_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 2000)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    PointTargetProjectile(self.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 2000,
        parabola = 600,
        graphics = "particles/brew_q/brew_q.vpcf",
        invulnerable = true,
        hitCondition = 
            function(self, target)
                return false
            end,
        targetReachedFunction =
            function(projectile)
                local hit = hero:AreaEffect({
                    filter = Filters.Area(target, 200),
                    filterProjectiles = true,
                    onlyHeroes = true,
                    action = function(victim)
                        self:AddBeerModifier(victim)
                    end
                })

                if hit then
                    self:EmitSound("Arena.Brew.HitQ")
                end

                ScreenShake(target, 5, 150, 0.25, 2000, 0, true)
                
            end
    }):Activate()

    CreateAOEMarker(hero, target, 200, 0.4, Vector(255, 106, 0))

    self:AddBeerModifier(hero)

    hero:EmitSound("Arena.Brew.CastQ")

    self.tick = (self.tick or 0) + 1

    if self.tick % 2 == 0 then
        hero:EmitSound("Arena.Brew.CastQ.Voice")
    end
end

function brew_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function brew_q:GetPlaybackRateOverride()
    return 1.33
end