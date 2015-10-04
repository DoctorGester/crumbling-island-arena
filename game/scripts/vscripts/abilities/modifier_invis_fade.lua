modifier_invis_fade = class({})

-- modifier_invisible
-- modifier_permanent_invisibility
-- modifier_riki_permanent_invisibility

function modifier_invis_fade:OnCreated(params)
	self.invis_modifier = params.invis_modifier or "modifier_invis_plain"
	self.invis_duration = params.invis_duration or 10

	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_persistent_invisibility", { duration = self.invis_duration, fadetime = params.duration })
	end
end

function modifier_invis_fade:OnDestroy()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), self.invis_modifier, { duration = self.invis_duration })
	end
end

function modifier_invis_fade:IsHidden()
	return true
end

function modifier_invis_fade:GetEffectName()
	return "particles/generic_hero_status/status_invisibility_start.vpcf"
end

function modifier_invis_fade:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end