modifier_pudge_r_aura = class({})

function modifier_pudge_r_aura:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_rot.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(index, 1, Vector(800, 0, 0))
        self:AddParticle(index, false, false, 1, false, false)

        parent:EmitSound("Arena.Pudge.LoopR")
    end
end

function modifier_pudge_r_aura:IsAura()
    return true
end

function modifier_pudge_r_aura:GetAuraRadius()
    return 800
end

function modifier_pudge_r_aura:GetAuraDuration()
    return 0.1
end

function modifier_pudge_r_aura:GetModifierAura()
    return "modifier_pudge_r"
end

function modifier_pudge_r_aura:CheckState()
    local state = {
        [MODIFIER_STATE_PROVIDES_VISION] = true
    }

    return state
end

function modifier_pudge_r_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_pudge_r_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_pudge_r_aura:OnDestroy()
    if IsServer() then
        local parent = self:GetParent()
        parent:StopSound("Arena.Pudge.LoopR")
    end
end