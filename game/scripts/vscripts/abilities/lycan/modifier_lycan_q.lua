modifier_lycan_q = class({})

function modifier_lycan_q:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_DISARMED] = true,
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_lycan_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT
    }

    return funcs
end

function modifier_lycan_q:GetModifierMoveSpeed_Max(params)
    return 1100
end

function modifier_lycan_q:GetModifierIgnoreMovespeedLimit()
    return 1
end

function modifier_lycan_q:GetModifierMoveSpeedOverride(params)
    if IsServer() then
        if LycanUtil.IsTransformed(self:GetCaster():GetParentEntity()) then
            return 1000
        end
    end

    return 700
end

function modifier_lycan_q:DestroyOnExpire()
    return false
end