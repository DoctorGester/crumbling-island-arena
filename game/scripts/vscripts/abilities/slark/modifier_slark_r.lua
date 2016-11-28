modifier_slark_r = class({})

if IsServer() then
    function modifier_slark_r:OnCreated()
        local p = self:GetParent()
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_slark/slark_shadow_dance.vpcf", PATTACH_ABSORIGIN_FOLLOW, p)
        ParticleManager:SetParticleControlEnt(index, 1, p, PATTACH_POINT_FOLLOW, nil, p:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(index, 3, p, PATTACH_POINT_FOLLOW, "attach_eyeL", p:GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(index, 4, p, PATTACH_POINT_FOLLOW, "attach_eyeR", p:GetAbsOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        self:StartIntervalThink(0.5)
    end

    function modifier_slark_r:OnIntervalThink()
        self:GetParent().hero:Heal(1)
    end
end

function modifier_slark_r:CheckState()
    local state = {
    }

    return state
end

function modifier_slark_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_slark_r:GetModifierMoveSpeedBonus_Percentage(params)
    return 50
end

function modifier_slark_r:GetActivityTranslationModifiers()
    return "shadow_dance"
end

function modifier_slark_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function modifier_slark_r:StatusEffectPriority()
    return 10
end