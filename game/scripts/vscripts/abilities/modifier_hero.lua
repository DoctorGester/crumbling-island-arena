modifier_hero = class({})

function modifier_hero:IsHidden()
    return true
end

if IsClient() then
    return
end

function modifier_hero:IsForwardEmpty()
    local parent = self:GetParent()
    local forward = parent:GetForwardVector() * parent:GetBaseMoveSpeed() / 30 + parent:GetAbsOrigin()
    local trace = {
        startpos = forward,
        endpos = forward - Vector(0, 0, 128),
        ignore = parent
    }

    TraceLine(trace)

    return not trace.hit
end

function modifier_hero:CheckState()
    local state = {
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_hero:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT
    }

    return funcs
end

function modifier_hero:GetModifierMoveSpeed_Limit()
    if self:IsForwardEmpty() then
        return 20
    end
end

function modifier_hero:GetDisableHealing()
    return true
end