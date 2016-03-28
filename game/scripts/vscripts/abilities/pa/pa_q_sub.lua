pa_q_sub = class({})

function pa_q_sub:OnSpellStart()
    local caster = self:GetCaster()

    local hero = self:GetCaster().hero

    self:SetActivated(false)
    hero:GetWeapon():Return()
end

function pa_q_sub:GetCastAnimation()
    return ACT_DOTA_CAST_ABILITY_1
end