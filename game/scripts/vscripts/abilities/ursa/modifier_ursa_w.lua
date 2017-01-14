modifier_ursa_w = class({})

if IsServer() then
    function modifier_ursa_w:OnCreated(kv)
        local caster = self:GetCaster()
        local origin = caster:GetOrigin()

        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControlEnt(index, 0, caster, PATTACH_POINT_FOLLOW, "attach_head", origin, true)
        ParticleManager:SetParticleControlEnt(index, 2, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)
        ParticleManager:SetParticleControlEnt(index, 3, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)

        self:AddParticle(index, false, false, -1, false, false)
    end
end

function modifier_ursa_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_ursa_w:GetActivityTranslationModifiers()
    return "overpower"
end

function modifier_ursa_w:GetModifierMoveSpeedBonus_Percentage(params)
    return 40 + self:GetElapsedTime() / self:GetDuration() * 60
end

function modifier_ursa_w:StatusEffectPriority()
    return 2
end

function modifier_ursa_w:GetStatusEffectName()
    return "particles/status_fx/status_effect_overpower.vpcf"
end