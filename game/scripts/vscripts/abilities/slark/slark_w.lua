slark_w = class({})

function slark_w:OnSpellStart()
    local hero = self:GetCaster().hero
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit())
    ParticleManager:SetParticleControlEnt(index, 1, hero:GetUnit(), PATTACH_ABSORIGIN_FOLLOW, nil, hero:GetPos(), true)
    ParticleManager:ReleaseParticleIndex(index)

    hero:EmitSound("Arena.Slark.PreW")

    Timers:CreateTimer(1.5, function()
        if hero:Alive() then
            local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_dark_pact_pulses.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero:GetUnit())
            ParticleManager:SetParticleControlEnt(index, 1, hero:GetUnit(), PATTACH_ABSORIGIN_FOLLOW, nil, hero:GetPos(), true)
            ParticleManager:SetParticleControl(index, 2, Vector(300, 0, 0))

            hero:GetUnit():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.5)

            if hero:GetHealth() > 1 then
                hero:Damage(hero)
            end

            hero:AreaEffect({
                filter = Filters.Area(hero:GetPos(), 300),
                damage = true,
                filterProjectiles = true
            })

            for _, modifier in pairs(hero:AllModifiers()) do
                if modifier:GetName() == "modifier_slark_q" then
                    modifier:SetPurged(true)
                end
            end

            hero:GetUnit():Purge(false, true, false, true, false)
            hero:EmitSound("Arena.Slark.CastW")
        end
    end)
end