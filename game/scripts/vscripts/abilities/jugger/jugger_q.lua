jugger_q = class({})

require('abilities/jugger/jugger_sword')

function jugger_q:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.Jugger.PreQ")
    return true
end

function jugger_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local range = hero:GetSwordRange()

    Wrappers.DirectionalAbility(self, range, range)

    local target = self:GetCursorPosition()
    local effect = ImmediateEffect("particles/jugger_q/jugger_q.vpcf", PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 2, hero:GetPos() + Vector(0, 0, 64))
    ParticleManager:SetParticleControl(effect, 3, target + Vector(0, 0, 64))
    ParticleManager:ReleaseParticleIndex(effect)

    --hero:StopSound("Arena.Jugger.PreQ")

    local hurt = hero:AreaEffect({
        filter = Filters.Line(hero:GetPos(), target, 64),
        sound = "Arena.TA.HitQ",
        action = function(victim)
            victim:Damage(hero)

            ImmediateEffect("particles/units/heroes/hero_juggernaut/juggernaut_omni_slash_tgt.vpcf", PATTACH_ABSORIGIN, victim)
        end
    })

    if hero:HasModifier("modifier_jugger_r") then
        hero:UseUltiCharge()
        hero:EmitSound("Arena.Jugger.CastQEmp")
    else
        hero:EmitSound("Arena.Jugger.CastQ")
    end
end

function jugger_q:GetCastAnimation()
    return ACT_DOTA_ATTACK_EVENT
end

function jugger_q:GetPlaybackRateOverride()
    return 1.6
end