modifier_undying_w = class({})
local self = modifier_undying_w

function self:CheckState()
    local state = {
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function self:IsDebuff()
    return true
end

function self:GetEffectName()
    return "particles/undying_w/undyng_w_debuff.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
