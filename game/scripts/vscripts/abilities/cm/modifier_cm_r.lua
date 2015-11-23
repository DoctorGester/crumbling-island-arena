modifier_cm_r = class({})

function modifier_cm_r:IsAura()
    return true
end

function modifier_cm_r:GetAuraRadius()
    return 600
end

function modifier_cm_r:GetAuraDuration()
    return 0.1
end

function modifier_cm_r:GetModifierAura()
    return "modifier_cm_r_slow"
end

function modifier_cm_r:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_cm_r:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

function modifier_cm_r:GetEffectName()
    return "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_snow_arcana1.vpcf"
end

function modifier_cm_r:OnDestroy()
    if IsServer() then
        self:GetParent():StopSound("Arena.CM.LoopR")
        self:GetParent():RemoveSelf()
    end
end