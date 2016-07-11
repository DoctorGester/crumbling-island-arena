invoker_r = class({})

function invoker_r:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()

    local particle = ParticleManager:CreateParticle("particles/invoker_r/invoker_r.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, target + Vector(0, 0, 3000) - self:GetDirection() * 2000)
    ParticleManager:SetParticleControl(particle, 1, target)
    ParticleManager:SetParticleControl(particle, 2, Vector(2, 0, 0))
    ParticleManager:ReleaseParticleIndex(particle)

    hero:EmitSound("Arena.Invoker.CastR", target)
    hero:EmitSound("Arena.Invoker.LoopR")

    Timers:CreateTimer(2, function()
        hero:StopSound("Arena.Invoker.LoopR")
        hero:EmitSound("Arena.Invoker.HitR", target)

        Spells:GroundDamage(target, 350)
        Spells:GroundDamage(target, 350)
        Spells:GroundDamage(target, 350)
        Spells:GroundDamage(target, 350)

        ScreenShake(target, 5, 150, 0.5, 4000, 0, true)

        if IsValidEntity(self) then
            local particle = ParticleManager:CreateParticle("particles/econ/items/clockwerk/clockwerk_paraflare/clockwerk_para_rocket_flare_explosion.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
            ParticleManager:SetParticleControl(particle, 3, target)
            ParticleManager:ReleaseParticleIndex(particle)
        end
    end)
end

function invoker_r:GetCastAnimation()
    return ACT_DOTA_CAST_CHAOS_METEOR
end
