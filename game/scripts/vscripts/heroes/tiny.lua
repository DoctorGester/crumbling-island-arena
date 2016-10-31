Tiny = class({}, {}, Hero)

function Tiny:OnDeath(...)
    getbase(Tiny).OnDeath(self, ...)

    for _, part in pairs(self.wearables) do
        part:RemoveSelf()
    end

    self.wearables = {}

    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny01_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(index, 0, self:GetPos())
    ParticleManager:SetParticleControlForward(index, 0, self:GetFacing())
    ParticleManager:ReleaseParticleIndex(index)
end

function Tiny:HasModelChanged()
    return self:GetUnit():GetModelName() ~= "models/heroes/tiny_04/tiny_04.vmdl" and getbase(Tiny).HasModelChanged(self)
end
