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
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_ursa_e:GetActivityTranslationModifiers()
    return "overpower"
end

function modifier_ursa_e:GetModifierMoveSpeedBonus_Percentage(params)
    return self:GetElapsedTime() / self:GetDuration() * 100
end

function modifier_ursa_e:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_ursa_e:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ursa_e:StatusEffectPriority()
    return 2
end

function modifier_ursa_e:GetStatusEffectName()
    return "particles/status_fx/status_effect_overpower.vpcf"
end
