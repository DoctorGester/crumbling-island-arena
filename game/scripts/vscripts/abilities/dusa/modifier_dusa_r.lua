modifier_dusa_r = class({})
local self = modifier_dusa_r

function self:GetStatusEffectName()
    return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_FROZEN] = true
    }

    return state
end

function self:IsDebuff()
    return true
end

function self:IsStunDebuff()
    return true
end

function self:StatusEffectPriority()
    return 15
end