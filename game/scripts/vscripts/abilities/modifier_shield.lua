modifier_shield = class({})

local self = modifier_shield
local index

function self:GetTexture()
    return "rattletrap_power_cogs"
end

function self:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function self:OnDamageReceived(_, _, amount)
    self:SetStackCount(self:GetStackCount() - amount)

    if self:GetStackCount() <= 0 then
        self:Destroy()
    end

    if self:GetStackCount() < 0 then
        return -self:GetStackCount()
    end

    return false
end

function self:OnDamageReceivedPriority()
    return PRIORITY_SHIELD
end

if IsServer() then
    function self:OnCreated()
        self:StartIntervalThink(0.01)
    end

    function self:OnIntervalThink()
        local hero = self:GetParent():GetParentEntity()
        if self:GetStackCount() <= 2 then
            if index ~= nil then
                ParticleManager:DestroyParticle(index, false)
                ParticleManager:ReleaseParticleIndex(index)
            end
            index = ParticleManager:CreateParticle("particles/timber_shield/shredder_armor_lyr1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_armor", self:GetParent():GetOrigin(), true)
            self:AddParticle(index, false, false, -1, false, false)
        elseif self:GetStackCount() <= 3 and self:GetStackCount() > 2 then
            if index ~= nil then
                ParticleManager:DestroyParticle(index, false)
                ParticleManager:ReleaseParticleIndex(index)
            end
            index = ParticleManager:CreateParticle("particles/timber_shield/shredder_armor_2.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_armor", self:GetParent():GetOrigin(), true)
            self:AddParticle(index, false, false, -1, false, false)
        elseif self:GetStackCount() <= 4 and self:GetStackCount() > 3 then
            if index ~= nil then
                ParticleManager:DestroyParticle(index, false)
                ParticleManager:ReleaseParticleIndex(index)
            end
            index = ParticleManager:CreateParticle("particles/timber_shield/shredder_armor_3.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_armor", self:GetParent():GetOrigin(), true)
            self:AddParticle(index, false, false, -1, false, false)
        elseif self:GetStackCount() <= 8 and self:GetStackCount() > 4 then
            if index ~= nil then
                ParticleManager:DestroyParticle(index, false)
                ParticleManager:ReleaseParticleIndex(index)
            end
            index = ParticleManager:CreateParticle("particles/timber_shield/shredder_armor_4.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
            ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_armor", self:GetParent():GetOrigin(), true)
            self:AddParticle(index, false, false, -1, false, false)
        end
    end

    function self:OnDestroy()
        ParticleManager:DestroyParticle(index, false)
        ParticleManager:ReleaseParticleIndex(index)
    end
end
