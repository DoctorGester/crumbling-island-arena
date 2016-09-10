modifier_pl_q = class({})
local self = modifier_pl_q

if IsServer() then
    function self:OnCreated()
        local index = ParticleManager:CreateParticle("particles/pl_projectile/pl_projectile.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        self:GetParent():AddNoDraw()
    end

    function self:OnDestroy()
        self:GetParent():RemoveNoDraw()
    end
end

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