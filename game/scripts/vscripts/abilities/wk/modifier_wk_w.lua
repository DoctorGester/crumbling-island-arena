modifier_wk_w = class({})

if IsServer() then
    function modifier_wk_w:OnCreated()
        local path = self:GetCaster():GetParentEntity():GetMappedParticle("particles/units/heroes/hero_skeletonking/skeletonking_hellfireblast_debuff.vpcf")
        local particle = FX(path, PATTACH_POINT_FOLLOW, self:GetParent(), {
            release = false
        })

        self:AddParticle(particle, false, false, -1, false, false)
    end
end

function modifier_wk_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }

    return funcs
end

function modifier_wk_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -34
end

function modifier_wk_w:IsDebuff()
    return true
end