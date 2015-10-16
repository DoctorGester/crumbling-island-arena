earth_spirit_r = class({})
LinkLuaModifier("modifier_earth_spirit_remnant", "abilities/earth_spirit/modifier_earth_spirit_remnant", LUA_MODIFIER_MOTION_NONE)

function earth_spirit_r:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
end

function earth_spirit_r:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_5
end

function earth_spirit_r:GetChannelTime()
	return 0.5
end

function earth_spirit_r:OnChannelFinish()
	local hero = self:GetCaster().hero

	hero:AddNewModifier(hero, self, "modifier_earth_spirit_remnant", { duration = 3 })
end