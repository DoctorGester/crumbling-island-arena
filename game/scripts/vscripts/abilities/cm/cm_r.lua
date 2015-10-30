cm_r = class({})

function cm_r:OnSpellStart()
	local hero = self:GetCaster().hero
	local target = self:GetCursorPosition()
end

function cm_r:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end