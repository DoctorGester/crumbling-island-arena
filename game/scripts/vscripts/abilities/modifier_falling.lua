modifier_falling = class({})

if IsServer() then
    function modifier_falling:OnCreated()
        self:GetParent():StartGesture(ACT_DOTA_FLAIL)
    end
end

function modifier_falling:IsStunDebuff()
    return true
end

function modifier_falling:IsHidden()
    return true
end

function modifier_falling:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVISIBLE] = false
    }

    return state
end

function modifier_falling:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end