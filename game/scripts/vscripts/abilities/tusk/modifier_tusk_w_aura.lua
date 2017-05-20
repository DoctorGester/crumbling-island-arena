modifier_tusk_w_aura = class({})
if IsServer() then
    function modifier_tusk_w_aura:OnCreated(kv)
        local parent = self:GetParent()
        
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(particle, 1, Vector(800, 1, 1))
        ParticleManager:SetParticleControlEnt(particle, 2, parent, PATTACH_POINT_FOLLOW, "attach_attack2", parent:GetOrigin(), true)

        self:AddParticle(particle, false, false, 1, false, false)

        particle = ParticleManager:CreateParticle("particles/aoe_marker.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:SetParticleControl(particle, 1, Vector(500, 1, 1))
        ParticleManager:SetParticleControl(particle, 2, Vector(0, 225, 215))
        ParticleManager:SetParticleControl(particle, 3, Vector(self:GetDuration(), 0, 0))

        self:AddParticle(particle, false, false, 1, false, false)

        parent:EmitSound("Arena.Tusk.CastW")
        parent:EmitSound("Arena.Tusk.LoopW")
    end

    function modifier_tusk_w_aura:OnDestroy()
        self:GetParent():StopSound("Arena.Tusk.LoopW")
    end
end

function modifier_tusk_w_aura:IsAura()
    return true
end

function modifier_tusk_w_aura:GetAuraRadius()
    return 500
end

function modifier_tusk_w_aura:GetModifierAura()
    return "modifier_tusk_w"
end

function modifier_tusk_w_aura:GetAuraEntityReject(entity)
    if entity.GetParentEntity and entity:GetParentEntity().owner and entity:GetParentEntity().owner.team == self:GetParent():GetParentEntity().owner.team then
        return true
    end

    return false
end

function modifier_tusk_w_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_tusk_w_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_tusk_w_aura:GetAuraDuration()
    return 0.1
end