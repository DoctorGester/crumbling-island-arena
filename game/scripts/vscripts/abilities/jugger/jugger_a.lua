jugger_a = class({})

require('abilities/jugger/jugger_sword')

function jugger_a:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.Jugger.PreA")
    return true
end

function jugger_a:OnSpellStart()
    local hero = self:GetCaster().hero
    local range = hero:GetSwordRange()

    Wrappers.DirectionalAbility(self, range, range)

    local target = self:GetCursorPosition()
    local effect = ImmediateEffect(hero:GetAttackParticle(), PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 2, hero:GetPos() + Vector(0, 0, 64))
    ParticleManager:SetParticleControl(effect, 3, target + Vector(0, 0, 64))
    ParticleManager:ReleaseParticleIndex(effect)

    --hero:StopSound("Arena.Jugger.PreQ")

    local hurt = hero:AreaEffect({
        filter = Filters.Line(hero:GetPos(), target, 64),
        sound = "Arena.TA.HitQ",
        action = function(victim)
            victim:Damage(hero, hero:HasModifier("modifier_jugger_r") and 3 or self:GetDamage())

            ImmediateEffect("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN, victim)
        end
    })

    if hero:HasModifier("modifier_jugger_r") then
        hero:UseUltiCharge()
        hero:EmitSound("Arena.Jugger.CastAEmp")
    else
        hero:EmitSound("Arena.Jugger.CastA")
    end

    ScreenShake(target, 5, 150, 0.25, 2000, 0, true)
end

function jugger_a:GetCastAnimation()
    return ACT_DOTA_ATTACK_EVENT
end

function jugger_a:GetPlaybackRateOverride()
    return 1.6
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(jugger_a)