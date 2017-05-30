---@type CDOTA_Modifier_Lua
modifier_earth_spirit_remnant = class({})

if IsServer() then
    function modifier_earth_spirit_remnant:OnCreated()
        local index = FX("particles/earth_spirit_q/earth_spirit_q.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
            release = false
        })

        self:AddParticle(
        index,
        false,
        false,
        0,
        false,
        false
        )
    end
end

function modifier_earth_spirit_remnant:GetStatusEffectName()
    return "particles/status_fx/status_effect_earth_spirit_petrify.vpcf"
end

function modifier_earth_spirit_remnant:StatusEffectPriority()
    return 10
end

function modifier_earth_spirit_remnant:CheckState()
    local state = {
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
        [MODIFIER_STATE_STUNNED] = true
    }

    return state
end

function modifier_earth_spirit_remnant:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION_WEIGHT
    }

    return funcs
end

function modifier_earth_spirit_remnant:OnDestroy()
    if IsServer() then
        UnfreezeAnimation(self:GetParent())
    end
end

function modifier_earth_spirit_remnant:GetOverrideAnimation(params)
    return ACT_DOTA_VICTORY
end

function modifier_earth_spirit_remnant:GetOverrideAnimationWeight(params)
    return 1.0
end