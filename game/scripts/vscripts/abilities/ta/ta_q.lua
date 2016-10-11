ta_q = class({})

function ta_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local target = self:GetCursorPosition()
    local direction = target - hero:GetPos()

    if direction:Length2D() == 0 then
        direction = hero:GetFacing()
    end

    local target = hero:GetPos() + direction:Normalized() * 500
    local height = Vector(0, 0, 64)

    local effect = ImmediateEffect(hero:GetMappedParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_psi_blade.vpcf"), PATTACH_ABSORIGIN, hero)
    ParticleManager:SetParticleControl(effect, 0, hero:GetPos() + height)
    ParticleManager:SetParticleControl(effect, 1, target + height)
    ParticleManager:SetParticleControl(effect, 3, target + height)

    local hurt = hero:AreaEffect({
        filter = Filters.Line(hero:GetPos(), target, 64),
        sound = "Arena.TA.HitQ",
        action = function(victim)
            if victim:HasModifier("modifier_ta_w") then
                hero:Heal()
                hero:EmitSound("Arena.TA.HitW")

                ImmediateEffect("particles/ta_w_heal/ta_w_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero)
            end

            victim:Damage(hero)

            local effect = ImmediateEffect(hero:GetMappedParticle("particles/units/heroes/hero_templar_assassin/templar_assassin_meld_hit.vpcf"), PATTACH_ABSORIGIN, hero)
            ParticleManager:SetParticleControlForward(effect, 0, direction:Normalized())
            ParticleManager:SetParticleControl(effect, 3, victim:GetPos())
        end
    })

    hero:EmitSound("Arena.TA.CastQ")

    if hurt then
        hero:FindAbility("ta_e"):EndCooldown()
    end
end

function ta_q:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function ta_q:GetPlaybackRateOverride()
    return 1.33
end