pa_r = class({})

LinkLuaModifier("modifier_pa_r", "abilities/modifier_pa_r", LUA_MODIFIER_MOTION_NONE)

function pa_r:OnSpellStart()
	local caster = self:GetCaster()

	local params = { duration = 0.2, invis_duration = 3.5, invis_modifier = "modifier_pa_r" }
	caster:AddNewModifier(caster, self, "modifier_invis_fade", params)
end