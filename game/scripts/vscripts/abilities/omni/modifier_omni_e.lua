modifier_omni_e = class({})
local self = modifier_omni_e

if IsServer() then
    function self:OnCreated()
        self:GetParent():GetParentEntity():EmitSound("Arena.Omni.LoopE")
    end

    function self:OnDestroy()
        self:GetParent():GetParentEntity():StopSound("Arena.Omni.LoopE")
    end
end

function self:IsInvulnerable()
    return true
end

function self:GetEffectName()
    return "particles/units/heroes/hero_omniknight/omniknight_repel_buff.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
