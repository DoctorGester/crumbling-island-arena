modifier_gyro_e = class({})
local self = modifier_gyro_e

function self:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function self:Airborne()
    return true
end

function self:IsInvulnerable()
    return true
end