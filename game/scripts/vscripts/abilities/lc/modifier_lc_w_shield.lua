modifier_lc_w_shield = class({})

function modifier_lc_w_shield:GetEffectName()
    return "particles/lc_w/lc_w.vpcf"
end

function modifier_lc_w_shield:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function modifier_lc_w_shield:OnDamageReceived(source, hero)
    self.health = (self.health or 2) - 1

    if self.health == 0 then
        self:Destroy()
        hero:AddNewModifier(hero, self:GetAbility(), "modifier_lc_w_speed", { duration = 4 })
    end

    return false
end

function modifier_lc_w_shield:OnDamageReceivedPriority()
    return 0
end