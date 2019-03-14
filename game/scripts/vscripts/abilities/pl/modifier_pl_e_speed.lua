modifier_pl_e_speed = class({})
local self = modifier_pl_e_speed

function self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
    }

    return funcs
end

function self:GetModifierMoveSpeedBonus_Percentage(params)
    return 40
end

function self:GetActivityTranslationModifiers()
    return "haste"
end

function self:GetEffectName()
    return "particles/units/heroes/hero_phantom_lancer/phantomlancer_edge_boost.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ROOTBONE_FOLLOW
end

function self:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function self:GetModifierMoveSpeed_Max(params)
    return 800
end
