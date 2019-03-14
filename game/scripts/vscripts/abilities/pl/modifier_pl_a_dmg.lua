modifier_pl_a_dmg = class({})
local self = modifier_pl_a_dmg

if IsServer() then
    function modifier_pl_a_dmg:OnCreated(kv)
        
        local path = self:GetParent():GetParentEntity():GetMappedParticle("particles/pl_a/pl_a_extra_damage.vpcf")
        local index = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

        local path = self:GetParent():GetParentEntity():GetMappedParticle("particles/pl_a/pl_a_extra_damage2.vpcf")
        local index = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)

    end
end