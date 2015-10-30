cm_q = class({})

function cm_q:OnSpellStart()
	local hero = self:GetCaster().hero
	local target = self:GetCursorPosition()
	local direction = target - hero:GetPos()

	if direction:Length2D() == 0 then
		direction = hero:GetFacing()
	end
end

function cm_q:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_1
end