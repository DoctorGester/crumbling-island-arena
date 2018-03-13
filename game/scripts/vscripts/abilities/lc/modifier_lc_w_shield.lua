modifier_lc_w_shield = class({})

function modifier_lc_w_shield:GetEffectName()
    return "particles/lc_w/lc_w.vpcf"
end

function modifier_lc_w_shield:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

if IsServer() then
    function modifier_lc_w_shield:OnCreated()
        self:SetStackCount(2)
    end
end

function modifier_lc_w_shield:OnDamageReceived(source, hero, amount)
    self:SetStackCount(self:GetStackCount() - amount)

    if self:GetStackCount() <= 0 then
        self:Destroy()
        hero:AddNewModifier(hero, self:GetAbility(), "modifier_lc_w_speed", { duration = 4 })
    end

    if self:GetStackCount() < 0 then
        return -self:GetStackCount()
    end

    return false
end

function modifier_lc_w_shield:OnDamageReceivedPriority()
    return -1
end
