modifier_lc_w_speed = class({})

function modifier_lc_w_speed:OnCreated(kv)
    if IsServer() then
        local parent = self:GetParent()
        local origin = parent:GetAbsOrigin()
        local index = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_press.vpcf", PATTACH_ROOTBONE_FOLLOW, parent)
        ParticleManager:SetParticleControlEnt(index, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, false)
        ParticleManager:SetParticleControlEnt(index, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, false)
        ParticleManager:SetParticleControlEnt(index, 2, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, false)
        self:AddParticle(index, false, false, 1, false, false)
        parent:EmitSound("Arena.LC.HitW")
    end
end

function modifier_lc_w_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
    }

    return funcs
end

function modifier_lc_w_speed:GetModifierMoveSpeedBonus_Percentage(params)
    return 50
end

function modifier_lc_w_speed:GetModifierMoveSpeed_Max(params)
    return 700
end

function modifier_lc_w_speed:GetActivityTranslationModifiers()
    return "haste"
end
