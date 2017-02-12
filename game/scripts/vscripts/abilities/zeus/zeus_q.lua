zeus_q = class({})

function zeus_q:DestroyParticle()
    if self.particle then
        ParticleManager:DestroyParticle(self.particle, false)
        ParticleManager:ReleaseParticleIndex(self.particle)

        self.particle = nil
    end
end

function zeus_q:OnAbilityPhaseStart()
    Wrappers.DirectionalAbility(self, 1200)

    self.particle = FX("particles/zeus_q/zeus_q_target.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster(), {
        cp0 = self:GetCursorPosition()
    })

    FX("particles/units/heroes/hero_zuus/zuus_lightning_bolt_start.vpcf", PATTACH_POINT, self:GetCaster(), {
        cp0 = { ent = self:GetCaster(), point = "attach_attack1" },
        release = true
    })

    self:GetCaster():EmitSound("Arena.Storm.HitA")

    return true
end

function zeus_q:OnAbilityPhaseInterrupted()
    self:DestroyParticle()
end

function zeus_q:OnSpellStart()
    self:DestroyParticle()

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local skies = target + Vector(0, 0, 2000)
    local blank = not Spells.TestCircle(target, 16)
    if blank then
        target = target - Vector(0, 0, MAP_HEIGHT)
    end

    FX("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_CUSTOMORIGIN, hero, {
        cp0 = target,
        cp1 = skies,
        release = true
    })

    if not blank then
        FX("particles/econ/items/zeus/lightning_weapon_fx/zuus_lightning_bolt_groundfx_crack.vpcf", PATTACH_CUSTOMORIGIN, hero, {
            cp3 = target,
            release = true
        })

        Spells:GroundDamage(target, 175, hero)
    end

    ScreenShake(target, 5, 150, 0.35, 4000, 0, true)

    hero:AreaEffect({
        ability = self,
        filter = Filters.Area(target, 175),
        damage = self:GetDamage(),
        action = function(victim)
            ZeusUtil.AbilityHit(hero, self, victim)
        end
    })

    hero:EmitSound("Arena.Zeus.CastQ")
end

function zeus_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end