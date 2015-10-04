pa_r = class({})

LinkLuaModifier("modifier_pa_r", "abilities/pa/modifier_pa_r", LUA_MODIFIER_MOTION_NONE)

function pa_r:OnSpellStart()
	local caster = self:GetCaster()

	local params = { duration = 0.7, invis_duration = 5.0, invis_modifier = "modifier_pa_r" }
	caster:AddNewModifier(caster, self, "modifier_invis_fade", params)
	caster:EmitSound("Item.GlimmerCape.Activate")
end