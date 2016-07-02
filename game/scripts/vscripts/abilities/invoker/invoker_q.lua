invoker_q = class({})

function invoker_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local realTarget = target

    local blank = not Spells.TestPoint(target)
    if blank then
        realTarget = target - Vector(0, 0, MAP_HEIGHT)
    end

    local particle = ParticleManager:CreateParticle("particles/invoker_q/invoker_q_preview.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
    ParticleManager:SetParticleControl(particle, 0, realTarget)
    ParticleManager:ReleaseParticleIndex(particle)

    Timers:CreateTimer(1.1, function()
        blank = not Spells.TestPoint(target)

        hero:StopSound("Arena.Invoker.CastQ")
        hero:EmitSound("Arena.Invoker.HitQ", realTarget)

        if blank then
            realTarget = target - Vector(0, 0, MAP_HEIGHT)
        else
            hero:AreaEffect({
                filter = Filters.Area(target, 200),
                filterProjectiles = true,
                damage = true,
                action = function(victim)
                    if victim:HasModifier("modifier_invoker_w") then
                        victim:Damage(hero)
                    end
                end
            })

            ScreenShake(target, 5, 150, 0.25, 2000, 0, true)
            Spells:GroundDamage(target, 200)
        end

        local index =  ParticleManager:CreateParticle("particles/invoker_q/invoker_q.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(index, 0, realTarget)
        ParticleManager:ReleaseParticleIndex(index)
    end)

    hero:EmitSound("Arena.Invoker.CastQ", realTarget)
end

function invoker_q:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end