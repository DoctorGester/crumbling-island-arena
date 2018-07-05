modifier_ta_e_counter = class({})

function modifier_ta_e_counter:Update()
    if self.particle then
        DFX(self.particle)
    end

    self.particle = FX("particles/ta_e/ta_e_counter.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent(), {
        cp1 = Vector(self:GetStackCount(), 0, 0),
        release = false
    })
end

function modifier_ta_e_counter:OnDestroy()
    if self.particle then
        DFX(self.particle)
    end
end

function modifier_ta_e_counter:IsPermanent()
    return true
end

function modifier_ta_e_counter:IsHidden()
    return true
end