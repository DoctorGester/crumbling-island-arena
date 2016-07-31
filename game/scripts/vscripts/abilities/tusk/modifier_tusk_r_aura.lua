modifier_tusk_r_aura = class({})

if IsServer() then
    function modifier_tusk_r_aura:OnCreated(kv)
        local parent = GameRules:GetGameModeEntity()
        
        self:AddParticle(ParticleManager:CreateParticle("particles/tusk_r/tusk_r.vpcf", PATTACH_WORLDORIGIN, parent), false, false, 1, false, false)
        self:AddParticle(ParticleManager:CreateParticle("particles/rain_fx/econ_snow.vpcf", PATTACH_EYES_FOLLOW, parent), false, false, 1, false, false)

        parent:EmitSound("Arena.Tusk.CastR")
        parent:EmitSound("Arena.Tusk.LoopR")
    end

    function modifier_tusk_r_aura:OnDestroy()
        GameRules:GetGameModeEntity():StopSound("Arena.Tusk.LoopR")
    end
end

function modifier_tusk_r_aura:IsAura()
    return true
end

function modifier_tusk_r_aura:GetAuraRadius()
    return 65536
end

function modifier_tusk_r_aura:GetModifierAura()
    return "modifier_tusk_r"
end

function modifier_tusk_r_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_BOTH
end

function modifier_tusk_r_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_tusk_r_aura:GetAuraDuration()
    return 1.0
end