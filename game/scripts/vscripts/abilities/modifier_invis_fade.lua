modifier_invis_fade = class({})

function modifier_invis_fade:OnCreated(params)
	self.invis_modifier = params.invis_modifier or "modifier_invis_plain"
	self.invis_duration = params.invis_duration or 10
end

function modifier_invis_fade:OnDestroy()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self:GetAbility(), self.invis_modifier, { duration = self.invis_duration })
	caster:AddNewModifier(caster, self:GetAbility(), "modifier_invisible", { duration = self.invis_duration })
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