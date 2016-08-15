modifier_dusa_e = class({})
local self = modifier_dusa_e

function self:GetEffectName()
    return "particles/units/heroes/hero_medusa/medusa_mana_shield.vpcf"
end

function self:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function self:OnDamageReceived(source, entity)
    FX("particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, entity, { release = true })
    FX("particles/units/heroes/hero_medusa/medusa_mana_shield_oom.vpcf", PATTACH_ABSORIGIN_FOLLOW, entity, { release = true })
    ScreenShake(self:GetParent():GetAbsOrigin(), 5, 150, 0.25, 2000, 0, true)
    self:GetParent():EmitSound("Arena.Medusa.HitE")

    self:Destroy()

    return false
end

function self:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
