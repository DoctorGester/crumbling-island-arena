sven_q = class({})

function sven_q:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sven.CastQ")

    return true
end

function sven_q:OnSpellStart()
    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local f = hero:GetFacing() * Vector(1, 1, 0)
    local range = 300

    if hero:IsEnraged() then
        range = 500
    end

    local forward = pos + f * range

    Spells:MultipleHeroesDamage(hero,
        function (source, target)
            local distance = (target:GetPos() - pos):Length2D()
            local withinCone = hero:FilterCone(target:GetPos(), pos, pos + f, range)

            if target ~= source and distance <= range and withinCone then
                local effectPos = target:GetPos() + Vector(0, 0, 64)
                local direction = (pos - effectPos):Normalized()
                local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
                ParticleManager:SetParticleControlEnt(blood, 0, target.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", effectPos, true)
                ParticleManager:SetParticleControl(blood, 2, direction)

                target:EmitSound("Arena.Sven.HitQ")

                if hero:IsEnraged() then
                    local effect = ImmediateEffectPoint("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_dust_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero, effectPos)
                    ParticleManager:SetParticleControl(effect, 1, effectPos + direction * 300)

                    target:EmitSound("Arena.Sven.HitE")
                    KnockbackUnit(target, pos, 0.4, 300, 0, true)
                end

                return true
            end
        end
    )

    for _, projectile in ipairs(Projectiles) do
        local distance = (projectile.position - pos):Length2D()
        local withinCone = hero:FilterCone(projectile.position, pos, pos + f, range)

        if distance <= range and withinCone then
            Spells:ProjectileDestroyEffect(hero, projectile.position + Vector(0, 0, 64))
            projectile:Destroy()
        end
    end
end

function sven_q:GetCastAnimation()
    return ACT_DOTA_ATTACK
end