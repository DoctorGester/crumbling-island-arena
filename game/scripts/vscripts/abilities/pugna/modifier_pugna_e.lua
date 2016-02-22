modifier_pugna_e = class({})

if IsServer() then
    function modifier_pugna_e:OnCreated()
        if self:GetAbility():GetToggleState() then
            self:SetStackCount(1)
        end
    end
end

function modifier_pugna_e:GetStatusEffectName()
    if self:GetStackCount() == 0 then
        return "particles/pugna_e/status_effect_pugna_e.vpcf"
    end
end

function modifier_pugna_e:StatusEffectPriority()
    return 10
end

function modifier_pugna_e:IsHidden()
    return self:GetStackCount() == 0
end