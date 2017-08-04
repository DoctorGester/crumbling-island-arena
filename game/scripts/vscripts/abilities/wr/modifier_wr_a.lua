modifier_wr_a = class({})

if IsServer() then
    function modifier_wr_a:OnCreated()
        self:StartIntervalThink(0)

        self:GetParent():GetParentEntity():EmitSound("Arena.WR.Haste")
    end

    function modifier_wr_a:OnIntervalThink()
        if self:GetParent():IsMoving() and not self:GetParent():HasModifier("modifier_wr_e") then
            self:DecrementStackCount()

            if self:GetStackCount() == 0 then
                self:Destroy()
            end
        end
    end

    function modifier_wr_a:OnDestroy()
        self:GetParent():GetParentEntity():StopSound("Arena.WR.Haste")
    end
end

function modifier_wr_a:CheckState()
    return {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_wr_a:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
        MODIFIER_PROPERTY_MOVESPEED_MAX
    }

    return funcs
end

function modifier_wr_a:GetModifierMoveSpeedOverride(params)
    return 1000
end

function modifier_wr_a:GetModifierMoveSpeedBonus_Percentage(params)
    return 80
end

function modifier_wr_a:GetActivityTranslationModifiers()
    return "windrun"
end

function modifier_wr_a:GetEffectName()
    return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function modifier_wr_a:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end