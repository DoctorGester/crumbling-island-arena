modifier_ember_w = class({})

function modifier_ember_w:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_ember_w:IsDebuff()
    return true
end

function modifier_ember_w:GetEffectName()
    return "particles/units/heroes/hero_ember_spirit/ember_spirit_searing_chains_debuff.vpcf"
end