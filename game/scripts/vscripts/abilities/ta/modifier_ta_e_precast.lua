modifier_ta_e_precast = class({})



function modifier_ta_e_precast:OnAbilityPhaseInterrupted()
    local hero = self:GetParent():GetParentEntity()
    local modifier = hero:FindModifier("modifier_ta_e_precast")
    if modifier then
    	return
end



function modifier_ta_e_precast:IsHidden()
    return true
end