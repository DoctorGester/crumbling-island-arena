modifier_ta_w = class({})

if IsServer() then
    function modifier_ta_w:OnCreated()
        local owner = self:GetParent().hero.owner

        if owner then
            owner:Blind(self:GetCaster())
        end
    end

    function modifier_ta_w:OnDestroy()
        local owner = self:GetParent().hero.owner

        if owner then
            owner:ReturnVision(self:GetCaster())
        end
    end
end

function modifier_ta_w:IsDebuff()
    return true
end

function modifier_ta_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_ta_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -20
end

function modifier_ta_w:GetEffectName()
    return "particles/ta_w/ta_w_debuff.vpcf"
end

function modifier_ta_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end