modifier_sk_r_aura = class({})

function modifier_sk_r_aura:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        local index = ParticleManager:CreateParticle("particles/sk_r/sk_r.vpcf", PATTACH_ABSORIGIN, parent)
        ParticleManager:SetParticleControl(index, 0, parent:GetAbsOrigin())
        ParticleManager:SetParticleControl(index, 1, Vector(400, 400, 400))
        self:AddParticle(index, false, false, 1, false, false)

        parent:EmitSound("Arena.SK.CastR")
        parent:EmitSound("Arena.SK.LoopR")
    end
end

function modifier_sk_r_aura:IsAura()
    return true
end

function modifier_sk_r_aura:GetAuraRadius()
    return 400
end

function modifier_sk_r_aura:GetAuraDuration()
    return 0.1
end

function modifier_sk_r_aura:GetModifierAura()
    return "modifier_sk_r"
end

function modifier_sk_r_aura:CheckState()
    local state = {
        [MODIFIER_STATE_PROVIDES_VISION] = true
    }

    return state
end

function modifier_sk_r_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_sk_r_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_sk_r_aura:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        parent:StopSound("Arena.SK.LoopR")
        parent:RemoveSelf()
    end
end