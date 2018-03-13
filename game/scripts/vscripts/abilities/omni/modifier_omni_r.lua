modifier_omni_r = class({})
local self = modifier_omni_r

if IsServer() then
    function self:OnCreated()
        self:GetParent():GetParentEntity():EmitSound("Arena.Omni.HitR")
    end
end

function self:OnDamageReceived()
    return false
end

function self:OnDamageReceivedPriority()
    return PRIORITY_ABSOLUTE_SHIELD
end

function self:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
