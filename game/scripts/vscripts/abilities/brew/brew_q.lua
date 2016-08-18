brew_q = class({})

LinkLuaModifier("modifier_brew_beer", "abilities/brew/modifier_brew_beer", LUA_MODIFIER_MOTION_NONE)

function brew_q:AddBeerModifier(target)
    if self:CountBeer(target) < 6 then
        target:AddNewModifier(self:GetCaster().hero, self, "modifier_brew_beer", { duration = 9.5 })
    end
end

function brew_q:CountBeer(target)
    return #target:GetUnit():FindAllModifiersByName("modifier_brew_beer")
end

function brew_q:ClearBeer(target)
    for _, modifier in pairs(target:GetUnit():FindAllModifiersByName("modifier_brew_beer")) do
        modifier:Destroy()
    end
end

function brew_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 2000)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local projectile = ArcProjectile(self.round, {
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 2400,
        arc = 600,
        graphics = "particles/brew_q/brew_q.vpcf",
        hitParams = {
            filter = Filters.Area(target, 200),
            filterProjectiles = true,
            onlyHeroes = true,
            action = function(victim)
                self:AddBeerModifier(victim)
            end
        },
        hitScreenShake = true,
        hitFunction = function(projectile, hit)
            if hit then
                projectile:EmitSound("Arena.Brew.HitQ")
            end
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