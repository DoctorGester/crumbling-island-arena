modifier_tusk_a = class({})

if IsServer() then
    function modifier_tusk_a:OnCreated()
        self:StartIntervalThink(5)
        self:SetDuration(5, true)
    end

    function modifier_tusk_a:OnIntervalThink()
        local index = FX("particles/units/heroes/hero_tusk/tusk_walruspunch_status.vpcf", PATTACH_POINT_FOLLOW, self:GetParent(), {
            cp0 = { ent = self:GetParent(), point = "attach_attack2"}
        })

        self:AddParticle(index, false, false, -1, false, false)
        self:StartIntervalThink(-1)
        self:GetParent():EmitSound("Arena.Tusk.LoopA")
    end
end

function modifier_tusk_a:DestroyOnExpire()
    return false
end