modifier_zeus_w = class({})

function modifier_zeus_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_zeus_w:OnCreated()
    if IsServer() then
        self:GetCaster().hero:EmitSound("Arena.Zeus.HitW")
    end
end

function modifier_zeus_w:GetModifierMoveSpeedBonus_Percentage(params)
    return 30
end

function modifier_zeus_w:GetEffectName()
    return "particles/zeus_w_buff/zeus_w_buff.vpcf"
end

function modifier_zeus_w:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_zeus_w:GetActivityTranslationModifiers()
    return "haste"
end
