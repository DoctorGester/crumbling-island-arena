modifier_am_r = class({})
local self = modifier_am_r

if IsServer() then
    function self:OnCreated()
        local count = 0

        for i = 0, self:GetParent():GetAbilityCount() - 1 do
            local ability = self:GetParent():GetAbilityByIndex(i)

            if ability and not ability:IsHidden() and ability:IsActivated() and not ability:IsAttributeBonus() and not ability:IsCooldownReady() then
                count = count + 1
            end
        end

        self:SetStackCount(count)

        local particle = FX("particles/items_fx/diffusal_slow.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {})
        self:AddParticle(particle, false, false, -1, false, false)
    end
end

function self:IsDebuff()
    return true
end

function self:GetEffectName()
    return "particles/generic_gameplay/generic_silence.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function self:IsDebuff()
    return true
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return -20 * self:GetStackCount()
end