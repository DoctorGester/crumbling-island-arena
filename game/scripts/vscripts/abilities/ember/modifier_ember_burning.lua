modifier_ember_burning = class({})

function modifier_ember_burning:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_ember_burning:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end

function modifier_ember_burning:GetTexture()
    return "ember_spirit_flame_guard"
end