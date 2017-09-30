modifier_ursa_e = class({})

if IsServer() then
    function modifier_ursa_e:OnCreated(kv)
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()

        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(index, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", origin, true)
        ParticleManager:SetParticleControlEnt(index, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)
        ParticleManager:SetParticleControlEnt(index, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)

        self:AddParticle(index, false, false, -1, false, false)
    end
end

function modifier_ursa_e:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE
    }

    return funcs
end

function modifier_ursa_e:StatusEffectPriority()
    return 2
end

function modifier_ursa_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_ursa_e:IsInvulnerable()
    return true
end

function modifier_ursa_e:GetOverrideAnimation(params)
    return ACT_DOTA_CAST_ABILITY_3
end

function modifier_ursa_e:GetOverrideAnimationWeight(params)
    return 1.0
end

function modifier_ursa_e:GetOverrideAnimationRate(params)
    return 9.0
end