modifier_nevermore_w = class({})

function modifier_nevermore_w:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_nevermore_w:IsDebuff()
    return true
end

function modifier_nevermore_w:GetEffectName()
    return "particles/items2_fx/heavens_halberd_debuff.vpcf"
end