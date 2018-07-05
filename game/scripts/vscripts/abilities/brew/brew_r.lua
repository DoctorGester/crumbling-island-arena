brew_r = class({})

function brew_r:OnAbilityPhaseStart()
    local lastCast = self.lastCast or 0
    local now = Time()

    if now - lastCast > 1.5 then
        self:GetCaster():GetParentEntity():EmitSound("Arena.Brew.CastR.Voice")
        self.lastCast = now
    end

    return true
end

function brew_r:OnSpellStart()
    Wrappers.DirectionalAbility(self, 700)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    ArcProjectile(self.round, {
        ability = self,
        owner = hero,
        from = hero:GetPos(),
        to = target,
        speed = 1900,
        arc = 300,
        graphics = "particles/brew_r/brew_r.vpcf",
        hitParams = {
            ability = self,
            filter = Filters.Area(target, 400),
            filterProjectiles = true,
            hitSelf = true,
            hitAllies = true,
            damagesTrees = true,
            action = function(victim)
                local q = hero:FindAbility("brew_q")

                q:AddBeerModifier(victim)
                q:AddBeerModifier(victim)

               -- Knockback(victim, self, victim:GetPos() - target, 350, 1500, DashParabola(80))

                if victim.owner.team ~= hero.owner.team then
                    victim:Damage(hero, self:GetDamage())
                end
            end,
            knockback = {
                force = 80,
                knockup = 60,
                direction = function(v) return v:GetPos() - target end
            },
            modifier = { name = "modifier_stunned_lua", ability = self, duration = 0.5 }
        },
        hitSound = "Arena.Brew.HitR",
        hitFunction = function(projectile, hit)
            ScreenShake(target, 5, 250, 0.45, 3000, 0, true)
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

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(brew_r)