modifier_hidden = class({})

function modifier_hidden:IsHidden()
    return true
end

function modifier_hidden:CheckState()
    local state = {
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_UNSELECTABLE] = self:GetParent():GetUnitName() == "npc_dota_hero_wisp",
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
        [MODIFIER_STATE_ROOTED] = true,
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_BLIND] = true
    }

    return state
end

function modifier_hidden:IsStunDebuff()
    return true
end