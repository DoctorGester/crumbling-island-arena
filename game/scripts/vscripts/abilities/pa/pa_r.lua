pa_r = class({})

LinkLuaModifier("modifier_pa_r", "abilities/pa/modifier_pa_r", LUA_MODIFIER_MOTION_NONE)

function pa_r:OnSpellStart()
	local hero = self:GetCaster().hero
	local params = { duration = 0.7, invis_duration = 5.0, invis_modifier = "modifier_pa_r" }
	hero:AddNewModifier(hero, self, "modifier_invis_fade", params)
	hero:EmitSound("Item.GlimmerCape.Activate")
end