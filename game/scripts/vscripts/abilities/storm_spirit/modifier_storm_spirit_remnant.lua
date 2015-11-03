modifier_storm_spirit_remnant = class({})

function modifier_storm_spirit_remnant:OnCreated()
    if IsServer() then
        local id = ParticleManager:CreateParticle("particles/units/heroes/hero_stormspirit/stormspirit_static_remnant.vpcf", PATTACH_ABSORIGIN, self:GetParent())
        self:AddParticle(id, false, true, 1, false, false)
    end
end

function modifier_storm_spirit_remnant:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_NOT_ON_MINIMAP] = true,
        [MODIFIER_STATE_UNSELECTABLE] = true,
        [MODIFIER_STATE_COMMAND_RESTRICTED] = true
    }

    return state
end

function modifier_storm_spirit_remnant:GetStatusEffectName()
    return "particles/status_fx/status_effect_ancestral_spirit.vpcf"
end