modifier_sven_r = class({})

function modifier_sven_r:OnCreated()
    if IsServer() then
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_spell_gods_strength.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
        self:AddParticle(index, false, false, -1, false, false)
        self:GetCaster():StartGesture(ACT_DOTA_OVERRIDE_ABILITY_4)
    end
end

function modifier_sven_r:GetStatusEffectName()
    return "particles/status_fx/status_effect_gods_strength.vpcf"
end

function modifier_sven_r:StatusEffectPriority()
    return 10
end

function modifier_sven_r:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE
    }

    return funcs
end

function modifier_sven_r:GetModifierMoveSpeedBonus_Percentage(params)
    return 15
end

function modifier_sven_r:GetModifierModelScale()
    return 30
end