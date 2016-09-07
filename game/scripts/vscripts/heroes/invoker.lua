Invoker = class({}, {}, Hero)

function Invoker:GetAwardSeason()
    return 2
end

function Invoker:SetOwner(owner)
    getbase(Invoker).SetOwner(self, owner)

    local function AttachOrb(path, attach)
        self.orbs = self.orbs or {}

        local particle = ParticleManager:CreateParticle(path, PATTACH_POINT_FOLLOW, self:GetUnit())
        ParticleManager:SetParticleControlEnt(particle, 1, self:GetUnit(), PATTACH_POINT_FOLLOW, attach, self:GetPos(), true)

        table.insert(self.orbs, particle)
    end

    local pattern = "models/heroes/invoker/invoker_%s.vmdl"
    local parts = { "bracer", "cape", "head", "dress", "shoulder", "hair" }
    local orbPattern = "particles/units/heroes/hero_invoker/invoker_%s_orb.vpcf"

    if self:IsAwardEnabled() then
        pattern = "models/items/invoker/dark_artistry/dark_artistry_%s_model.vmdl"
        parts = { "bracer", "cape", "hair", "belt", "shoulder" }
        orbPattern = "particles/econ/items/invoker/invoker_apex/invoker_apex_%s_orb.vpcf"

        self:AttachWearable("models/heroes/invoker/invoker_head.vmdl")
    end

    for _, part in pairs(parts) do
        self:AttachWearable(string.format(pattern, part))
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