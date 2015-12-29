modifier_lc_r_aura = class({})

function modifier_lc_r_aura:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        local index = ParticleManager:CreateParticle("particles/lc_r/lc_r.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:SetParticleControl(index, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(index, 7, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(index, 8, Vector(400, 1, 1))
        self:AddParticle(index, false, false, 1, false, false)

        parent:EmitSound("Arena.LC.CastR")
        parent:EmitSound("Arena.LC.LoopR")
    end
end

function modifier_lc_r_aura:IsAura()
    return true
end

function modifier_lc_r_aura:GetAuraRadius()
    return 400
end

function modifier_lc_r_aura:GetModifierAura()
    return "modifier_lc_r"
end

function modifier_lc_r_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_lc_r_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_lc_r_aura:GetAuraDuration()
    return 0.1
end

function modifier_lc_r_aura:OnDestroy()
    if IsServer() then
        self:GetParent():StopSound("Arena.LC.LoopR")
        self:GetParent():RemoveSelf()
    end
end