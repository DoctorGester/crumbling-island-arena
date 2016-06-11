modifier_pudge_e_animation = class({})

function modifier_pudge_e_animation:EmitDust()
    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_fissure_dust.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(index, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(index, 1, self:GetParent():GetAbsOrigin())
    self:AddParticle(index, false, false, 1, false, false)
end

function modifier_pudge_e_animation:OnCreated(kv)
    if IsServer() then
        self:EmitDust()
        self:StartIntervalThink(0.1)
    end
end

function modifier_pudge_e_animation:OnIntervalThink()
    if IsServer() then
        self:EmitDust()
        self:GetParent():EmitSound("Arena.Sven.StepE")
    end
end

function modifier_pudge_e_animation:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_pudge_e_animation:GetActivityTranslationModifiers()
    return "haste"
end

function modifier_pudge_e_animation:IsHidden()
    return true
end

function modifier_pudge_e_animation:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end

function modifier_pudge_e_animation:GetOverrideAnimationRate(params)
    return 2.5
end
