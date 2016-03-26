modifier_creep = class({})

function modifier_creep:CheckState()
    local state = {
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_PROVIDES_VISION] = true
    }

    return state
end

function modifier_creep:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_creep:GetModifierProvidesFOWVision()
    return true
end

function modifier_creep:GetModifierMoveSpeedBonus_Percentage(params)
    local name = self:GetParent():GetUnitName()
    if name == "npc_dota_creep_goodguys_melee" or name == "npc_dota_creep_goodguys_ranged" then
        return -25
    end
end
