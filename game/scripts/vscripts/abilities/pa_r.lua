pa_r = class({})

LinkLuaModifier("modifier_pa_r", "abilities/modifier_pa_r", LUA_MODIFIER_MOTION_NONE)

function pa_r:OnSpellStart()
	local caster = self:GetCaster()

	caster:AddNewModifier(caster, self, "modifier_invis_fade", { duration = 0.2, invis_duration = 2.5, invis_modifier = "modifier_pa_r" })
	-- Add shuriken invis and speedup
end