sven_r = class({})
LinkLuaModifier("modifier_sven_r", "abilities/sven/modifier_sven_r", LUA_MODIFIER_MOTION_NONE)

function sven_r:OnSpellStart()
	local hero = self:GetCaster().hero
	hero:AddNewModifier(hero, self, "modifier_sven_r", { duration = 7 })
	hero:EmitSound("Arena.Sven.CastR")
	hero:EmitSound("Arena.Sven.CastRVoice")
	hero:ResetCooldowns()
end