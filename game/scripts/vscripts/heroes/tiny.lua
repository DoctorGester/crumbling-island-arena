Tiny = class({}, {}, Hero)

function Tiny:SetOwner(owner)
    getbase(Tiny).SetOwner(self, owner)

    TinyUtil.ChangeModelLevel(self, 1, 2)

    self:GetUnit():SetModel("models/heroes/tiny_02/tiny_02.vmdl")
    self:GetUnit():SetOriginalModel("models/heroes/tiny_02/tiny_02.vmdl")

    self:AddComponent(TinyComponent())
end

function Tiny:OnDeath(...)
    getbase(Tiny).OnDeath(self, ...)

    local index = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny01_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
    ParticleManager:SetParticleControl(index, 0, self:GetPos())
    ParticleManager:SetParticleControlForward(index, 0, self:GetFacing())
    ParticleManager:ReleaseParticleIndex(index)
end