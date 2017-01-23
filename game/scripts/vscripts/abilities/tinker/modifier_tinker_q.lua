modifier_tinker_q = class({})

function modifier_tinker_q:CheckState()
    return {
        [MODIFIER_STATE_DISARMED] = true
    }
end

function modifier_tinker_q:IsDebuff()
    return true
end