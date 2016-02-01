modifier_tiny_q = class({})

if IsServer() then
    function modifier_tiny_q:OnCreated(kv)
        if kv.hidden then
            self:SetStackCount(1)
        end
    end
end

function modifier_tiny_q:IsHidden()
    return self:GetStackCount() == 1
end

function modifier_tiny_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_tiny_q:GetModifierMoveSpeedBonus_Percentage(params)
    return -30
end

function modifier_tiny_q:IsDebuff()
    return true
end

function modifier_tiny_q:GetEffectName()
    return "particles/tiny_q/tiny_q_slow.vpcf"
end

function modifier_tiny_q:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end