sven_a = class({})

function sven_a:OnAbilityPhaseStart()
    local hero = self:GetCaster().hero
    hero:EmitSound("Arena.Sven.CastA")

    FX("particles/melee_attack_blur_configurable.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, {
        cp1 = Vector(SvenUtil.IsEnraged(hero) and 500 or 300, 0, 0),
        release = true
    })

    return true
end

function sven_a:OnSpellStart()
    Wrappers.DirectionalAbility(self, 300)

    local hero = self:GetCaster().hero
    local pos = hero:GetPos()
    local forward = self:GetDirection()
    local range = 300
    local damage = self:GetDamage()
    local force = 20

    if SvenUtil.IsEnraged(hero) then
        range = 500
        damage = 2
        force = 40
    end

    hero:AreaEffect({
        ability = self,
        filter = Filters.Cone(pos, range, forward, math.pi),
        sound = "Arena.Sven.HitA",
        damage = damage,
        isPhysical = true,
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)
            local direction = (pos - effectPos):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControlEnt(blood, 0, target.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", effectPos, true)
            ParticleManager:SetParticleControl(blood, 2, direction)

            SoftKnockback(target, hero, target:GetPos() - hero:GetPos(), force, { decrease = 3 })

            if SvenUtil.IsEnraged(hero) then
                local effect = ImmediateEffectPoint("particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_dust_gravelmaw.vpcf", PATTACH_ABSORIGIN, hero, effectPos)
                ParticleManager:SetParticleControl(effect, 1, effectPos + direction * 300)

                target:EmitSound("Arena.Sven.HitE")
            end
        end
    })
end

function sven_a:GetCastAnimation()
    return ACT_DOTA_ATTACK2
end

function sven_a:GetPlaybackRateOverride()
    return 3
end

if IsClient() then
    require("wrappers")
end

Wrappers.AttackAbility(sven_a)