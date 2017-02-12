modifier_am_e = class({})
local self = modifier_am_e

if IsServer() then
    function self:OnCreated()
        local hero = self:GetParent():GetParentEntity()

        self.p1 = FX(hero:GetMappedParticle("particles/am_e/am_e.vpcf"), PATTACH_ABSORIGIN, hero, {
            cp0 = { ent = self:GetParent(), point = "attach_attack1" }
        })

        self.p2 = FX(hero:GetMappedParticle("particles/am_e/am_e.vpcf"), PATTACH_ABSORIGIN, hero, {
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

function self:GetActivityTranslationModifiers()
    return "haste"
end
