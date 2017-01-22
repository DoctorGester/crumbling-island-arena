modifier_ursa_r = class({})

function modifier_ursa_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MODEL_SCALE
    }

    return funcs
end

function modifier_ursa_r:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true
    }

    return state
end

function modifier_ursa_r:GetModifierModelScale()
    return 30
end

function modifier_ursa_r:GetHeroEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_hero_effect.vpcf"
end

function modifier_ursa_r:HeroEffectPriority()
    return 10
end

function modifier_ursa_r:GetEffectName()
    return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_ursa_r:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ursa_r:AllowAbilityEffect(source)
    return source.owner.team == self:GetParent():GetParentEntity().owner.team
end

function modifier_ursa_r:OnDamageReceived()
    return false
end

function modifier_ursa_r:OnDamageReceivedPriority()
    return 1
end