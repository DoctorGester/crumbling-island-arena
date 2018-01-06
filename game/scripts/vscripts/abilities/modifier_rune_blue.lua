modifier_rune_blue = class({})

function modifier_rune_blue:GetTexture()
    return "rune_doubledamage"
end

function modifier_rune_blue:GetEffectName()
    return "particles/generic_gameplay/rune_doubledamage_owner.vpcf"
end

function modifier_rune_blue:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
