modifier_sniper_w = class({})

function modifier_sniper_w:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_sniper_w:GetStatusEffectName()
    return "particles/status_fx/status_effect_techies_stasis.vpcf"
end