Invoker = class({}, {}, Hero)

function Invoker:SetOwner(owner)
    getbase(Invoker).SetOwner(self, owner)

    local function AttachOrb(path, attach)
        self.orbs = self.orbs or {}

        local particle = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, self:GetUnit())
        ParticleManager:SetParticleControlEnt(particle, 1, self:GetUnit(), PATTACH_POINT_FOLLOW, attach, self:GetPos(), true)

        table.insert(self.orbs, particle)
    end

    local orbPattern = "particles/units/heroes/hero_invoker/invoker_%s_orb.vpcf"

    if self:IsAwardEnabled() then
        orbPattern = "particles/econ/items/invoker/invoker_apex/invoker_apex_%s_orb.vpcf"
    end

    for index, orb in ipairs({ "quas", "wex", "exort" }) do
        AttachOrb(string.format(orbPattern, orb), "attach_orb"..tostring(index))
    end
end

function Invoker:OnDeath()
    getbase(Invoker).OnDeath(self)

    for _, orb in pairs(self.orbs or {}) do
        ParticleManager:DestroyParticle(orb, false)
        ParticleManager:ReleaseParticleIndex(orb)
    end
end