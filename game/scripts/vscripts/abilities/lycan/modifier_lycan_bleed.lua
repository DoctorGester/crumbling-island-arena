modifier_lycan_bleed = class({})

function modifier_lycan_bleed:IsDebuff()
    return true
end

function modifier_lycan_bleed:GetEffectName()
    return "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf"
end

function modifier_lycan_bleed:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_lycan_bleed:GetTexture()
    return "bloodseeker_rupture"
end

function modifier_lycan_bleed:CheckState()
    local state = {
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

function modifier_lycan_bleed:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end