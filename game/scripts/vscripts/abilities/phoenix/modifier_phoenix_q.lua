modifier_phoenix_q = class({})

function modifier_phoenix_q:OnCreated()
    if IsServer() then
        local p = self:GetParent()
        local o = p:GetOrigin()
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_icarus_dive.vpcf", PATTACH_ABSORIGIN_FOLLOW, p)
        ParticleManager:SetParticleControlEnt(index, 1, p, PATTACH_POINT_FOLLOW, "attach_hitloc", o, true)
        ParticleManager:SetParticleControlEnt(index, 4, p, PATTACH_POINT_FOLLOW, "attach_hitloc", o, true)
        ParticleManager:SetParticleControlEnt(index, 5, p, PATTACH_POINT_FOLLOW, "attach_wingtipL", o, true)
        ParticleManager:SetParticleControlEnt(index, 6, p, PATTACH_POINT_FOLLOW, "attach_wingtipR", o, true)

        self:AddParticle(index, false, false, -1, false, false)
    end
end

function modifier_phoenix_q:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end

function modifier_phoenix_q:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION
    }

    return funcs
end

function modifier_phoenix_q:GetOverrideAnimation(params)
    return ACT_DOTA_OVERRIDE_ABILITY_3
end

function modifier_phoenix_q:IsStunDebuff()
    return true
end

function modifier_phoenix_q:Airborne()
    return true
end