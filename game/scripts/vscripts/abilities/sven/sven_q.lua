sven_q = class({})

function sven_q:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sven.CastQ")

    return true
end

function sven_q:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300

    if hero:IsEnraged() then
        range = 500
    end

    hero:AreaEffect({
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Sven.HitQ",
        damage = true,
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)
            local direction = (pos - effectPos):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControlEnt(blood, 0, target.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", effectPos, true)
            ParticleManager:SetParticleControl(blood, 2, direction)

            if hero:IsEnraged() then
                local effect = ImmediateEffectPoint("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_dust_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero, effectPos)
                ParticleManager:SetParticleControl(effect, 1, effectPos + direction * 300)

                target:EmitSound("Arena.Sven.HitE")
                KnockbackUnit(target, pos, 0.4, 300, 0, true)
            end
        end
    })
end

function sven_q:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

