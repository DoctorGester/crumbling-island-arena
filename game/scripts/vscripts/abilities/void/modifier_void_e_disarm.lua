modifier_void_e_disarm = class({})

function modifier_void_e_disarm:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_void_e_disarm:IsDebuff()
    return true
end

function modifier_void_e_disarm:GetEffectName()
    return "particles/items2_fx/heavens_halberd_debuff.vpcf"
end