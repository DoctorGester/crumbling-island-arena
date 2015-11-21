modifier_sk_w = class({})

function modifier_sk_w:OnCreated()
    if IsServer() then
        self:SetDuration(0.1, false)

        local owner = self:GetParent().hero.owner

        if owner then
            owner:Blind()
        end
    end
end

function modifier_sk_w:OnDestroy()
    if IsServer() then
        local owner = self:GetParent().hero.owner

        if owner then
            owner:ReturnVision()
        end
    end
end

function modifier_sk_w:IsDebuff()
    return true
end

function modifier_sk_w:GetStatusEffectName()
    return "particles/status_fx/status_effect_earth_spirit_boulderslow.vpcf"
end

function modifier_sk_w:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_sk_w:GetModifierMoveSpeedBonus_Percentage(params)
    return -20
end