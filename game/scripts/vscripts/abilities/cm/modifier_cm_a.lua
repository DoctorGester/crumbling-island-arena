modifier_cm_a = class({})

if IsServer() then
    function modifier_cm_a:Inc()
        self:IncrementStackCount()

        if self:GetStackCount() == 3 then
            local p = self:GetParent()
            local path = p:GetParentEntity():GetMappedParticle("particles/cm_a/cm_a_empowered.vpcf")
            local index = FX(path, PATTACH_POINT_FOLLOW, p, {
                cp0 = { ent = p, point = "attach_attack1" },
                release = false
            })
            self:AddParticle(index, false, false, -1, false, false)
        end
    end
end