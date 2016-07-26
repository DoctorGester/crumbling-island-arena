Tiny = class({}, {}, Hero)

function Tiny:SetUnit(unit)
    getbase(Tiny).SetUnit(self, unit)

    for _, part in pairs({ "body", "head", "left_arm", "right_arm" }) do
        self:AttachWearable("models/heroes/tiny_01/tiny_01_"..part..".vmdl")
    end
end

function Tiny:Damage(...)
    getbase(Tiny).Damage(self, ...)

    if not self:Alive() then
        for _, part in pairs(self.wearables) do
            part:RemoveSelf()
        end

        self.wearables = {}

        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_tiny/tiny01_death.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(index, 0, self:GetPos())
        ParticleManager:SetParticleControlForward(index, 0, self:GetFacing())
        ParticleManager:ReleaseParticleIndex(index)
    end
end