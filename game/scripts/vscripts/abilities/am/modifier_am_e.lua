modifier_am_e = class({})
local self = modifier_am_e

if IsServer() then
    function self:OnCreated()
        self.p1 = FX("particles/am_e/am_e.vpcf", PATTACH_ABSORIGIN, self:GetCaster(), {
            cp0 = { ent = self:GetParent(), point = "attach_attack1" }
        })

        self.p2 = FX("particles/am_e/am_e.vpcf", PATTACH_ABSORIGIN, self:GetCaster(), {
            cp0 = { ent = self:GetParent(), point = "attach_attack2" }
        })
    end

    function self:OnDestroy()
        Timers:CreateTimer(0.3, function()
            ParticleManager:DestroyParticle(self.p1, false)
            ParticleManager:DestroyParticle(self.p2, false)
            ParticleManager:ReleaseParticleIndex(self.p1)
            ParticleManager:ReleaseParticleIndex(self.p2)
        end)
    end
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_RATE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function self:GetOverrideAnimation(params)
    return ACT_DOTA_RUN
end

function self:GetOverrideAnimationWeight(params)
    return 1.0
end

function self:GetOverrideAnimationRate(params)
    return 2.4
end

function self:GetActivityTranslationModifiers()
    return "haste"
end
