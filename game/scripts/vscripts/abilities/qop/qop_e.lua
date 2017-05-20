qop_e = class({})

function qop_e:OnSpellStart()
    Wrappers.DirectionalAbility(self, 1000)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    hero:EmitSound("Arena.QOP.CastE", hero:GetPos())
    hero:EmitSound("Arena.QOP.EndE", target)

    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:SetParticleControl(particle, 0, hero:GetPos())
    ParticleManager:SetParticleControl(particle, 1, target)
    ParticleManager:ReleaseParticleIndex(particle)

    hero:FindClearSpace(target, true)
    hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2_END, 2.0)

    particle = ParticleManager:CreateParticle("particles/units/heroes/hero_queenofpain/queen_blink_end.vpcf", PATTACH_ABSORIGIN, hero:GetUnit())
    ParticleManager:ReleaseParticleIndex(particle)

    hero:FindAbility("qop_r"):AbilityUsed(self)
end

function qop_e:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_2
end

function qop_e:GetPlaybackRateOverride()
    return 2
end

if IsClient() then
    require("wrappers")
end

Wrappers.NormalAbility(qop_e)