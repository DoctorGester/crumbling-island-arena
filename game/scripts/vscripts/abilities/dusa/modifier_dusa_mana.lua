modifier_dusa_mana = class({})
local self = modifier_dusa_mana

function self:DestroyOnExpire()
    return false
end

if IsServer() then
    function self:OnCreated()
        self:StartIntervalThink(0.1)
        self.restored = true
    end

    function self:OnIntervalThink()
        if self:GetRemainingTime() <= 0 and not self.restored then
            self:GetParent():GetParentEntity():RestoreMana()
            self.restored = true
        end

        if self:GetParent():GetMana() < self:GetParent():GetMaxMana() and self:GetRemainingTime() <= 0 then
            self:SetDuration(10, true)
            self.restored = false
        end
    end

    function self:GetModifierMoveSpeedBonus_Constant()
        return self:GetParent():GetMana() * 30
    end

    function self:DeclareFunctions()
        local funcs = {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
        }

        return funcs
    end
end