modifier_ember_e = class({})

if IsServer() then
    function modifier_ember_e:OnCreated()
        local index = ParticleManager:CreateParticle("particles/ember_e/ember_e.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        self:GetParent():GetParentEntity():SetHidden(true)
    end

    function modifier_ember_e:OnDestroy()
        self:GetParent():GetParentEntity():SetHidden(false)
    end
end

function modifier_ember_e:CheckState()
    local state = {
        [MODIFIER_STATE_STUNNED] = true,
        [MODIFIER_STATE_NO_HEALTH_BAR] = true
    }

    return state
end

function modifier_ember_e:Airborne()
    return true
end