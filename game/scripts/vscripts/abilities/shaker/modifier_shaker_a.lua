modifier_shaker_a = class({})

if IsServer() then
    function modifier_shaker_a:OnCreated(kv)
        local path = self:GetParent():GetParentEntity():GetMappedParticle("particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_totem_buff_egset.vpcf")
        local index = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(index, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_totem", self:GetCaster():GetOrigin(), true)
        self:AddParticle(index, false, false, -1, false, false)
    end
end