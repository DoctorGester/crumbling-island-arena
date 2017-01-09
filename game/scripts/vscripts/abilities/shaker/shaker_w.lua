shaker_w = class({})

function shaker_w:OnAbilityPhaseStart()
    self:GetCaster().hero:EmitSound("Arena.Shaker.PreQ")
    return true
end

function shaker_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()

    hero:AddNewModifier(hero, hero:FindAbility("shaker_a"), "modifier_shaker_a", { duration = 5 })
    hero:AreaEffect({
        filter = Filters.Area(pos, 400),
        damage = self:GetDamage(),
        filterProjectiles = true,
        action = function(target)
            local dir = pos - target:GetPos()

            Knockback(target, self, dir, math.max(20, dir:Length2D() - 96), 1300,
                function(dash, current)
                    local d = (dash.from - dash.to):Length2D()
                    local x = (dash.from - current):Length2D()
                    return ParabolaZ(80, d, x)
                end
            )
        end
    })

    local effect = ImmediateEffect("particles/units/heroes/hero_brewmaster/brewmaster_thunder_clap.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, pos)
    ParticleManager:SetParticleControl(effect, 1, Vector(350, 0, 0))

    ScreenShake(pos, 5, 150, 0.45, 3000, 0, true)
    hero:EmitSound("Arena.Shaker.CastW")
end

function shaker_w:GetPlaybackRateOverride()
    return 2.0
end

function shaker_w:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end