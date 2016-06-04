ld_q_sub = class({})

function ld_q_sub:OnAbilityPhaseStart()
    self:GetCaster():EmitSound("Arena.LD.PreQSub")
    return true
end

function ld_q_sub:OnSpellStart()
    Wrappers.DirectionalAbility(self)

    local hero = self:GetCaster().hero

    hero:AreaEffect({
        filter = Filters.Cone(hero:GetPos(), 300, self:GetDirection(), math.pi),
        sound = "Arena.LD.HitQSub",
        damage = true,
        action = function(target)
            local effectPos = target:GetPos() + Vector(0, 0, 64)
            local direction = (hero:GetPos() - effectPos):Normalized()
            local blood = ImmediateEffect("particles/units/heroes/hero_riki/riki_backstab_hit_blood.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:SetParticleControlEnt(blood, 0, target.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", effectPos, true)
            ParticleManager:SetParticleControl(blood, 2, direction)

            if hero:HasModifier("modifier_ld_e_sub") then
                target:AddNewModifier(hero, self, "modifier_ld_root", { duration = 1.5 })
            end
        end
    })
end

function ld_q_sub:GetCastAnimation()
    return ACT_DOTA_ATTACK
end

function ld_q_sub:GetPlaybackRateOverride()
    return 1.5
end